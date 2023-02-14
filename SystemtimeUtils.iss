// SystemtimeUtils.iss

type
  SYSTEMTIME = record 
    Year: WORD; 
    Month: WORD; 
    DayOfWeek: WORD; 
    Day: WORD; 
    Hour: WORD; 
    Minute: WORD; 
    Second: WORD; 
    Millisecond: WORD; 
  end; 

// WinAPI declarations
  function FileTimeToSystemTime(const FileTime: TFileTime; var SystemTime: SYSTEMTIME): BOOL; external 'FileTimeToSystemTime@kernel32.dll stdcall';
  procedure GetLocalTime(var SystemTime: SYSTEMTIME); external 'GetLocalTime@kernel32.dll stdcall';
  function SystemTimeToFileTime(const SystemTime: SYSTEMTIME; var FileTime: TFileTime): BOOL; external 'SystemTimeToFileTime@kernel32.dll stdcall';
  function CompareFileTime(const FileTime1, FileTime2: TFileTime): Integer; external 'CompareFileTime@kernel32.dll stdcall';


procedure ClearSystemTime(var ASystemTime: SYSTEMTIME);
begin
  ASystemTime.Year := 0; 
  ASystemTime.Month := 0; 
  ASystemTime.DayOfWeek := 0; 
  ASystemTime.Day := 0; 
  ASystemTime.Hour := 0; 
  ASystemTime.Minute := 0; 
  ASystemTime.Second := 0; 
  ASystemTime.Millisecond := 0; 
end;

function GetSystemTimeErrorStr(const AValueName: string; const AValue: WORD): string;
begin
  Result := 'Invalid "' + AValueName + '" value for SystemTime: ' + IntToStr(AValue);
end;

function InitSystemTime(const AYear, AMonth, ADay, AHour, AMinute, ASecond, AMillisecond: WORD): SYSTEMTIME;
begin 
  Result.Year := AYear; 

  if (AMonth >= 1) and  (AMonth <= 12) then
    Result.Month := AMonth
  else
    RaiseException(GetSystemTimeErrorStr('Month', AMonth));

  Result.DayOfWeek := 0; 
  
  if (ADay >= 1) and (ADay <= 31) then
    Result.Day := ADay
  else
    RaiseException(GetSystemTimeErrorStr('Day', ADay));

  if AHour <= 23 then
    Result.Hour := AHour
  else
    RaiseException(GetSystemTimeErrorStr('Hour', AHour));

  if AMinute <= 59 then
    Result.Minute := AMinute
  else
    RaiseException(GetSystemTimeErrorStr('Minute', AMinute));

  if ASecond <= 59 then
    Result.Second := ASecond
  else
    RaiseException(GetSystemTimeErrorStr('Second', ASecond));

  if AMillisecond <= 999 then
    Result.Millisecond := AMillisecond
  else
    RaiseException(GetSystemTimeErrorStr('Millisecond', AMillisecond));
end;

function SameSystemTime(const ASystemTime1, ASystemTime2: SYSTEMTIME): Boolean;
begin
  Result := (ASystemTime1.Year = ASystemTime2.Year)
    and (ASystemTime1.Month = ASystemTime2.Month)
    and (ASystemTime1.Day = ASystemTime2.Day)
    and (ASystemTime1.Hour = ASystemTime2.Hour)
    and (ASystemTime1.Minute = ASystemTime2.Minute)
    and (ASystemTime1.Second = ASystemTime2.Second)
    and (ASystemTime1.Millisecond = ASystemTime2.Millisecond);
end;

(*
function CompareSystemTime(const ASystemTime1, ASystemTime2: SYSTEMTIME): Integer;
var
  LFileTime1: TFileTime;
  LFileTime2: TFileTime;
begin
  if Boolean(SystemTimeToFileTime(ASystemTime1, LFileTime1)) and Boolean(SystemTimeToFileTime(ASystemTime2, LFileTime2)) then
    Result := CompareFileTime(LFileTime1, LFileTime2)
  else
    Result := MIN_INT;
end; 
*)

function SystemTimeGreater(const ASystemTime1, ASystemTime2: SYSTEMTIME): Boolean;
begin
  if SameSystemTime(ASystemTime1, ASystemTime2) then
    Result := False
  else if ASystemTime1.Year < ASystemTime2.Year then
    Result := False
  else if ASystemTime1.Year > ASystemTime2.Year then
    Result := True
  else 
  begin
    if ASystemTime1.Month < ASystemTime2.Month then
      Result := False
    else if ASystemTime1.Month > ASystemTime2.Month then 
      Result := True
    else 
    begin
      if ASystemTime1.Day < ASystemTime2.Day then
        Result := False
      else if ASystemTime1.Day > ASystemTime2.Day then 
        Result := True
      else 
      begin
        if ASystemTime1.Hour < ASystemTime2.Hour then
          Result := False
        else if ASystemTime1.Hour > ASystemTime2.Hour then 
          Result := True
        else 
        begin
          if ASystemTime1.Minute < ASystemTime2.Minute then
            Result := False
          else if ASystemTime1.Minute > ASystemTime2.Minute then 
            Result := True
          else 
          begin
            if ASystemTime1.Second < ASystemTime2.Second then
              Result := False
            else if ASystemTime1.Second > ASystemTime2.Second then 
              Result := True
            else 
            begin
              if ASystemTime1.Millisecond < ASystemTime2.Millisecond then
                Result := False
              else if ASystemTime1.Millisecond > ASystemTime2.Millisecond then 
                Result := True
            end;
          end;
        end;
      end;
    end;
  end;
end;

function CompareSystemTime(const ASystemTime1, ASystemTime2: SYSTEMTIME): Integer;
begin 
  if SameSystemTime(ASystemTime1, ASystemTime2) then
    Result := 0
  else if SystemTimeGreater(ASystemTime1, ASystemTime2) then
    Result := 1
  else
    Result := -1
end;

function GetSortableTimeStampStr(const ATimeStamp: SYSTEMTIME): string;
begin
  Result := Format('%.4d-%.2d-%.2d %.2d:%.2d:%.2d:%.3d', [ATimeStamp.Year, ATimeStamp.Month, ATimeStamp.Day, 
    ATimeStamp.Hour, ATimeStamp.Minute, ATimeStamp.Second , ATimeStamp.Millisecond]);
end;