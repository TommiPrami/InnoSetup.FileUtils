// UnitTestFileUtils.iss

const
  TEST_DIRECTORY = 'TestFiles';
  TEST_DETLETEFILES_SUB_DIR = 'DeleteTestDir\';
var
  GCurrentTestMethodName: string;

// TODO: needs refactoring, some helper methods to get rid of duplicate code etc.

procedure ErrorMsg(const AErrorMessage: string; const AShowMessageBox: Boolean);
var
  LErrorMessage: string;
begin
  LErrorMessage := GCurrentTestMethodName + ' - ' + AErrorMessage;
  Log(LErrorMessage);

  if AShowMessageBox then
    MsgBox(LErrorMessage, mbCriticalError, MB_OK);
end;

procedure InitTest(const ATestMethodName: string);
begin
  GCurrentTestMethodName :=  ATestMethodName;

  ErrorMsg('* ' + GCurrentTestMethodName, False);
end;

function GetTestFileOrDir(const AFileName: string): string;
begin
  Result := AddBackSlash(ExpandConstant('{#SourcePath}') + TEST_DIRECTORY) + AFileName;
end;

procedure Test_DecMonth;
var
  LSourceTime: SYSTEMTIME;
  LResultTime: SYSTEMTIME;
begin
  InitTest('Test_DecMonth');

  LSourceTime := InitSystemTime(2023, 03, 31, 12, 32, 23, 666);
  
  LResultTime := DecMonth(LSourceTime, 1);
  if not SameSystemTime(LResultTime, InitSystemTime(2023, 02, 28, 12, 32, 23, 666)) then
    ErrorMsg('Did not ereturn Expected Date Time', True);

  LResultTime := DecMonth(LSourceTime, 3);
  if not SameSystemTime(LResultTime, InitSystemTime(2022, 12, 31, 12, 32, 23, 666)) then
    ErrorMsg('Did not ereturn Expected Date Time', True);

  LResultTime := DecMonth(LSourceTime, 15);
  if not SameSystemTime(LResultTime, InitSystemTime(2021, 12, 31, 12, 32, 23, 666)) then
    ErrorMsg('Did not ereturn Expected Date Time', True);
end;

procedure Test_ClearSystemTime;
var
  LSystemTime1: SYSTEMTIME;
begin
  InitTest('Test_ClearSystemTime');

  LSystemTime1.Year := 2023;

  ClearSystemTime(LSystemTime1);

  if LSystemTime1.Year <> 0 then
    ErrorMsg('Did not Clear', True);
end;

procedure Test_InitSystemTime;
var
  LSystemTime1: SYSTEMTIME;
begin
  InitTest('Test_InitSystemTime');

  LSystemTime1 := InitSystemTime(2023, 02, 09, 12, 01, 02, 003);

  if LSystemTime1.Year <> 2023 then
    ErrorMsg('ERROR: Year', True)
  else if  LSystemTime1.Month <> 2 then
    ErrorMsg('ERROR: Month', True)
  else if  LSystemTime1.Day <> 9 then
    ErrorMsg('ERROR: Day', True)
  else if  LSystemTime1.DayOfWeek <> 0 then
    ErrorMsg('ERROR: DayOfWeek', True)
  else if  LSystemTime1.Hour <> 12 then
    ErrorMsg('ERROR: Hour', True)
  else if  LSystemTime1.Minute <> 1 then
    ErrorMsg('ERROR: Minute', True)
  else if  LSystemTime1.Second <> 2 then
    ErrorMsg('ERROR: Second', True)
  else if  LSystemTime1.Millisecond <> 3 then
    ErrorMsg('ERROR: Millisecond', True)
end;

procedure Test_CompareSystemTime;
var
  LResult: Integer;
  LSystemTime1: SYSTEMTIME;
  LSystemTime2: SYSTEMTIME;
begin
  InitTest('Test_CompareSystemTime');

  LSystemTime1 := InitSystemTime(2023, 02, 09, 12, 00, 00, 000);
  LSystemTime2 := InitSystemTime(2023, 02, 09, 12, 00, 00, 000);

  // API
  LSystemTime2 := InitSystemTime(2023, 02, 09, 12, 00, 00, 000);
  LResult := CompareSystemTime(LSystemTime1, LSystemTime2)
  if LResult <> 0 then
    ErrorMsg('Did not return 0. Returned : ' + IntToStr(LResult) + ' - ' + GetSortableTimeStampStr(LSystemTime1) + ' <> ' + GetSortableTimeStampStr(LSystemTime2), True);

  LSystemTime2 := InitSystemTime(2023, 02, 09, 11, 59, 50, 000);
  LResult := CompareSystemTime(LSystemTime1, LSystemTime2)
  if LResult <> 1 then
    ErrorMsg('Did not return 1. Returned : ' + IntToStr(LResult) + ' - ' + GetSortableTimeStampStr(LSystemTime1) + ' <> ' + GetSortableTimeStampStr(LSystemTime2), True);

  LSystemTime2 := InitSystemTime(2023, 02, 09, 12, 00, 10, 001);
  LResult := CompareSystemTime(LSystemTime1, LSystemTime2)
  if LResult <> -1 then
    ErrorMsg('Did not return -1. Returned : ' + IntToStr(LResult) + ' - ' + GetSortableTimeStampStr(LSystemTime1) + ' <> ' + GetSortableTimeStampStr(LSystemTime2), True);
end;

procedure Test_CompareSystemTimeFromFile;
var
  LFileTimes: TFileTimes;
  LManualSystemTime: SYSTEMTIME;
  LResult: Integer;
begin
  InitTest('Test_CompareSystemTimeFromFile');

  if not TryGetFileTimes(GetTestFileOrDir('msvcp80.dll'),  LFileTimes) then
    ErrorMsg('Error: Returned False', True);

  LResult := CompareSystemTime(LFileTimes.CreationTime, LFileTimes.CreationTime);
  if LResult <> 0 then
    ErrorMsg('Error: Expected 0, Returned ' + IntToStr(LResult), True);

  LResult := CompareSystemTime(LFileTimes.CreationTime, LFileTimes.LastWriteTime);
  if LResult <> 1 then
    ErrorMsg('Error: Expected 0, Returned ' + IntToStr(LResult), True);

  LResult := CompareSystemTime(LFileTimes.LastWriteTime, LFileTimes.CreationTime);
  if LResult <> -1 then
    ErrorMsg('Error: Expected 0, Returned ' + IntToStr(LResult), True);

  LManualSystemTime := InitSystemTime(2000, 01, 01, 01, 01, 01, 001);
  LResult := CompareSystemTime(LManualSystemTime, LFileTimes.LastWriteTime);
  if LResult <> -1 then
    ErrorMsg('Error: Expected 0, Returned ' + IntToStr(LResult), True);

  LManualSystemTime := InitSystemTime(2024, 01, 01, 01, 01, 01, 001);
  LResult := CompareSystemTime(LManualSystemTime, LFileTimes.LastWriteTime);
  if LResult <> 1 then
    ErrorMsg('Error: Expected 0, Returned ' + IntToStr(LResult), True);

  LManualSystemTime := InitSystemTime(2005, 09, 22, 21, 05, 58, 000);
  LResult := CompareSystemTime(LManualSystemTime, LFileTimes.LastWriteTime)
  if LResult <> 0 then
    ErrorMsg('Did not return 0. Returned : ' + IntToStr(LResult) + ' - ' + GetSortableTimeStampStr(LManualSystemTime) + ' <> ' + GetSortableTimeStampStr(LFileTimes.LastWriteTime), True);
end;

procedure Test_GetSortableTimeStampStr;
var
  LSystemTime1: SYSTEMTIME;
  LResult: string;
begin
  InitTest('Test_GetSortableTimeStampStr');

  LSystemTime1 := InitSystemTime(2023, 02, 09, 12, 00, 00, 000);

  LResult := GetSortableTimeStampStr(LSystemTime1);
  if LResult <> '2023-02-09 12:00:00:000'  then
    ErrorMsg('Error Returned: ' + LResult, True);
end;

procedure Test_TryGetFileTimes;
var
  LFileTimes: TFileTimes;
  LCompareTimeTo: SYSTEMTIME;
begin
  InitTest('Test_TryGetFileTimes');

  if not TryGetFileTimes(GetTestFileOrDir('msvcp80.dll'),  LFileTimes) then
    ErrorMsg('Error: Returned False', True);

  LCompareTimeTo := InitSystemTime(2023, 02, 09, 11, 19, 34, 942);
  if not SameSystemTime(LFileTimes.CreationTime, LCompareTimeTo) then
    ErrorMsg('Error: LFileTimes.CreationTime: ' + GetSortableTimeStampStr(LFileTimes.CreationTime) + ' <> ' + GetSortableTimeStampStr(LCompareTimeTo), True);

  LCompareTimeTo := InitSystemTime(2005, 09, 22, 21, 05, 58, 000);
  if not SameSystemTime(LFileTimes.LastWriteTime, LCompareTimeTo) then
    ErrorMsg('Error: LFileTimes.LastWriteTime: ' + GetSortableTimeStampStr(LFileTimes.LastWriteTime) + ' <> ' + GetSortableTimeStampStr(LCompareTimeTo), True);
end;

procedure Test_TrySetFileTimes;
begin
  // InitTest('Test_TrySetFileTimes');

  // TrySetFileTimes(const AFileName: string; const AFileTimes: TFileTimes): Boolean;
end;

procedure CheckFile(const AFiles: TStringList; const AIndex: Integer; const AExpectedFileName: string);
begin
  if not SameText(AFiles[AIndex], GetTestFileOrDir(AExpectedFileName)) then
    ErrorMsg('Error: Wrong file index ' + IntToStr(AIndex) + ': ' + AFiles[AIndex], True);
end;

procedure CheckFiles(const AFiles: TStringList);
begin
  AFiles.Sort;

  CheckFile(AFiles, 0, 'icudt30.dll');
  CheckFile(AFiles, 3, 'libeay32.dll');
  CheckFile(AFiles, 6, 'libpq.dll');
  // not an natural sort/compare, thats why msvcp140.dll is not last file as is in Win11 Explorer
  CheckFile(AFiles, 8, 'msvcp80.dll');
end;

procedure Test_GetFilesFromDirectory;
var
  LFiles: TStringList;
begin
  InitTest('Test_GetFilesFromDirectory');

  LFiles := TStringList.Create;
  try
    if not GetFilesFromDirectory(GetTestFileOrDir(''), LFiles, True) then
      ErrorMsg('Error Returned: False', True);

    if LFiles.Count <> 9 then
      ErrorMsg('Error: Wrong file count: ' + IntToStr(LFiles.Count), True);

    CheckFiles(LFiles);
  finally
    LFiles.Free;
  end;
end;

procedure Test_GetFilesFromDirectoryEx;
var
  LFiles: TStringList;
begin
  InitTest('Test_GetFilesFromDirectoryEx');

  LFiles := TStringList.Create;
  try
    if GetFilesFromDirectoryEx(GetTestFileOrDir(''), '*.zip', LFiles, True) then
      ErrorMsg('Error Returned: True', True);

    if LFiles.Count <> 0 then
      ErrorMsg('Error: Wrong file count: ' + IntToStr(LFiles.Count), True);

    if not GetFilesFromDirectoryEx(GetTestFileOrDir(''), '*.dll', LFiles, True) then
      ErrorMsg('Error Returned: False', True);

    if LFiles.Count <> 9 then
      ErrorMsg('Error: Wrong file count: ' + IntToStr(LFiles.Count), True);

    CheckFiles(LFiles);
  finally
    LFiles.Free;
  end;
end;

procedure Test_GetFilesOlderThan;
var
  LAllFiles: TStringList;
  LOlderThanFiles: TStringList;
  LResult: Boolean;
  LOlderThanTimeStamp: SYSTEMTIME;
  LIndex: Integer;
begin
  InitTest('Test_GetFilesOlderThan');

  LAllFiles := TStringList.Create;
  LOlderThanFiles := TStringList.Create;
  try
    if not GetFilesFromDirectory(GetTestFileOrDir(''), LAllFiles, True) then
      ErrorMsg('Error Returned: False', True);

    // 
    LOlderThanTimeStamp := InitSystemTime(2004, 06, 06, 23, 59, 59, 999);
    LOlderThanFiles.Clear;
    LResult := GetFilesOlderThan(LAllFiles, LOlderThanFiles, LOlderThanTimeStamp, True);
    if LResult then
      ErrorMsg('Error: Should not return True for TimeStamp: ' + GetSortableTimeStampStr(LOlderThanTimeStamp), True);

    // 
    LOlderThanTimeStamp := InitSystemTime(2022, 06, 15, 23, 59, 59, 999);
    LOlderThanFiles.Clear;
    LResult := GetFilesOlderThan(LAllFiles, LOlderThanFiles, LOlderThanTimeStamp, True);
    for LIndex := 0 to LOlderThanFiles.Count - 1 do
      Log('  - ' + LOlderThanFiles[LIndex]);
    if not LResult then
      ErrorMsg('Error: Should return True for TimeStamp: ' + GetSortableTimeStampStr(LOlderThanTimeStamp), True);
    if LOlderThanFiles.Count <> 5 then
      ErrorMsg('Error: Should return 5 oldest files, returned count=' + IntToStr(LOlderThanFiles.Count) + ', with timestamp TimeStamp: ' + GetSortableTimeStampStr(LOlderThanTimeStamp), True);
    if Pos('MSVCP80.DLL', (AnsiUppercase(LOlderThanFiles[0]))) = 0 then
      ErrorMsg('Error: Wrong oldest file: ' + LOlderThanFiles[0], True);


    GetLocalTime(LOlderThanTimeStamp);
    LOlderThanFiles.Clear;
    LResult := GetFilesOlderThan(LAllFiles, LOlderThanFiles, LOlderThanTimeStamp, True);
    if not LResult then
      ErrorMsg('Error: Should  return True for TimeStamp: ' + GetSortableTimeStampStr(LOlderThanTimeStamp), True);
    for LIndex := 0 to LOlderThanFiles.Count - 1 do
      Log('  - ' + LOlderThanFiles[LIndex]);
    if LOlderThanFiles.Count <> 9 then
      ErrorMsg('Error: Should return 5 oldest files, returned count=' + IntToStr(LOlderThanFiles.Count) + ', with timestamp TimeStamp: ' + GetSortableTimeStampStr(LOlderThanTimeStamp), True);
    if Pos('MSVCP80.DLL', (AnsiUppercase(LOlderThanFiles[0]))) = 0 then
      ErrorMsg('Error: Wrong oldest file: ' + LOlderThanFiles[0], True);
  finally
    LAllFiles.Free;
    LOlderThanFiles.Free;
  end;
end;

procedure Test_DeleteFilesOlderThan;
var
  LDirectory: string;
  LOlderThanTimeStamp: SYSTEMTIME;
  LFilesDeleted: Integer;
  LFilesInDir: TStringList;
begin
  InitTest('Test_GetFilesOlderThan');

  LDirectory := GetTestFileOrDir(TEST_DETLETEFILES_SUB_DIR);
  // 
  LOlderThanTimeStamp := InitSystemTime(2022, 06,  12, 12, 12, 12, 012);
  LFilesDeleted := DeleteFilesOlderThan(LDirectory,  LOlderThanTimeStamp, 2);
  if LFilesDeleted <> 5 then
    ErrorMsg('Expected to delete 5 files, deteted ' + IntToStr(LFilesDeleted), True);

  // Should not have single gfile with these paramerters lefft in the directory
  LOlderThanTimeStamp := InitSystemTime(2022, 06,  18, 12, 12, 12, 012);
  LFilesDeleted := DeleteFilesOlderThan(LDirectory,  LOlderThanTimeStamp, 4);
  if LFilesDeleted <> 0 then
    ErrorMsg('Expected to delete 0 files, deteted ' + IntToStr(LFilesDeleted), True);

  // 
  LOlderThanTimeStamp := InitSystemTime(2022, 06,  18, 12, 12, 12, 012);
  LFilesDeleted := DeleteFilesOlderThan(LDirectory,  LOlderThanTimeStamp, 2);
  if LFilesDeleted <> 2 then
    ErrorMsg('Expected to delete 2 files, deteted ' + IntToStr(LFilesDeleted), True);

  // Repeat previous call, should not have any files to delete
  LOlderThanTimeStamp := InitSystemTime(2022, 06,  18, 12, 12, 12, 012);
  LFilesDeleted := DeleteFilesOlderThan(LDirectory,  LOlderThanTimeStamp, 2);
  if LFilesDeleted <> 0 then
    ErrorMsg('Expected to delete 0 files, deteted ' + IntToStr(LFilesDeleted), True);

  LOlderThanTimeStamp := InitSystemTime(2024, 06,  18, 12, 12, 12, 012);
  LFilesDeleted := DeleteFilesOlderThan(LDirectory,  LOlderThanTimeStamp, 1);
  if LFilesDeleted <> 1 then
    ErrorMsg('Expected to delete 1 files, deteted ' + IntToStr(LFilesDeleted), True);

  // Keep 0 files, and timestamp in future, should remove all files.
  LOlderThanTimeStamp := InitSystemTime(2024, 06,  18, 12, 12, 12, 012);
  LFilesDeleted := DeleteFilesOlderThan(LDirectory,  LOlderThanTimeStamp, 0);
  if LFilesDeleted <> 1 then
    ErrorMsg('Expected to delete 1 files, deteted ' + IntToStr(LFilesDeleted), True);

  LFilesInDir := TStringList.Create;
  try
    if GetFilesFromDirectory(LDirectory, LFilesInDir, False) then
      ErrorMsg('Directory should be empty at this point', True)
    else if LFilesInDir.Count <> 0 then
      ErrorMsg('Directory should be empty at this point and for sure FileList count should be 0, not:' + IntToStr(LFilesInDir.Count), True);
  finally
    LFilesInDir.Free;
  end;
end;

procedure CopyTestFiles;
var
  LSourceDir: string;
  LDestinationDir: string;
begin

  LSourceDir := GetTestFileOrDir('');
  LDestinationDir := GetTestFileOrDir(TEST_DETLETEFILES_SUB_DIR);

  CopyFileIfNeeded('msvcp80.dll', LSourceDir, LDestinationDir);
  CopyFileIfNeeded('icuin30.dll', LSourceDir, LDestinationDir);
  CopyFileIfNeeded('icuuc30.dll', LSourceDir, LDestinationDir);
  CopyFileIfNeeded('icudt30.dll', LSourceDir, LDestinationDir);
  CopyFileIfNeeded('msvcp140.dll', LSourceDir, LDestinationDir);
  CopyFileIfNeeded('libiconv-2.dll', LSourceDir, LDestinationDir);
  CopyFileIfNeeded('libintl-8.dll', LSourceDir, LDestinationDir);
  CopyFileIfNeeded('libpq.dll', LSourceDir, LDestinationDir);
  CopyFileIfNeeded('libeay32.dll', LSourceDir, LDestinationDir);
end;

function GetFilenamesInfo(const ASourceFile, ADestFile: string): string;
begin
  Result := 'Source: "' + ASourceFile +'", and Destination: "' + ADestFile + '"'
end;

procedure Test_InternalFilesAreDifferent(const ASourceDirectory, ADestinationDirectory, AFileName, ADestinationFileName: string; const AExpectedResult, AdestinationMustExists: Boolean);
var
  LSourceFileName: string;
  LDestinationFileName: string;
begin
  if ADestinationFileName <> '' then
    LDestinationFileName := ADestinationDirectory + ADestinationFileName
  else
    LDestinationFileName := ADestinationDirectory + AFileName;
  
  LSourceFileName := ASourceDirectory + AFileName; 

  if not FileExists(LSourceFileName) then
    ErrorMsg('Source file not found: ' + LSourceFileName, True)
  else if AdestinationMustExists and not FileExists(LDestinationFileName) then
    ErrorMsg('Destination file not found, even tough mandatory for the test: ' + LDestinationFileName, True)
  else if FilesAreDifferent(LSourceFileName,  LDestinationFileName) <> AExpectedResult then
  begin
    if not AExpectedResult then
      ErrorMsg('Files should be identical. ' + GetFilenamesInfo(LSourceFileName, LDestinationFileName), True)
    else
      ErrorMsg('Files should NOT be identical. + GetFilenamesInfo(LSourceFileName, LDestinationFileName)', True);
  end
  else
    ErrorMsg('Expected result for - ' +  + GetFilenamesInfo(LSourceFileName, LDestinationFileName), False);
end;

procedure DeleteTestFiles(const ADirectory: string);
var
  LOlderThanTimeStamp: SYSTEMTIME;
begin
  LOlderThanTimeStamp := InitSystemTime(2066, 06,  18, 12, 12, 12, 012);
  DeleteFilesOlderThan(ADirectory,  LOlderThanTimeStamp, 0);
end;

procedure Test_CopyFileIfChanged;
var
  LSourceDir: string;
  LDestinationDir: string;
begin
  InitTest('Test_CopyFileIfChanged');

  LSourceDir := GetTestFileOrDir('');
  LDestinationDir := GetTestFileOrDir(TEST_DETLETEFILES_SUB_DIR);

  CopyTestFiles;

  Test_InternalFilesAreDifferent(LSourceDir, LDestinationDir, 'msvcp80.dll', '', False, True);
  Test_InternalFilesAreDifferent(LSourceDir, LDestinationDir, 'icuin30.dll', '', False, True);
  Test_InternalFilesAreDifferent(LSourceDir, LDestinationDir, 'icuin30.dll', 'msvcp80.dll', True, True);
  Test_InternalFilesAreDifferent(LSourceDir, LDestinationDir, 'icuin30.dll', 'uuuuh_msvcp80.dll', True, False);

  // Get Rid of test files...
  DeleteTestFiles(LDestinationDir);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  case CurStep of
    ssInstall:
      begin
        Log('CurStepChanged.CurStep = ssInstall');

        // First copy test files for Test_DeleteFilesOlderThan
        CopyTestFiles;

        Test_DecMonth;
        Test_ClearSystemTime;
        Test_InitSystemTime;
        Test_CompareSystemTime;
        Test_CompareSystemTimeFromFile;
        Test_GetSortableTimeStampStr;
        Test_TryGetFileTimes;
        Test_TrySetFileTimes;
        Test_GetFilesFromDirectory;
        Test_GetFilesFromDirectoryEx;
        Test_GetFilesOlderThan;
        Test_DeleteFilesOlderThan;
        Test_CopyFileIfChanged;
      end;
  end;
end;
