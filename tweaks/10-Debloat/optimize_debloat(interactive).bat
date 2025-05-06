@echo off
setlocal enabledelayedexpansion

REM Description: Interactively removes selected categories of built-in Windows apps and optional features often considered bloatware (e.g., General UWP apps, 3D apps, Xbox apps, OneDrive, IE11, WMP). Uses PowerShell and DISM.
REM Risk: Medium - Removing apps/features is generally irreversible via script and removes functionality. Ensure you don't need the selected components before proceeding. Errors during removal are possible. System Restore point is recommended.
REM RevertInfo: App removal is largely permanent. Some apps may be reinstallable via Microsoft Store. Features can be re-enabled via DISM ('DISM /Online /Enable-Feature'). OneDrive requires manual download/reinstall. A System Restore point is the most reliable way to revert.

echo ============================================================================
echo                       WINDOWS DEBLOAT SCRIPT
echo ============================================================================
echo This script will PERMANENTLY remove selected built-in Windows Apps and Features.
echo Review each category carefully. Removal means losing the functionality
echo provided by these apps/features. This process cannot be easily undone.
echo ============================================================================
echo.
echo It is STRONGLY recommended to create a System Restore point before continuing.
echo.

:MENU
cls
echo Please choose which categories of Apps/Features to remove:
echo ----------------------------------------------------------
echo [1] General UWP Apps (Weather, News, Maps, Alarms, Camera, Office Hub, People, etc.)
echo [2] 3D Related Apps (3D Viewer, Print 3D, Mixed Reality Portal)
echo [3] Xbox / Gaming Apps (Xbox App, Game Bar Overlay, Identity Provider - Excludes Services)
echo [4] OneDrive (Full removal attempt)
echo [5] Optional Windows Features (Internet Explorer 11, Media Player, Work Folders)
echo ----------------------------------------------------------
echo [A] ALL of the above (Use with caution!)
echo [S] SKIP Debloat / Exit
echo ----------------------------------------------------------
echo.

set "CHOICE="
set /p "CHOICE=Enter your choice (1-5, A, S): "

REM --- Set Flags Based on Choice ---
set DO_GENERAL=0
set DO_3D=0
set DO_XBOX=0
set DO_ONEDRIVE=0
set DO_FEATURES=0

if /I "%CHOICE%"=="1" set DO_GENERAL=1
if /I "%CHOICE%"=="2" set DO_3D=1
if /I "%CHOICE%"=="3" set DO_XBOX=1
if /I "%CHOICE%"=="4" set DO_ONEDRIVE=1
if /I "%CHOICE%"=="5" set DO_FEATURES=1
if /I "%CHOICE%"=="A" (
    set DO_GENERAL=1
    set DO_3D=1
    set DO_XBOX=1
    set DO_ONEDRIVE=1
    set DO_FEATURES=1
)
if /I "%CHOICE%"=="S" goto END_DEBLOAT

REM --- Validate Choice ---
if "%DO_GENERAL%%DO_3D%%DO_XBOX%%DO_ONEDRIVE%%DO_FEATURES%"=="00000" (
    echo Invalid choice. Please try again.
    timeout /t 2 /nobreak > nul
    goto MENU
)

echo.
echo Preparing to remove selected components... This may take some time.
echo Output from PowerShell/DISM will be suppressed unless errors occur.
echo.
pause

REM --- Execute Removal Sections Based on Flags ---

if "%DO_GENERAL%"=="1" call :REMOVE_GENERAL
if "%DO_3D%"=="1" call :REMOVE_3D
if "%DO_XBOX%"=="1" call :REMOVE_XBOX
if "%DO_ONEDRIVE%"=="1" call :REMOVE_ONEDRIVE
if "%DO_FEATURES%"=="1" call :REMOVE_FEATURES

goto FINAL_MESSAGE

REM --- Subroutines for Removal ---

:REMOVE_GENERAL
echo [INFO] Removing General UWP Apps...
set "GeneralApps=Microsoft.BingWeather Microsoft.GetHelp Microsoft.Getstarted Microsoft.Messaging Microsoft.MicrosoftOfficeHub Microsoft.MicrosoftSolitaireCollection Microsoft.Office.OneNote Microsoft.People Microsoft.WindowsAlarms Microsoft.WindowsCamera microsoft.windowscommunicationsapps Microsoft.WindowsFeedbackHub Microsoft.WindowsMaps Microsoft.WindowsSoundRecorder Microsoft.YourPhone Microsoft.ZuneMusic Microsoft.ZuneVideo Microsoft.HEIFImageExtension Microsoft.WebMediaExtensions Microsoft.WebpImageExtension MicrosoftStickyNotes CommsPhone WindowsReadingList Sway Clipchamp ScreenSketch WalletService"
for %%a in (%GeneralApps%) do (
    echo   Removing %%a...
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage -AllUsers *%%a* | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" > nul
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like '*%%a*'} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue" > nul
)
echo [INFO] General UWP Apps removal attempted.
echo.
goto:eof

:REMOVE_3D
echo [INFO] Removing 3D Related Apps...
set "3DApps=Microsoft.Microsoft3DViewer Microsoft.MixedReality.Portal Microsoft.Print3D Microsoft.3DBuilder"
for %%a in (%3DApps%) do (
    echo   Removing %%a...
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage -AllUsers *%%a* | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" > nul
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like '*%%a*'} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue" > nul
)
echo [INFO] 3D Related Apps removal attempted.
echo.
goto:eof

:REMOVE_XBOX
echo [INFO] Removing Xbox Related Apps (UI/Overlays)...
set "XboxApps=Microsoft.XboxApp Microsoft.XboxGamingOverlay Microsoft.XboxGameOverlay Microsoft.XboxSpeechToTextOverlay Microsoft.XboxIdentityProvider"
for %%a in (%XboxApps%) do (
    echo   Removing %%a...
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage -AllUsers *%%a* | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" > nul
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like '*%%a*'} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue" > nul
)
echo [INFO] Xbox Related Apps removal attempted.
echo.
goto:eof

:REMOVE_ONEDRIVE
echo [INFO] Removing OneDrive...
taskkill /f /im OneDrive.exe >nul 2>&1
ping 127.0.0.1 -n 3 > nul REM Short delay

echo   Running OneDrive Uninstallers...
if exist "%SYSTEMROOT%\SysWOW64\OneDriveSetup.exe" "%SYSTEMROOT%\SysWOW64\OneDriveSetup.exe" /uninstall >nul 2>&1
if exist "%SYSTEMROOT%\System32\OneDriveSetup.exe" "%SYSTEMROOT%\System32\OneDriveSetup.exe" /uninstall >nul 2>&1
ping 127.0.0.1 -n 5 > nul REM Longer delay for uninstaller

echo   Removing OneDrive Folders...
rd "%UserProfile%\OneDrive" /q /s >nul 2>&1
rd "%LocalAppData%\Microsoft\OneDrive" /q /s >nul 2>&1
rd "%ProgramData%\Microsoft OneDrive" /q /s >nul 2>&1
rd "%SystemDrive%\OneDriveTemp" /q /s >nul 2>&1

echo   Removing OneDrive Registry Keys (Explorer Integration)...
reg delete "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f >nul 2>&1
reg delete "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f >nul 2>&1

echo [INFO] OneDrive removal attempted.
echo.
goto:eof

:REMOVE_FEATURES
echo [INFO] Disabling Optional Windows Features (IE11, WMP, Work Folders)...
echo   Disabling Internet Explorer 11...
DISM /Online /Disable-Feature /FeatureName:"Internet-Explorer-Optional-amd64" /NoRestart > nul
echo   Disabling Windows Media Player...
DISM /Online /Disable-Feature /FeatureName:"WindowsMediaPlayer" /NoRestart > nul
echo   Disabling Work Folders Client...
DISM /Online /Disable-Feature /FeatureName:"WorkFolders-Client" /NoRestart > nul
echo [INFO] Optional Windows Features disabling attempted. A restart is needed for DISM changes.
echo.
goto:eof

:FINAL_MESSAGE
echo ============================================================================
echo                        DEBLOAT PROCESS COMPLETE
echo ============================================================================
echo The selected Windows apps and features have been removed or disabled.
echo REMOVAL IS LARGELY PERMANENT. Reinstall apps from the Microsoft Store
echo or re-enable features via DISM if needed later.
echo.
echo A RESTART is recommended, especially if Optional Features were removed.
echo ============================================================================

:END_DEBLOAT
echo.
pause
exit /b 0