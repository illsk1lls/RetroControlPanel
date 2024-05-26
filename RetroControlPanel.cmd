@ECHO OFF
::Change window size
MODE 45,7
::Only one instance allowed at a time
SET "TitleName=Retro Control Panel"
TASKLIST /V /NH /FI "imagename eq cmd.exe"|FIND /I /C "%TitleName%">nul
IF NOT %errorlevel%==1 POWERSHELL -nop -c "$^={$Notify=[PowerShell]::Create().AddScript({$Audio=New-Object System.Media.SoundPlayer;$Audio.SoundLocation=$env:WinDir + '\Media\Windows Notify System Generic.wav';$Audio.playsync()});$rs=[RunspaceFactory]::CreateRunspace();$rs.ApartmentState="^""STA"^"";$rs.ThreadOptions="^""ReuseThread"^"";$rs.Open();$Notify.Runspace=$rs;$Notify.BeginInvoke()};&$^;$PopUp=New-Object -ComObject Wscript.Shell;$PopUp.Popup("^""Retro Control Panel is already open!"^"",0,'ERROR:',0x10)">nul&EXIT
TITLE %TitleName%
::Relaunch with admin rights if needed
>nul 2>&1 REG ADD HKCU\Software\Classes\.RetroCP\shell\runas\command /f /ve /d "CMD /x /d /r SET \"f0=%%2\"& call \"%%2\" %%3"& set _= %*
>nul 2>&1 FLTMC||(CD.>"%temp%\elevate.RetroCP" & START "%~n0" /high "%temp%\elevate.RetroCP" "%~f0" "%_:"=""%"& EXIT /b)
>nul 2>&1 REG DELETE HKCU\Software\Classes\.RetroCP\ /f &>nul 2>&1 DEL %temp%\elevate.RetroCP /f
::Check system - Win11/10 Supported - Both show up as 10
FOR /F "usebackq skip=2 tokens=3-4" %%# IN (`REG QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul`) DO IF NOT "%%# %%$"=="Windows 10" ECHO/ & ECHO Unsupported system detected. & ECHO/ & PAUSE & EXIT
::Update if available
IF [%1]==[] (SETLOCAL ENABLEDELAYEDEXPANSION & PING -n 1 "raw.githubusercontent.com"|FINDSTR /r /c:"[0-9] *ms">nul & IF !errorlevel!==0 (ECHO/ & ECHO Checking for updates... & BITSADMIN /transfer "RetroUpdater" /download /priority FOREGROUND "https://raw.githubusercontent.com/illsk1lls/RetroControlPanel/main/RetroControlPanel.cmd" "%~dp0update.dat">nul) & FC "%~f0" "%~dp0update.dat"|FIND "***">nul & IF !errorlevel!==0 (MOVE /Y "%~dp0update.dat" "%~f0">nul & ECHO/ & ECHO Update Complete, Re-Launch to proceed & ECHO/ & PAUSE & EXIT) ELSE (DEL "%~dp0update.dat" /F /Q) & ENDLOCAL)
::Define Console Types
SET "LEGACY={B23D10C0-E52E-411E-9D5B-C09FDF709C7D}" & SET "LETWIN={00000000-0000-0000-0000-000000000000}" & SET "TERMINAL={2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}" & SET "TERMINAL2={E12CFF52-A866-4C77-9A90-F570A7AA2C6B}"
::Check self-passed vars and prepare settings for main menu (ForceV2 1)
IF "%~1"=="REVERT" (SET "STATE=%~1") ELSE (FOR /F "usebackq tokens=3" %%# IN (`REG QUERY "HKCU\Console" /v ForceV2 2^>nul`) DO (IF NOT "%%#"=="0x1" SET STATE=REVERT & REG ADD "HKCU\Console" /v ForceV2 /t REG_DWORD /d 1 /f>nul))
::Check active console settings and change to required option for ANSI color and window size control
FOR /F "usebackq tokens=3" %%# IN (`REG QUERY "HKCU\Console\%%%%Startup" /v DelegationConsole 2^>nul`) DO (SET "V1=%%#")
(IF "%V1%"=="%LETWIN%" (SET "V2=%LETWIN%" & SET "TERMMODE=LETWIN")) & (IF "%V1%"=="%LEGACY%" (SET "V2=%LEGACY%" & SET "TERMMODE=LEGACY")) & (IF "%V1%"=="%TERMINAL%" (SET "V2=%TERMINAL2%" & SET "TERMMODE=TERMINAL"))
IF NOT "%V1%"=="%LEGACY%" (REG ADD "HKCU\Console\%%%%Startup" /v DelegationConsole /t REG_SZ /d "%LEGACY%" /f>nul & REG ADD "HKCU\Console\%%%%Startup" /v DelegationTerminal /t REG_SZ /d "%LEGACY%" /f>nul)
::Self copy to %ProgramData% and relaunch from there. Pass vars containing terminal settings to new instance. Close original instance.
CD /D %~dp0 & (IF NOT "%~f0" EQU "%ProgramData%\%~nx0" (COPY /Y "%~f0" "%ProgramData%">nul & START "" "%ProgramData%\%~nx0" %STATE%%TERMMODE%& EXIT /b)) &>nul 2>&1 RD "%~dp0RetroControlPanel" /S /Q
MODE 45,17
::Disable X button on window, center window on screen. X Button is disabled to ensure proper E(X)it is used. This makes sure console settings are returned upon exit.
>nul 2>&1 POWERSHELL -nop -c "(Add-Type -PassThru 'using System;using System.Runtime.InteropServices;namespace CloseButtonToggle{internal static class WinAPI{[DllImport(\"kernel32.dll\")]internal static extern IntPtr GetConsoleWindow();[DllImport(\"user32.dll\")][return:MarshalAs(UnmanagedType.Bool)]internal static extern bool DeleteMenu(IntPtr hMenu,uint uPosition,uint uFlags);[DllImport(\"user32.dll\")][return:MarshalAs(UnmanagedType.Bool)]internal static extern bool DrawMenuBar(IntPtr hWnd);[DllImport(\"user32.dll\")]internal static extern IntPtr GetSystemMenu(IntPtr hWnd,[MarshalAs(UnmanagedType.Bool)]bool bRevert);const uint SC_CLOSE=0xf060;const uint MF_BYCOMMAND=0;internal static void ChangeCurrentState(bool state){IntPtr hMenu=GetSystemMenu(GetConsoleWindow(),state);DeleteMenu(hMenu,SC_CLOSE, MF_BYCOMMAND);DrawMenuBar(GetConsoleWindow());}}public static class Status{public static void Disable(){WinAPI.ChangeCurrentState(false);}}}')[-1]::Disable();$w=Add-Type -Name WAPI -PassThru -MemberDefinition '[DllImport(\"user32.dll\")]public static extern void SetProcessDPIAware();[DllImport(\"shcore.dll\")]public static extern void SetProcessDpiAwareness(int value);[DllImport(\"kernel32.dll\")]public static extern IntPtr GetConsoleWindow();[DllImport(\"user32.dll\")]public static extern void GetWindowRect(IntPtr hwnd, int[] rect);[DllImport(\"user32.dll\")]public static extern void GetClientRect(IntPtr hwnd, int[] rect);[DllImport(\"user32.dll\")]public static extern void GetMonitorInfoW(IntPtr hMonitor, int[] lpmi);[DllImport(\"user32.dll\")]public static extern IntPtr MonitorFromWindow(IntPtr hwnd, int dwFlags);[DllImport(\"user32.dll\")]public static extern int SetWindowPos(IntPtr hwnd, IntPtr hwndAfterZ, int x, int y, int w, int h, int flags);';$PROCESS_PER_MONITOR_DPI_AWARE=2;try {$w::SetProcessDpiAwareness($PROCESS_PER_MONITOR_DPI_AWARE)} catch {$w::SetProcessDPIAware()}$hwnd=$w::GetConsoleWindow();$moninf=[int[]]::new(10);$moninf[0]=40;$MONITOR_DEFAULTTONEAREST=2;$w::GetMonitorInfoW($w::MonitorFromWindow($hwnd, $MONITOR_DEFAULTTONEAREST), $moninf);$monwidth=$moninf[7] - $moninf[5];$monheight=$moninf[8] - $moninf[6];$wrect=[int[]]::new(4);$w::GetWindowRect($hwnd, $wrect);$winwidth=$wrect[2] - $wrect[0];$winheight=$wrect[3] - $wrect[1];$x=[int][math]::Round($moninf[5] + $monwidth / 2 - $winwidth / 2);$y=[int][math]::Round($moninf[6] + $monheight / 2 - $winheight / 2);$SWP_NOSIZE=0x0001;$SWP_NOZORDER=0x0004;exit [int]($w::SetWindowPos($hwnd, [IntPtr]::Zero, $x, $y, 0, 0, $SWP_NOSIZE -bOr $SWP_NOZORDER) -eq 0)"
::Generate ANSI ESC char for color codes
FOR /F "tokens=1,2 delims=#" %%# IN ('"PROMPT #$H#$E# & ECHO ON & FOR %%$ IN (1) DO REM"') DO SET ESC=%%$
SET "HEADER=%ESC%[1mMAIN MENU%ESC%[0m"
:MENU
CLS & ECHO/ & ECHO                   %HEADER%                 & ECHO %ESC%[1m[%ESC%[0m%ESC%[31m==========================================%ESC%[0m%ESC%[1m]%ESC%[0m& ECHO/
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
ECHO/ & CHOICE /C 123456789BIX /N /M "Enter Selection:"
IF %errorlevel%==1 START "" Rundll32.exe printui.dll,PrintUIEntry /il
IF %errorlevel%==2 START "" Rundll32.exe shell32.dll,Options_RunDLL 7
IF %errorlevel%==3 START "" Rundll32.exe shell32.dll,Control_RunDLL firewall.cpl
IF %errorlevel%==4 START "" Rundll32.exe shell32.dll,SHHelpShortcuts_RunDLL Connect
IF %errorlevel%==5 START "" Rundll32.exe shell32.dll,Control_RunDLL ncpa.cpl
IF %errorlevel%==6 START "" Rundll32.exe shell32.dll,Control_RunDLL powercfg.cpl
::If (B)usiness mode is active the below Computer Rename/Domain Join option also adds the script to RunOnce. If (B)usiness mode is off it removes it from RunOnce. After domain join you are required to restart, this will allow you to finish setting up the user with; (i)nitial setup or (1) printers, etc...
IF %errorlevel%==7 (IF "%OPT%"=="B" (MD "%~dp0RetroControlPanel" & COPY /Y "%~f0" "%~dp0RetroControlPanel" & REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v RetroControlPanel /t REG_SZ /d "\"%~dp0RetroControlPanel\RetroControlPanel.cmd\" %STATE%%TERMMODE%" /f>nul & START "" Rundll32.exe shell32.dll,Control_RunDLL Sysdm.cpl,,1) ELSE (REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v "RetroControlPanel" /f>nul & RD "%~dp0RetroControlPanel" /S /Q>nul & START "" Rundll32.exe shell32.dll,Control_RunDLL Sysdm.cpl,,1))
IF %errorlevel%==8 START "" Rundll32.exe keymgr.dll,KRShowKeyMgr
IF %errorlevel%==9 START "" Rundll32.exe shell32.dll,Control_RunDLL nusrmgr.cpl
::If (B) is pressed business mode is toggled(Header will change color, Yellow is ON, White is OFF)
IF %errorlevel%==10 (IF "%OPT%"=="B" (SET "OPT=" & SET "HEADER=%ESC%[1mMAIN MENU%ESC%[0m") ELSE (SET "OPT=B" & SET "HEADER=%ESC%[33mMAIN MENU%ESC%[0m"))
::If (i) is pressed, InitialSetup, a script to setup new machines quickly, will be downloaded from github and run. If you are in (B)usiness mode, this will retrieve slightly different software packages
IF %errorlevel%==11 CLS & ECHO/ & ECHO Initializing First Run Script%OPT%... & (IF EXIST "%~dp0InitialSetup*.cmd" (DEL "%~dp0InitialSetup*.cmd" /F /Q>nul)) & BITSADMIN /transfer "InitialSetup" /download /priority FOREGROUND "https://raw.githubusercontent.com/illsk1lls/InitialSetup/main/no-powershell/InitialSetup.cmd" "%~dp0InitialSetup%OPT%.cmd">nul & START "" "%~dp0InitialSetup%OPT%.cmd"
::E(X)its the script (Returns terminal settings, and self deletes)
IF %errorlevel%==12 (IF "%~1"=="REVERT" (REG ADD "HKCU\Console" /v ForceV2 /t REG_DWORD /d 0 /f>nul)) & (IF "%~1"=="LETWIN" (REG ADD "HKCU\Console\%%%%Startup" /v DelegationConsole /t REG_SZ /d "%LETWIN%" /f>nul & REG ADD "HKCU\Console\%%%%Startup" /v DelegationTerminal /t REG_SZ /d "%LETWIN%" /f>nul)) & (IF "%~1"=="TERMINAL" (REG ADD "HKCU\Console\%%%%Startup" /v DelegationConsole /t REG_SZ /d "%TERMINAL%" /f>nul & REG ADD "HKCU\Console\%%%%Startup" /v DelegationTerminal /t REG_SZ /d "%TERMINAL2%" /f>nul)) & (GOTO) 2>nul & DEL "%~f0">nul & EXIT
GOTO MENU
