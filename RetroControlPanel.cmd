@ECHO OFF
TITLE Retro Control Panel
MODE 45,17
>nul 2>&1 REG ADD HKCU\Software\Classes\.RetroCP\shell\runas\command /f /ve /d "CMD /x /d /r SET \"f0=%%2\"& call \"%%2\" %%3"
>nul 2>&1 FLTMC||(CD.>"%temp%\elevate.RetroCP" & START "%~n0" /high "%temp%\elevate.RetroCP" "%~f0" & EXIT /b)
>nul 2>&1 REG DELETE HKCU\Software\Classes\.RetroCP\ /f &>nul 2>&1 DEL %temp%\elevate.RetroCP /f
CD /D %~dp0 & IF NOT "%~f0" EQU "%ProgramData%\%~nx0" (COPY /Y "%~f0" "%ProgramData%">nul & START "" "%ProgramData%\%~nx0" & EXIT /b)
POWERSHELL -nop -c "(Add-Type -PassThru 'using System;using System.Runtime.InteropServices;namespace CloseButtonToggle{internal static class WinAPI{[DllImport(\"kernel32.dll\")]internal static extern IntPtr GetConsoleWindow();[DllImport(\"user32.dll\")][return:MarshalAs(UnmanagedType.Bool)]internal static extern bool DeleteMenu(IntPtr hMenu,uint uPosition,uint uFlags);[DllImport(\"user32.dll\")][return:MarshalAs(UnmanagedType.Bool)]internal static extern bool DrawMenuBar(IntPtr hWnd);[DllImport(\"user32.dll\")]internal static extern IntPtr GetSystemMenu(IntPtr hWnd,[MarshalAs(UnmanagedType.Bool)]bool bRevert);const uint SC_CLOSE=0xf060;const uint MF_BYCOMMAND=0;internal static void ChangeCurrentState(bool state){IntPtr hMenu=GetSystemMenu(GetConsoleWindow(),state);DeleteMenu(hMenu,SC_CLOSE, MF_BYCOMMAND);DrawMenuBar(GetConsoleWindow());}}public static class Status{public static void Disable(){WinAPI.ChangeCurrentState(false);}}}')[-1]::Disable()"
:START
CLS & ECHO. & ECHO                   MAIN MENU & ECHO ============================================& ECHO.
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
ECHO. & CHOICE /C 123456789X /N /M "Enter Selection:"
IF %errorlevel% == 1 START "" Rundll32.exe tcpmonui.dll,LocalAddPortUI
IF %errorlevel% == 2 START "" Rundll32.exe shell32.dll,Options_RunDLL 7
IF %errorlevel% == 3 START "" Rundll32.exe shell32.dll,Control_RunDLL firewall.cpl
IF %errorlevel% == 4 START "" Rundll32.exe shell32.dll,SHHelpShortcuts_RunDLL Connect
IF %errorlevel% == 5 START "" Rundll32.exe shell32.dll,Control_RunDLL ncpa.cpl
IF %errorlevel% == 6 START "" Rundll32.exe shell32.dll,Control_RunDLL powercfg.cpl
IF %errorlevel% == 7 START "" Rundll32.exe shell32.dll,Control_RunDLL Sysdm.cpl,,1
IF %errorlevel% == 8 START "" Rundll32.exe keymgr.dll,KRShowKeyMgr
IF %errorlevel% == 9 START "" Rundll32.exe shell32.dll,Control_RunDLL nusrmgr.cpl
IF %errorlevel% == 10 (GOTO) 2>nul & DEL "%~f0">nul & EXIT
GOTO START