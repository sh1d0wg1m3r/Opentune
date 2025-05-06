@echo off
setlocal enabledelayedexpansion

REM Description: Reverts privacy and telemetry optimizations. Attempts to re-enable services, scheduled tasks, restore default registry settings, and MOST IMPORTANTLY, restores the original hosts file from the backup created by the optimizer.
REM Risk: Medium - Success depends heavily on restoring the hosts file backup correctly. If the backup is missing, manual hosts file cleaning or System Restore may be required. Re-enabling services/registry keys is generally safe.
REM RevertInfo: Restores default settings where possible. Always prioritize using System Restore if available. Check hosts file manually if network issues occur after running.

echo Reverting Combined Privacy and Telemetry Optimizations...
echo This may take a moment. Please wait...
echo.

REM --- CRITICAL: Restore Hosts File from Backup ---
set HOSTS_DIR=%WINDIR%\System32\drivers\etc
set HOSTS_FILE=%HOSTS_DIR%\hosts
set BACKUP_PATTERN=hosts.opentune-backup-*
set FOUND_BACKUP=

echo [CRITICAL] Attempting to restore hosts file from backup...
pushd "%HOSTS_DIR%" >nul 2>&1
for /f "delims=" %%f in ('dir "%BACKUP_PATTERN%" /b /o:-d 2^>nul') do (
    if not defined FOUND_BACKUP (
        set FOUND_BACKUP=%%f
        echo    Found latest backup: !FOUND_BACKUP!
    )
)
popd >nul 2>&1

if defined FOUND_BACKUP (
    echo    Restoring !FOUND_BACKUP!...
    attrib -r "%HOSTS_FILE%" >nul 2>&1
    del "%HOSTS_FILE%" >nul 2>&1
    ren "%HOSTS_DIR%\!FOUND_BACKUP!" hosts >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed to rename backup file !FOUND_BACKUP! to hosts. Manual restore may be needed from %HOSTS_DIR%.
    ) else (
        echo    Hosts file successfully restored from !FOUND_BACKUP!.
    )
) else (
    echo [WARNING] No Opentune hosts file backup (hosts.opentune-backup-*) found in %HOSTS_DIR%.
    echo           Cannot automatically restore hosts file. Check for backups manually.
    echo           If you have network issues, you may need to manually edit the hosts file or use System Restore.
)
echo.

REM --- Re-enable Telemetry & Diagnostic Services ---
echo [INFO] Re-enabling Telemetry and Diagnostic Services to defaults...
sc config "DiagTrack" start=auto >nul 2>&1
sc config "dmwappushservice" start=auto >nul 2>&1
sc config "diagnosticshub.standardcollector.service" start=demand >nul 2>&1
sc config "PcaSvc" start=auto >nul 2>&1
sc config "WerSvc" start=demand >nul 2>&1
sc start "DiagTrack" >nul 2>&1
sc start "dmwappushservice" >nul 2>&1
sc start "diagnosticshub.standardcollector.service" >nul 2>&1
sc start "PcaSvc" >nul 2>&1
sc start "WerSvc" >nul 2>&1
echo.

REM --- Re-enable Telemetry Related Scheduled Tasks ---
echo [INFO] Re-enabling Telemetry Related Scheduled Tasks...
schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /ENABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /ENABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\StartupAppTask" /ENABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /ENABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /ENABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /ENABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Uploader" /ENABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /ENABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Feedback\Siuf\DmClient" /ENABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" /ENABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\PI\Sqm-Tasks" /ENABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Autochk\Proxy" /ENABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Diagnosis\Scheduled" /ENABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Maintenance\WinSAT" /ENABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\SettingSync\NetworkStateChangeTask" /ENABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\SettingSync\BackgroundUploadTask" /ENABLE >nul 2>&1
:: Office Telemetry Tasks
schtasks /Change /TN "\Microsoft\Office\OfficeTelemetryAgentLogOn" /ENABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Office\OfficeTelemetryAgentFallBack" /ENABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Office\Office ClickToRun Service Monitor" /ENABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Office\Office Feature Updates" /ENABLE >nul 2>&1
echo.

REM --- Revert Core Telemetry & Data Collection Registry Settings ---
echo [INFO] Reverting core Telemetry & Data Collection registry settings...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 1 /f >nul 2>&1 REM Set to Basic=1, could be 3=Full depending on original setting
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "LimitEnhancedDiagnosticDataWindowsAnalytics" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowDeviceNameInTelemetry" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /f >nul 2>&1
echo.

REM --- Re-enable Privacy-Related Features (Advertising ID, Activity, Input, etc.) ---
echo [INFO] Re-enabling Advertising ID, Activity History, Input Personalization...
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableActivityFeed" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d 0 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableWindowsLocationProvider" /t REG_DWORD /d 0 /f >nul 2>&1
reg delete "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /f >nul 2>&1
echo.

REM --- Re-enable Windows Error Reporting ---
echo [INFO] Re-enabling Windows Error Reporting features...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "DontSendAdditionalData" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PCHealth\ErrorReporting" /v "DoReport" /t REG_DWORD /d 1 /f >nul 2>&1
echo.

REM --- Re-enable Cortana ---
echo [INFO] Re-enabling Cortana (Registry settings only)...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 2 /f >nul 2>&1 REM Set back to full search box
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaConsent" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo [INFO] Note: Cortana App Package cannot be reliably reinstalled via script. Use Windows settings or Store if needed.
echo.

REM --- Re-enable Defender Telemetry (SpyNet/MAPS) ---
echo [INFO] Re-enabling Windows Defender telemetry (SpyNet/MAPS) to defaults...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpynetReporting" /t REG_DWORD /d 1 /f >nul 2>&1 REM Basic reporting
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d 1 /f >nul 2>&1 REM Send safe samples
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "DisableGenericReports" /t REG_DWORD /d 0 /f >nul 2>&1
echo.

REM --- Re-enable Autologgers ---
echo [INFO] Re-enabling WMI Autologgers...
set "Autologgers=AppModel Cellcore Circular Kernel Context Logger CloudExperienceHostOobe DataMarket DefenderApiLogger DefenderAuditLogger DiagLog HolographicDevice LwtNetLog Microsoft-Windows-AssignedAccess-Trace Microsoft-Windows-Setup NBSMBLOGGER PEAuthLog RdrLog ReadyBoot SetupPlatform SetupPlatformTel SocketHeciServer SpoolerLogger SQMLogger TCPIPLOGGER TileStore Tpm TPMProvisioningService UBPM WdiContextLog WFP-IPsec Trace WiFiDriverIHVSession WiFiSession"
for %%L in (%Autologgers%) do (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\%%L" /v "Start" /t REG_DWORD /d 1 /f >nul 2>&1
)
echo.

REM --- Flush DNS Cache ---
echo [INFO] Flushing DNS cache...
ipconfig /flushdns >nul

echo.
echo Privacy and Telemetry settings reverted successfully.
echo ** MANUAL CHECK of the hosts file (%HOSTS_FILE%) is recommended if network issues occur. **
echo Please RESTART your computer for all changes to take effect.
echo.
pause
exit /b 0