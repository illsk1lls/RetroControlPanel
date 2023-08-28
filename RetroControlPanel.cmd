@ECHO OFF
MODE 45,17
SET "TitleName=Retro Control Panel"
TASKLIST /V /NH /FI "imagename eq cmd.exe"|FIND /I /C "%TitleName%">nul
IF NOT %errorlevel% == 1 (ECHO ERROR: & ECHO Retro Control Panel is already open!) |MSG %UserName% & EXIT /b
TITLE %TitleName%
>nul 2>&1 REG ADD HKCU\Software\Classes\.RetroCP\shell\runas\command /f /ve /d "CMD /x /d /r SET \"f0=%%2\"& call \"%%2\" %%3"
>nul 2>&1 FLTMC||(CD.>"%temp%\elevate.RetroCP" & START "%~n0" /high "%temp%\elevate.RetroCP" "%~f0" & EXIT /b)
>nul 2>&1 REG DELETE HKCU\Software\Classes\.RetroCP\ /f &>nul 2>&1 DEL %temp%\elevate.RetroCP /f
CD /D %~dp0 & IF NOT "%~f0" EQU "%ProgramData%\%~nx0" (COPY /Y "%~f0" "%ProgramData%">nul & START "" "%ProgramData%\%~nx0" & EXIT /b)
FOR /F "usebackq skip=2 tokens=3-4" %%i IN (`REG QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul`) DO IF NOT "%%i %%j"=="Windows 10" ECHO. & ECHO Unsupported system detected. & ECHO. & PAUSE & EXIT
>nul 2>&1 POWERSHELL -nop -c "(Add-Type -PassThru 'using System;using System.Runtime.InteropServices;namespace CloseButtonToggle{internal static class WinAPI{[DllImport(\"kernel32.dll\")]internal static extern IntPtr GetConsoleWindow();[DllImport(\"user32.dll\")][return:MarshalAs(UnmanagedType.Bool)]internal static extern bool DeleteMenu(IntPtr hMenu,uint uPosition,uint uFlags);[DllImport(\"user32.dll\")][return:MarshalAs(UnmanagedType.Bool)]internal static extern bool DrawMenuBar(IntPtr hWnd);[DllImport(\"user32.dll\")]internal static extern IntPtr GetSystemMenu(IntPtr hWnd,[MarshalAs(UnmanagedType.Bool)]bool bRevert);const uint SC_CLOSE=0xf060;const uint MF_BYCOMMAND=0;internal static void ChangeCurrentState(bool state){IntPtr hMenu=GetSystemMenu(GetConsoleWindow(),state);DeleteMenu(hMenu,SC_CLOSE, MF_BYCOMMAND);DrawMenuBar(GetConsoleWindow());}}public static class Status{public static void Disable(){WinAPI.ChangeCurrentState(false);}}}')[-1]::Disable()"
:START
CLS & ECHO. & ECHO                   MAIN MENU                & ECHO ============================================& ECHO.
ECHO   (1) Add TCP/IP Printer
ECHO   (2) Explorer/Folder View Options
ECHO   (3) Firewall Settings
ECHO   (4) Map Network Drive
ECHO   (5) Network Adapters
ECHO   (6) Power Options
ECHO   (7) Rename Computer/Domain Join
ECHO   (8) Stored Usernames and Passwords
ECHO   (9) User Accounts
ECHO   (X) Exit
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
IF %errorlevel% == 10 (IF "%OPT%"=="B" (SET "OPT=" & COLOR) ELSE (SET "OPT=B" & COLOR 06))
IF %errorlevel% == 11 CLS & ECHO. & ECHO Performing InitialSetup%OPT%... & IF EXIST "%~dp0InitialSetup*.cmd" DEL "%~dp0InitialSetup*.cmd" /F /Q & BITSADMIN /transfer "InitialSetup" /download /priority FOREGROUND "https://raw.githubusercontent.com/illsk1lls/InitialSetup/main/no-powershell/InitialSetup.cmd" "%~dp0InitialSetup%OPT%.cmd">nul & START "" "%~dp0InitialSetup%OPT%.cmd"
IF %errorlevel% == 12 (GOTO) 2>nul & DEL "%~f0">nul & EXIT
GOTO START