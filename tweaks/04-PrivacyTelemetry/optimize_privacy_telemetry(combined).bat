@echo off
setlocal enabledelayedexpansion

REM Description: Disables extensive Windows telemetry, data collection, diagnostics, feedback, advertising ID, activity history, and Cortana features. Blocks many known Microsoft telemetry domains via the hosts file. Aims to significantly enhance user privacy.
REM Risk: Medium - Disabling services or blocking domains might interfere with Windows Update, Store, activation, or other MS services if not carefully managed. Incorrect hosts file modification can break connectivity. Use with caution and ensure you have backups/restore points.
REM RevertInfo: Use the corresponding revert script (revert_optimize_privacy_telemetry(combined).bat), which restores default registry/service/task settings AND crucially restores the original hosts file from backup. System Restore is recommended.

echo Applying Combined Privacy and Telemetry Optimizations...
echo This may take a moment. Please wait...
echo.

REM --- Disable Telemetry & Diagnostic Services ---
echo [INFO] Disabling Telemetry and Diagnostic Services...
sc config "DiagTrack" start=disabled >nul 2>&1
sc config "dmwappushservice" start=disabled >nul 2>&1
sc config "diagnosticshub.standardcollector.service" start=disabled >nul 2>&1
sc config "PcaSvc" start=disabled >nul 2>&1  REM Program Compatibility Assistant Service
sc config "WerSvc" start=disabled >nul 2>&1   REM Windows Error Reporting Service
sc stop "DiagTrack" >nul 2>&1
sc stop "dmwappushservice" >nul 2>&1
sc stop "diagnosticshub.standardcollector.service" >nul 2>&1
sc stop "PcaSvc" >nul 2>&1
sc stop "WerSvc" >nul 2>&1
echo.

REM --- Disable Telemetry Related Scheduled Tasks ---
echo [INFO] Disabling Telemetry Related Scheduled Tasks...
schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\StartupAppTask" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Uploader" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Feedback\Siuf\DmClient" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\PI\Sqm-Tasks" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Autochk\Proxy" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Diagnosis\Scheduled" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Maintenance\WinSAT" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\SettingSync\NetworkStateChangeTask" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\SettingSync\BackgroundUploadTask" /DISABLE >nul 2>&1
:: Office Telemetry Tasks (if applicable)
schtasks /Change /TN "\Microsoft\Office\OfficeTelemetryAgentLogOn" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Office\OfficeTelemetryAgentFallBack" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Office\Office ClickToRun Service Monitor" /DISABLE >nul 2>&1
schtasks /Change /TN "\Microsoft\Office\Office Feature Updates" /DISABLE >nul 2>&1
echo.

REM --- Apply Core Telemetry & Data Collection Registry Settings ---
echo [INFO] Applying core Telemetry & Data Collection registry settings...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "LimitEnhancedDiagnosticDataWindowsAnalytics" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowDeviceNameInTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /t REG_DWORD /d 1 /f >nul 2>&1
echo.

REM --- Disable Privacy-Related Features (Advertising ID, Activity, Input, etc.) ---
echo [INFO] Disabling Advertising ID, Activity History, Input Personalization...
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableActivityFeed" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableWindowsLocationProvider" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t REG_DWORD /d 1 /f >nul 2>&1
echo.

REM --- Disable Windows Error Reporting ---
echo [INFO] Disabling Windows Error Reporting features...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "DontSendAdditionalData" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PCHealth\ErrorReporting" /v "DoReport" /t REG_DWORD /d 0 /f >nul 2>&1
echo.

REM --- Disable Cortana ---
echo [INFO] Disabling Cortana...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 1 /f >nul 2>&1 REM Set to icon only
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaConsent" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1 REM Disable typing suggestions based on Cortana learning
echo [INFO] Attempting to remove Cortana App Package (may not work on all versions)...
PowerShell -Command "Get-AppxPackage -AllUsers *Microsoft.549981C3F5F10* | Remove-AppxPackage" >nul 2>&1
PowerShell -Command "Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like '*Microsoft.549981C3F5F10*'} | Remove-AppxProvisionedPackage -Online" >nul 2>&1
echo.

REM --- Disable Defender Telemetry (SpyNet/MAPS) ---
echo [INFO] Disabling Windows Defender telemetry (SpyNet/MAPS)...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpynetReporting" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d 2 /f >nul 2>&1 REM Set to Never Send
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "DisableGenericReports" /t REG_DWORD /d 1 /f >nul 2>&1
echo.

REM --- Disable Autologgers ---
echo [INFO] Disabling various WMI Autologgers...
set "Autologgers=AppModel Cellcore Circular Kernel Context Logger CloudExperienceHostOobe DataMarket DefenderApiLogger DefenderAuditLogger DiagLog HolographicDevice LwtNetLog Microsoft-Windows-AssignedAccess-Trace Microsoft-Windows-Setup NBSMBLOGGER PEAuthLog RdrLog ReadyBoot SetupPlatform SetupPlatformTel SocketHeciServer SpoolerLogger SQMLogger TCPIPLOGGER TileStore Tpm TPMProvisioningService UBPM WdiContextLog WFP-IPsec Trace WiFiDriverIHVSession WiFiSession"
for %%L in (%Autologgers%) do (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\%%L" /v "Start" /t REG_DWORD /d 0 /f >nul 2>&1
)
echo.

REM --- Block Telemetry Domains via Hosts File ---
set HOSTS_FILE=%WINDIR%\System32\drivers\etc\hosts
set BACKUP_FILE=%WINDIR%\System32\drivers\etc\hosts.opentune-backup-%date:~10,4%%date:~4,2%%date:~7,2%
set BLOCK_IP=0.0.0.0

echo [INFO] Backing up current hosts file to %BACKUP_FILE%...
copy /Y "%HOSTS_FILE%" "%BACKUP_FILE%" > nul
if errorlevel 1 (
    echo [ERROR] Failed to backup hosts file. Aborting hosts modification.
    goto SkipHosts
)

echo [INFO] Blocking known telemetry domains in %HOSTS_FILE%...
echo [INFO] Using %BLOCK_IP% to block. This may take some time...
attrib -r "%HOSTS_FILE%" >nul 2>&1

:: List of domains to block (consolidated and common examples)
set DOMAINS_TO_BLOCK=
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% vortex.data.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% vortex-win.data.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% telecommand.telemetry.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% telemetry.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% telemetry.urs.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% settings-win.data.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% sqm.telemetry.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% sqm.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% watson.telemetry.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% watson.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% watson.live.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% oca.telemetry.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% df.telemetry.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% reports.wes.df.telemetry.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% wes.df.telemetry.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% services.wes.df.telemetry.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% i1.services.social.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% choice.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% ceuswatcab01.blob.core.windows.net
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% ceuswatcab02.blob.core.windows.net
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% eaus2watcab01.blob.core.windows.net
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% eaus2watcab02.blob.core.windows.net
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% weus2watcab01.blob.core.windows.net
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% weus2watcab02.blob.core.windows.net
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% Telemetry.Rules.skype.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% feedback.windows.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% feedback.search.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% feedback.microsoft-hohm.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% diagnostics.support.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% corp.sts.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% compatexchange.cloudapp.net
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% cs1.wpc.v0cdn.net
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% statsfe2.ws.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% ssw.live.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% spynet.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% spynetalt.microsoft.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% fe3.delivery.dsp.mp.microsoft.com.nsatc.net
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% fe2.update.microsoft.com.akadns.net
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% www.msftncsi.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% msftncsi.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% msftconnecttest.com
set DOMAINS_TO_BLOCK=%DOMAINS_TO_BLOCK% www.msftconnecttest.com

:: Check each domain and add if not present
echo. >> "%HOSTS_FILE%"
echo # ----- Opentune Telemetry Block Start ----- >> "%HOSTS_FILE%"
for %%d in (%DOMAINS_TO_BLOCK%) do (
    findstr /L /C:"%%d" "%HOSTS_FILE%" >nul
    if errorlevel 1 (
        echo %BLOCK_IP% %%d >> "%HOSTS_FILE%"
        echo   Added: %%d
    ) else (
        echo   Skipped (already present): %%d
    )
)
echo # ----- Opentune Telemetry Block End ----- >> "%HOSTS_FILE%"
echo.

attrib +r "%HOSTS_FILE%" >nul 2>&1
:SkipHosts

echo.
echo Combined Privacy and Telemetry optimizations applied successfully.
echo It is strongly recommended to RESTART your computer for all changes to take effect.
echo.
pause
exit /b 0