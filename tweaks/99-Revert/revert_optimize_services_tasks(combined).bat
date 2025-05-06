@echo off
REM Description: Reverts changes made by optimize_services_tasks(combined).bat. Re-enables services (like Print Spooler, Bluetooth, Search Indexing, Xbox, etc.) and scheduled tasks (like application updaters) by setting them back to their default startup types/states.
REM Risk: Low - Re-enabling default services and tasks is generally safe and restores functionality that might have been lost.
REM RevertInfo: Restores default service start types and re-enables specific scheduled tasks. Use services.msc or taskschd.msc for manual adjustments if needed.

echo Reverting Combined Service and Scheduled Task Optimizations to Defaults...
echo This may take a moment. Please wait...
echo.

echo [INFO] Re-enabling Selected Windows Services to Default Startup Types...

REM --- Services often safe to disable if features aren't used (Defaults: Mostly Demand or Auto) ---
sc config "Fax" start=demand >nul 2>&1
sc config "Spooler" start=auto >nul 2>&1 & sc start "Spooler" >nul 2>&1 REM Print Spooler
sc config "RemoteRegistry" start=demand >nul 2>&1 REM Default is often Disabled, but Demand is safer revert
sc config "TrkWks" start=auto >nul 2>&1 & sc start "TrkWks" >nul 2>&1 REM Distributed Link Tracking Client
sc config "WMPNetworkSvc" start=demand >nul 2>&1
sc config "workfolderssvc" start=demand >nul 2>&1
sc config "AJRouter" start=demand >nul 2>&1
sc config "MapsBroker" start=auto >nul 2>&1 & sc start "MapsBroker" >nul 2>&1
sc config "WpcMonSvc" start=auto >nul 2>&1 & sc start "WpcMonSvc" >nul 2>&1
sc config "WbioSrvc" start=demand >nul 2>&1
sc config "TabletInputService" start=auto >nul 2>&1 & sc start "TabletInputService" >nul 2>&1
sc config "CDPSvc" start=auto >nul 2>&1 & sc start "CDPSvc" >nul 2>&1
sc config "PhoneSvc" start=demand >nul 2>&1

REM --- Bluetooth Services (Default: Demand) ---
sc config "BthServ" start=demand >nul 2>&1
sc config "bthhfsrv" start=demand >nul 2>&1
for /f "tokens=1 delims=" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services" ^| findstr /R /C:"BluetoothUserService_.*"') do (
    sc config "%%~na" start=demand >nul 2>&1
)

REM --- Remote Desktop Services (Default: Demand) ---
sc config "TermService" start=demand >nul 2>&1
sc config "SessionEnv" start=demand >nul 2>&1
sc config "UmRdpService" start=demand >nul 2>&1

REM --- Xbox Services (Default: Demand) ---
sc config "XblAuthManager" start=demand >nul 2>&1
sc config "XboxNetApiSvc" start=demand >nul 2>&1
sc config "XblGameSave" start=demand >nul 2>&1
sc config "XboxGipSvc" start=demand >nul 2>&1
sc config "GamingServices" start=demand >nul 2>&1
sc config "GamingServicesNet" start=demand >nul 2>&1

REM --- Performance Impacting Services (Default: Auto Delayed) ---
sc config "WSearch" start=auto >nul 2>&1 & sc start "WSearch" >nul 2>&1

echo.
echo [INFO] Re-enabling Selected Scheduled Tasks...

REM --- File History / Work Folders Tasks ---
schtasks /Change /TN "\Microsoft\Windows\FileHistory\File History (maintenance mode)" /ENABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Work Folders\Work Folders Maintenance Work" /ENABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Work Folders\Work Folders Logon Synchronization" /ENABLE >nul 2>&1

REM --- Remote Assistance Task ---
schtasks /Change /TN "\Microsoft\Windows\RemoteAssistance\RemoteAssistanceTask" /ENABLE >nul 2>&1

REM --- Speech Related Tasks ---
schtasks /Change /TN "\Microsoft\Windows\Speech\SpeechModelDownloadTask" /ENABLE >nul 2>&1

REM --- Xbox Related Tasks ---
schtasks /Change /TN "\Microsoft\XblGameSave\XblGameSaveTask" /ENABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\XblGameSave\XblGameSaveTaskLogon" /ENABLE >nul 2>&1

REM --- Application Updater Tasks ---
schtasks /Change /TN "\GoogleUpdateTaskMachineCore" /ENABLE >nul 2>&1
schtasks /Change /TN "\GoogleUpdateTaskMachineUA" /ENABLE >nul 2>&1
schtasks /Change /TN "\MicrosoftEdgeUpdateTaskMachineCore" /ENABLE >nul 2>&1
schtasks /Change /TN "\MicrosoftEdgeUpdateTaskMachineUA" /ENABLE >nul 2>&1
schtasks /Change /TN "\Adobe Acrobat Update Task" /ENABLE >nul 2>&1
schtasks /Change /TN "\AdobeGCInvoker-1.0" /ENABLE >nul 2>&1
schtasks /Change /TN "\CCleaner Update" /ENABLE >nul 2>&1
schtasks /Change /TN "\CCleanerSkipUAC" /ENABLE >nul 2>&1

echo.
echo Services and Tasks reverted to default states successfully.
echo A RESTART is recommended for changes to fully apply.
echo Functionality related to Printing, Bluetooth, Search, etc., should now be restored.
echo.
pause
exit /b 0