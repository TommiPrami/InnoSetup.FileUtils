# InnoSetup.FileUtils

(requires SystemtimeUtils from https://github.com/TommiPrami/InnoSetup.SystemTimeUtils)

Few utilies for files, file age and systemtime. Some might be useful to others also. 

Main reason to write these utils was that I will need to do some pruning of files, by age, in the installer. Which I addmit, is not that common task for isntaller. I need it to get rid of potentially huge backups, that are too old to be useful anymore. 

Some code based on Stack overflow response, which I can't find anymore (will link and give credits if/when find it).

```Delphi
  function CopyFileIfNeeded(const AFileName, ASourceDir, ADestinationDir: string): Boolean;
  procedure CopyFileIfFilesAreDifferent(const ASourceFile, ADestFile: string);
  function TryGetFileTimes(const AFileName: string; out AFileTimes: TFileTimes): Boolean;
  function TrySetFileTimes(const AFileName: string; const AFileTimes: TFileTimes): Boolean;
  function DeleteFilesOlderThanEx(const ADirectory, AFileMask: string; const AFilesOlderThan: SYSTEMTIME; 
    const AMinFilesToKeep: Integer; const ADeletedFiles: TStringList): Integer;
  function DeleteFilesOlderThan(const ADirectory: string; const AFilesOlderThan: SYSTEMTIME; const AMinFilesToKeep: Integer): Integer;
```
