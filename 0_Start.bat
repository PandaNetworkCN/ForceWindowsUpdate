@Echo Off
REM Bat script start Powershell script
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -file "%~dp0Install_Windows_Update.ps1"