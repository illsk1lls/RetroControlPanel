@ECHO OFF
FOR /F "usebackq tokens=3" %%i IN (`REG QUERY "HKCU\Console" /v ForceV2 2^>nul`) DO IF NOT "%%i"=="1" SET STATE=REVERT & REG ADD "HKCU\Console" /v ForceV2 /t REG_DWORD /d 1 /f>nul
MODE 45,17
SET "TitleName=Retro Control Panel"
TASKLIST /V /NH /FI "imagename eq cmd.exe"|FIND /I /C "%TitleName%">nul
IF NOT %errorlevel% == 1 (ECHO ERROR: & ECHO Retro Control Panel is already open!) |MSG %UserName% & EXIT /b
TITLE %TitleName%
>nul 2>&1 REG ADD HKCU\Software\Classes\.RetroCP\shell\runas\command /f /ve /d "CMD /x /d /r SET \"f0=%%2\"& call \"%%2\" %%3"& set _= %*
>nul 2>&1 FLTMC||(CD.>"%temp%\elevate.RetroCP" & START "%~n0" /high "%temp%\elevate.RetroCP" "%~f0" "%_:"=""%"& EXIT /b)
>nul 2>&1 REG DELETE HKCU\Software\Classes\.RetroCP\ /f &>nul 2>&1 DEL %temp%\elevate.RetroCP /f
CD /D %~dp0 & IF NOT "%~f0" EQU "%ProgramData%\%~nx0" (COPY /Y "%~f0" "%ProgramData%">nul & START "" "%ProgramData%\%~nx0" %STATE%& EXIT /b)
FOR /F "usebackq skip=2 tokens=3-4" %%i IN (`REG QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul`) DO IF NOT "%%i %%j"=="Windows 10" ECHO. & ECHO Unsupported system detected. & ECHO. & PAUSE & EXIT
>nul 2>&1 POWERSHELL -nop -c "(Add-Type -PassThru 'using System;using System.Runtime.InteropServices;namespace CloseButtonToggle{internal static class WinAPI{[DllImport(\"kernel32.dll\")]internal static extern IntPtr GetConsoleWindow();[DllImport(\"user32.dll\")][return:MarshalAs(UnmanagedType.Bool)]internal static extern bool DeleteMenu(IntPtr hMenu,uint uPosition,uint uFlags);[DllImport(\"user32.dll\")][return:MarshalAs(UnmanagedType.Bool)]internal static extern bool DrawMenuBar(IntPtr hWnd);[DllImport(\"user32.dll\")]internal static extern IntPtr GetSystemMenu(IntPtr hWnd,[MarshalAs(UnmanagedType.Bool)]bool bRevert);const uint SC_CLOSE=0xf060;const uint MF_BYCOMMAND=0;internal static void ChangeCurrentState(bool state){IntPtr hMenu=GetSystemMenu(GetConsoleWindow(),state);DeleteMenu(hMenu,SC_CLOSE, MF_BYCOMMAND);DrawMenuBar(GetConsoleWindow());}}public static class Status{public static void Disable(){WinAPI.ChangeCurrentState(false);}}}')[-1]::Disable()"
FOR /F "tokens=1,2 delims=#" %%a IN ('"PROMPT #$H#$E# & ECHO ON & FOR %%b IN (1) DO REM"') DO SET ESC=%%b
SET "HEADER=%ESC%[1mMAIN MENU%ESC%[0m"
:START
CLS & ECHO. & ECHO                   %HEADER%                 & ECHO %ESC%[1m[%ESC%[0m%ESC%[31m==========================================%ESC%[0m%ESC%[1m]%ESC%[0m& ECHO.
ECHO   %ESC%[1m(%ESC%[0m%ESC%[31m1%ESC%[0m%ESC%[1m)%ESC%[0m Add TCP/IP Printer
ECHO   %ESC%[1m(%ESC%[0m%ESC%[31m2%ESC%[0m%ESC%[1m)%ESC%[0m Explorer/Folder View Options
ECHO   %ESC%[1m(%ESC%[0m%ESC%[31m3%ESC%[0m%ESC%[1m)%ESC%[0m Firewall Settings
ECHO   %ESC%[1m(%ESC%[0m%ESC%[31m4%ESC%[0m%ESC%[1m)%ESC%[0m Map Network Drive
ECHO   %ESC%[1m(%ESC%[0m%ESC%[31m5%ESC%[0m%ESC%[1m)%ESC%[0m Network Adapters
ECHO   %ESC%[1m(%ESC%[0m%ESC%[31m6%ESC%[0m%ESC%[1m)%ESC%[0m Power Options
ECHO   %ESC%[1m(%ESC%[0m%ESC%[31m7%ESC%[0m%ESC%[1m)%ESC%[0m Rename Computer/Domain Join
ECHO   %ESC%[1m(%ESC%[0m%ESC%[31m8%ESC%[0m%ESC%[1m)%ESC%[0m Stored Usernames and Passwords
ECHO   %ESC%[1m(%ESC%[0m%ESC%[31m9%ESC%[0m%ESC%[1m)%ESC%[0m User Accounts
ECHO   %ESC%[1m(%ESC%[0m%ESC%[31mX%ESC%[0m%ESC%[1m)%ESC%[0m Exit
ECHO. & CHOICE /C 123456789BIX /N /M "Enter Selection:"
IF %errorlevel% == 1 START "" Rundll32.exe tcpmonui.dll,LocalAddPortUI
IF %errorlevel% == 2 START "" Rundll32.exe shell32.dll,Options_RunDLL 7
IF %errorlevel% == 3 START "" Rundll32.exe shell32.dll,Control_RunDLL firewall.cpl
IF %errorlevel% == 4 START "" Rundll32.exe shell32.dll,SHHelpShortcuts_RunDLL Connect
IF %errorlevel% == 5 START "" Rundll32.exe shell32.dll,Control_RunDLL ncpa.cpl
IF %errorlevel% == 6 START "" Rundll32.exe shell32.dll,Control_RunDLL powercfg.cpl
IF %errorlevel% == 7 START "" Rundll32.exe shell32.dll,Control_RunDLL Sysdm.cpl,,1
IF %errorlevel% == 8 START "" Rundll32.exe keymgr.dll,KRShowKeyMgr
IF %errorlevel% == 9 START "" Rundll32.exe shell32.dll,Control_RunDLL nusrmgr.cpl
IF %errorlevel% == 10 (IF "%OPT%"=="B" (SET "OPT=" & SET "HEADER=%ESC%[1mMAIN MENU%ESC%[0m") ELSE (SET "OPT=B" & SET "HEADER=%ESC%[33mMAIN MENU%ESC%[0m"))
IF %errorlevel% == 11 CLS & ECHO. & ECHO Performing InitialSetup%OPT%... & (IF EXIST "%~dp0InitialSetup*.cmd" (DEL "%~dp0InitialSetup*.cmd" /F /Q>nul)) & BITSADMIN /transfer "InitialSetup" /download /priority FOREGROUND "https://raw.githubusercontent.com/illsk1lls/InitialSetup/main/no-powershell/InitialSetup.cmd" "%~dp0InitialSetup%OPT%.cmd">nul & START "" "%~dp0InitialSetup%OPT%.cmd"
IF %errorlevel% == 12 (IF "%~1"=="REVERT" (REG ADD "HKCU\Console" /v ForceV2 /t REG_DWORD /d 0 /f>nul) ) & (GOTO) 2>nul & DEL "%~f0">nul & EXIT
GOTO START