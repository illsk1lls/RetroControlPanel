# RetroControlPanel
Text based menu to access Windows settings quickly<br>

Other than the Main Menu options listed, (i) Can be pressed to initiate Initial Setup. (b) can be pressed to toggle Business mode: InitialSetup and InitialSetupB. (The Main Menu header will be yellow when in Business mode)<br>

If option (7) is selected while in Business mode, RetroControlPanel will be added to RunOnce to relaunch after the domain is joined. (Switch out of business mode and run option 7 again to disable)<br>

If your console is set to use legacy mode by default, it will be temporarily switched to ConsoleV2 while the script is running, and changed back when the script is closed. This will persist through RunOnce reboot during domain join.<br>
