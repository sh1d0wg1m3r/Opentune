@echo off
REM Description: Disables various non-telemetry Windows Services and Scheduled Tasks often considered unnecessary for standard desktop use or for performance optimization. This includes services for printing, fax, remote access, Bluetooth, Xbox, search indexing, and specific application update tasks. Disabling services WILL break their corresponding features.
REM Risk: Medium - Disabling services WILL prevent associated features (like printing, Bluetooth, search indexing, remote desktop, Xbox features) from working. Only proceed if you are certain you do not need these features. Reverting may be necessary if functionality is lost.
REM RevertInfo: Use the corresponding revert script (revert_optimize_services_tasks(combined).bat), System Restore, or manually re-enable required services via services.msc and tasks via Task Scheduler (taskschd.msc).

echo Applying Combined Service and Scheduled Task Optimizations...
echo =====================================================================
echo WARNING: This script disables services needed for features like Printing,
echo          Bluetooth, Search Indexing, Remote Desktop, Xbox, Fax, etc.
echo          PROCEED ONLY IF YOU DO NOT NEED THESE FEATURES.
echo =====================================================================
echo.
pause

echo [INFO] Disabling Selected Non-Essential Windows Services...

REM --- Services often safe to disable if features aren't used ---
sc config "Fax" start=disabled >nul 2>&1 & sc stop "Fax" >nul 2>&1
sc config "Spooler" start=disabled >nul 2>&1 & sc stop "Spooler" >nul 2>&1 REM Print Spooler
sc config "RemoteRegistry" start=disabled >nul 2>&1 & sc stop "RemoteRegistry" >nul 2>&1
sc config "TrkWks" start=disabled >nul 2>&1 & sc stop "TrkWks" >nul 2>&1 REM Distributed Link Tracking Client
sc config "WMPNetworkSvc" start=disabled >nul 2>&1 & sc stop "WMPNetworkSvc" >nul 2>&1 REM WMP Network Sharing
sc config "workfolderssvc" start=disabled >nul 2>&1 & sc stop "workfolderssvc" >nul 2>&1 REM Work Folders
sc config "AJRouter" start=disabled >nul 2>&1 & sc stop "AJRouter" >nul 2>&1 REM AllJoyn Router Service
sc config "MapsBroker" start=disabled >nul 2>&1 & sc stop "MapsBroker" >nul 2>&1 REM Downloaded Maps Manager
sc config "WpcMonSvc" start=disabled >nul 2>&1 & sc stop "WpcMonSvc" >nul 2>&1 REM Parental Controls
sc config "WbioSrvc" start=disabled >nul 2>&1 & sc stop "WbioSrvc" >nul 2>&1 REM Windows Biometric Service
sc config "TabletInputService" start=disabled >nul 2>&1 & sc stop "TabletInputService" >nul 2>&1 REM Touch Keyboard and Handwriting Panel Service
sc config "CDPSvc" start=disabled >nul 2>&1 & sc stop "CDPSvc" >nul 2>&1 REM Connected Devices Platform Service
sc config "PhoneSvc" start=disabled >nul 2>&1 & sc stop "PhoneSvc" >nul 2>&1 REM Phone Service

REM --- Bluetooth Services (Disable if Bluetooth hardware/devices are not used) ---
sc config "BthServ" start=disabled >nul 2>&1 & sc stop "BthServ" >nul 2>&1
sc config "bthhfsrv" start=disabled >nul 2>&1 & sc stop "bthhfsrv" >nul 2>&1
for /f "tokens=1 delims=" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services" ^| findstr /R /C:"BluetoothUserService_.*"') do (
    sc config "%%~na" start=disabled >nul 2>&1
    sc stop "%%~na" >nul 2>&1
)

REM --- Remote Desktop Services (Disable if Remote Desktop is not used) ---
sc config "TermService" start=disabled >nul 2>&1 & sc stop "TermService" >nul 2>&1 REM Remote Desktop Service
sc config "SessionEnv" start=disabled >nul 2>&1 & sc stop "SessionEnv" >nul 2>&1 REM Remote Desktop Configuration
sc config "UmRdpService" start=disabled >nul 2>&1 & sc stop "UmRdpService" >nul 2>&1 REM Remote Desktop Services Usermode Port Redirector

REM --- Xbox Services (Disable if Xbox App/Game Pass/features are not used) ---
sc config "XblAuthManager" start=disabled >nul 2>&1 & sc stop "XblAuthManager" >nul 2>&1
sc config "XboxNetApiSvc" start=disabled >nul 2>&1 & sc stop "XboxNetApiSvc" >nul 2>&1
sc config "XblGameSave" start=disabled >nul 2>&1 & sc stop "XblGameSave" >nul 2>&1
sc config "XboxGipSvc" start=disabled >nul 2>&1 & sc stop "XboxGipSvc" >nul 2>&1
sc config "GamingServices" start=disabled >nul 2>&1 & sc stop "GamingServices" >nul 2>&1
sc config "GamingServicesNet" start=disabled >nul 2>&1 & sc stop "GamingServicesNet" >nul 2>&1

REM --- Performance Impacting Services (Disable if functionality not needed) ---
sc config "WSearch" start=disabled >nul 2>&1 & sc stop "WSearch" >nul 2>&1 REM Windows Search (Indexing)

echo.
echo [INFO] Disabling Selected Non-Essential Scheduled Tasks...

REM --- File History / Work Folders Tasks ---
schtasks /Change /TN "\Microsoft\Windows\FileHistory\File History (maintenance mode)" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Work Folders\Work Folders Maintenance Work" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Work Folders\Work Folders Logon Synchronization" /DISABLE >nul 2>&1

REM --- Remote Assistance Task ---
schtasks /Change /TN "\Microsoft\Windows\RemoteAssistance\RemoteAssistanceTask" /DISABLE >nul 2>&1

REM --- Speech Related Tasks ---
schtasks /Change /TN "\Microsoft\Windows\Speech\SpeechModelDownloadTask" /DISABLE >nul 2>&1

REM --- Xbox Related Tasks ---
schtasks /Change /TN "\Microsoft\XblGameSave\XblGameSaveTask" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\XblGameSave\XblGameSaveTaskLogon" /DISABLE >nul 2>&1

REM --- Application Updater Tasks (Common Examples) ---
schtasks /Change /TN "\GoogleUpdateTaskMachineCore" /DISABLE >nul 2>&1
schtasks /Change /TN "\GoogleUpdateTaskMachineUA" /DISABLE >nul 2>&1
schtasks /Change /TN "\MicrosoftEdgeUpdateTaskMachineCore" /DISABLE >nul 2>&1
schtasks /Change /TN "\MicrosoftEdgeUpdateTaskMachineUA" /DISABLE >nul 2>&1
schtasks /Change /TN "\Adobe Acrobat Update Task" /DISABLE >nul 2>&1
schtasks /Change /TN "\AdobeGCInvoker-1.0" /DISABLE >nul 2>&1 REM Adobe GC Invoker Utility
schtasks /Change /TN "\CCleaner Update" /DISABLE >nul 2>&1
schtasks /Change /TN "\CCleanerSkipUAC" /DISABLE >nul 2>&1

echo.
echo Combined Service and Task optimizations applied.
echo Remember that disabled services mean lost functionality (Printing, Bluetooth, Search etc.).
echo A RESTART is recommended for changes to fully apply.
echo.
pause
exit /b 0