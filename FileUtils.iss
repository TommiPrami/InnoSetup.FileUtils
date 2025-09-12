// FileUtils.iss

const
  OPEN_EXISTING = 3;
  GENERIC_READ = $80000000;
  FILE_SHARE_READ = $00000001;
  FILE_SHARE_WRITE = $00000002;
  FILE_WRITE_ATTRIBUTES = $0100;
  INVALID_HANDLE_VALUE = 4294967295;
  MAX_INT = 2147483647;
  MIN_INT = -2147483648;

type
  TFileTimes = record
    CreationTime: SYSTEMTIME;
    LastWriteTime: SYSTEMTIME;
    LastAccessTime: SYSTEMTIME;
  end;

  // WinAPI declarations
  function CreateFile(lpFileName: string; dwDesiredAccess, dwShareMode, lpSecurityAttributes, dwCreationDisposition, 
    dwFlagsAndAttributes: DWORD; hTemplateFile: THandle): THandle; external 'CreateFileW@kernel32.dll stdcall';
  function CloseHandle(hObject: THandle): BOOL; external 'CloseHandle@kernel32.dll stdcall';
  function GetFileTime(hFile: THandle; out lpCreationTime, lpLastAccessTime, lpLastWriteTime: TFileTime): BOOL; external 'GetFileTime@kernel32.dll stdcall';
  function SetFileTime(hFile: THandle; const lpCreationTime, lpLastAccessTime, lpLastWriteTime: TFileTime): BOOL; external 'SetFileTime@kernel32.dll stdcall';

function MaxInteger(const AValue1, AValue2: Integer): Integer;
begin
  if AValue1 > AValue2 then
    Result := AValue1
  else
    Result := AValue2;
end;

function MinInteger(const AValue1, AValue2: Integer): Integer;
begin
  if AValue1 < AValue2 then
    Result := AValue1
  else
    Result := AValue2;
end;

function CopyFileIfNeeded(const AFileName, ASourceDir, ADestinationDir: string): Boolean;
var
  LSourceFile: string;
  LDestinationFile: string;
begin
  Result := False;

  if AFileName = '' then
    Exit;

  LSourceFile := AddBackslash(ASourceDir) + AFileName;
  LDestinationFile := AddBackslash(ADestinationDir) + AFileName;

  if FileExists(LSourceFile) then
    Result := CopyFile(LSourceFile, LDestinationFile, False);
end;

function FilesAreDifferent(const ASourceFile, ADestFile: string): Boolean;
var
  LSourceFileInfo: TFindRec;
  LDestFileInfo: TFindRec;
begin
  Result := True; // Assume files are different by default

  if FindFirst(ASourceFile, LSourceFileInfo) then
  begin
    try
      if FindFirst(ADestFile, LDestFileInfo) then
      begin
        try
          Result := 
            (LSourceFileInfo.LastWriteTime.dwLowDateTime <> LDestFileInfo.LastWriteTime.dwLowDateTime) 
            or (LSourceFileInfo.LastWriteTime.dwHighDateTime <> LDestFileInfo.LastWriteTime.dwHighDateTime) 
            or (LSourceFileInfo.SizeLow <> LDestFileInfo.SizeLow)
            or (LSourceFileInfo.SizeHigh <> LDestFileInfo.SizeHigh);

          if Result then
            Result := GetSHA1OfString(ASourceFile) <> GetSHA1OfString(ADestFile); 
        finally
          FindClose(LDestFileInfo);
        end;
      end;
    finally
      FindClose(LSourceFileInfo);
    end;
  end;
end;

procedure CopyFileIfFilesAreDifferent(const ASourceFile, ADestFile: string);
begin
  if FilesAreDifferent(ASourceFile, ADestFile) then
    CopyFile(ASourceFile, ADestFile, False);
end;

function SplitNameAndValue(const ANameValuePair: string; var AName, AValue: string): Boolean;
var
  LSeparatorPosiotion: Integer;
begin
  Result := False;
  AName := '';
  AValue := '';

  LSeparatorPosiotion := Pos('=', ANameValuePair);
  if LSeparatorPosiotion >= 2 then
  begin
     // Copy(S: String; Index, Count: Integer): String;
    AName := Copy(ANameValuePair, 1, LSeparatorPosiotion - 1);
    AValue := Copy(ANameValuePair, LSeparatorPosiotion + 1, MAX_INT);

    Result := AName <> '';
  end;
end;

function TryGetFileTimes(const AFileName: string; out AFileTimes: TFileTimes): Boolean;
var
  LFileHandle: THandle;
  LCreationTime: TFileTime;
  LLastWriteTime: TFileTime;
  LLastAccessTime: TFileTime;
  LSystemTime: SYSTEMTIME;
begin
  Result := False;

  LFileHandle := CreateFile(AFileName, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if LFileHandle <> INVALID_HANDLE_VALUE then
  try
    Result := Boolean(GetFileTime(LFileHandle, LCreationTime, LLastAccessTime, LLastWriteTime));

    if Result then
    begin
      if Boolean(FileTimeToSystemTime(LCreationTime, LSystemTime)) then 
        AFileTimes.CreationTime := LSystemTime;

      if Boolean(FileTimeToSystemTime(LLastWriteTime, LSystemTime)) then 
        AFileTimes.LastWriteTime := LSystemTime;

      if Boolean(FileTimeToSystemTime(LLastAccessTime, LSystemTime)) then 
        AFileTimes.LastAccessTime := LSystemTime;
    end;
  finally
    CloseHandle(LFileHandle);
  end;
end;

function TrySetFileTimes(const AFileName: string; const AFileTimes: TFileTimes): Boolean;
var
  LFileHandle: THandle;
  LCreationTime: TFileTime;
  LLastAccessTime: TFileTime;
  LLastWriteTime: TFileTime;
begin
  Result := False;

  LFileHandle := CreateFile(AFileName, FILE_WRITE_ATTRIBUTES, FILE_SHARE_WRITE, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if LFileHandle <> INVALID_HANDLE_VALUE then
  try
    if Boolean(SystemTimeToFileTime(AFileTimes.CreationTime, LCreationTime)) 
      and Boolean(SystemTimeToFileTime(AFileTimes.LastAccessTime, LLastAccessTime)) 
      and Boolean(SystemTimeToFileTime(AFileTimes.LastWriteTime, LLastWriteTime)) then
      Result := Boolean(SetFileTime(LFileHandle, LCreationTime, LLastAccessTime, LLastWriteTime));
  finally
    CloseHandle(LFileHandle);
  end;
end;

function GetFilesFromDirectoryEx(const ADirectory, AFileMask: string; const AFiles: TStringList; const ASortFiles: Boolean): Boolean;
var
  LDirectory: string;
  LFindRec: TFindRec;
  LFileMask: string;
begin
  Result := False;
  if AFileMask = '' then
    LFileMask := '*'
  else
    LFileMask :=  AFileMask;

  LDirectory := AddBackslash(ADirectory);

  if FindFirst(ExpandConstant(LDirectory + LFileMask), LFindRec) then
  try
    repeat
      if LFindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY = 0 then
        AFiles.Add(LDirectory + LFindRec.Name);
    until not FindNext(LFindRec);
  finally
    FindClose(LFindRec);
  end;

  Result := AFiles.Count >= 1; 
  if Result and ASortFiles and (AFiles.Count >= 2) then
    AFiles.Sort;
end;

function GetFilesFromDirectory(const ADirectory: string; const AFiles: TStringList; const ASortFiles: Boolean): Boolean;
begin
  Result := GetFilesFromDirectoryEx(ADirectory,'', AFiles, ASortFiles);
end;

function GetFilesOlderThan(const AFilesToCheck, AFilesOlder: TStringList; const AFilesOlderThan: SYSTEMTIME; const AAddSortableTimeStampPrefix: Boolean): Boolean;
var
  LIndex: Integer;
  LFileName: string;
  LFileTimes: TFileTimes;
  LCompareResult: Integer;
begin
  Result := False;

  for LIndex := 0 to AFilesToCheck.Count - 1 do
  begin
    LFileName := AFilesToCheck[LIndex];

    if TryGetFileTimes(LFileName, LFileTimes) then
    begin
      LCompareResult := CompareSystemTime(LFileTimes.LastWriteTime, AFilesOlderThan);

      if LCompareResult = -1 then
      begin
        Result := True;

        if AAddSortableTimeStampPrefix then
          LFileName := GetSortableTimeStampStr(LFileTimes.LastWriteTime) + '=' + LFileName;

        AFilesOlder.Add(LFileName);
      end;
    end;
  end;

  if AAddSortableTimeStampPrefix and (AFilesOlder.Count > 1) then
    AFilesOlder.Sort;
end;

function DeleteFilesOlderThanEx(const ADirectory, AFileMask: string; const AFilesOlderThan: SYSTEMTIME; const AMinFilesToKeep: Integer; const ADeletedFiles: TStringList): Integer;
var
  LFilesToCheck: TStringList;
  LOlderFilesWithTimeStamp: TStringList;
  LNewerFilesCount: Integer;
  LFilesToDelete: Integer;
  LIndex: Integer;
  LTimeStamp: string;
  LFileName: string;
begin
  Result := 0;

  LFilesToCheck := TStringList.Create;
  LOlderFilesWithTimeStamp := TStringList.Create;
  try
    if GetFilesFromDirectoryEx(ADirectory, AFileMask, LFilesToCheck, False) then
      if GetFilesOlderThan(LFilesToCheck, LOlderFilesWithTimeStamp, AFilesOlderThan, True) then
      begin
        LNewerFilesCount := MaxInteger(LFilesToCheck.Count - LOlderFilesWithTimeStamp.Count, 0);

        if LFilesToCheck.Count <= AMinFilesToKeep then
          LFilesToDelete := 0 // Delete none
        else if LNewerFilesCount >= AMinFilesToKeep then
          LFilesToDelete := LOlderFilesWithTimeStamp.Count // Delete all older
        else 
          LFilesToDelete := MinInteger(LFilesToCheck.Count - AMinFilesToKeep, LOlderFilesWithTimeStamp.Count);

        for LIndex := 0 to LFilesToDelete - 1 do
        begin
          SplitNameAndValue(LOlderFilesWithTimeStamp[LIndex], LTimeStamp, LFileName);

          if FileExists(LFileName) then 
            if DeleteFile(LFileName) then
            begin
              ADeletedFiles.Add(LFileName);
              Inc(Result);
            end;
        end;
      end;
  finally
    LFilesToCheck.Free;
    LOlderFilesWithTimeStamp.Free;
  end;
end;

function DeleteFilesOlderThan(const ADirectory: string; const AFilesOlderThan: SYSTEMTIME; const AMinFilesToKeep: Integer): Integer;
var
  LTempFilesList: TStringList;
begin
  LTempFilesList := TStringList.Create;
  try
    Result := DeleteFilesOlderThanEx(ADirectory, '', AFilesOlderThan, AMinFilesToKeep, LTempFilesList);
  finally
    LTempFilesList.Free;
  end;
end;
