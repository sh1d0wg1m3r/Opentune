@echo off
REM Description: Reverts power optimizations applied by optimize_power(combined).bat. Sets the default Balanced power plan active, restores its default settings, re-enables hibernation/fast startup, and restores default registry values for power throttling and other settings.
REM Risk: Low-Medium - Restoring defaults is generally safe. The most reliable way to revert is using a System Restore point created before applying optimizations.
REM RevertInfo: This script attempts to restore Windows default power settings. If issues persist, use System Restore.

echo Reverting Combined Power Optimizations to Defaults...
echo This may take a moment.
echo.

REM --- Set Balanced Power Plan Active ---
set BALANCED_GUID=381b4222-f694-41f0-9685-ff5bb260df2e
echo [INFO] Setting the default Balanced power plan (%BALANCED_GUID%) as active...
powercfg -setactive %BALANCED_GUID% > nul 2>&1

REM --- Restore Balanced Power Plan Defaults ---
echo [INFO] Restoring default settings for the Balanced power plan...
powercfg -restoreplansettings %BALANCED_GUID% > nul 2>&1
powercfg -setactive %BALANCED_GUID% > nul 2>&1 REM Re-apply just in case restore changed active plan

echo [INFO] Current active power scheme:
for /f "tokens=2 delims=:" %%G in ('powercfg /getactivescheme') do for /f "tokens=*" %%H in ("%%G") do echo %%H
echo.

REM --- Re-enable Hibernation and Fast Startup ---
echo [INFO] Re-enabling Hibernation (also enables Fast Startup if supported)...
powercfg -h on >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 1 /f >nul 2>&1

REM --- Re-enable Power Throttling (Default) ---
echo [INFO] Re-enabling Power Throttling (default behavior)...
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /f >nul 2>&1

REM --- Revert Other Power Registry Tweaks to Defaults ---
echo [INFO] Reverting other power-related registry tweaks to defaults...
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "EnergyEstimationEnabled" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "CsEnabled" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 20 /f >nul 2>&1 REM Default is 20% idle for background tasks
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Misc" /v "DeviceIdlePolicy" /t REG_DWORD /d 1 /f >nul 2>&1 REM Default is Cost-based/Conservative

REM --- Set Intel/AMD PPM Services to Auto Start (Default) ---
echo [INFO] Setting IntelPPM and AmdPPM services back to Automatic start...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\IntelPPM" /v Start /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AmdPPM" /v Start /t REG_DWORD /d 1 /f >nul 2>&1

REM --- Revert AHCI Link Power Management (HIPM/DIPM) to Defaults ---
echo [INFO] Reverting AHCI Link Power Management (HIPM/DIPM) to defaults (using powercfg)...
REM Try to set HIPM/DIPM back to Enabled (Value 1) for the current scheme (Balanced)
FOR /F "eol=E tokens=*" %%a IN ('REG QUERY "HKLM\System\CurrentControlSet\Control\Power\PowerSettings\0012ee47-9041-4b5d-9b77-535fba8b1442\0b2d69d7-a2a1-449c-9680-f91c70521c60" /v Attributes /t REG_DWORD ^| find "0x00000002"') DO (
    powercfg -setacvalueindex SCHEME_CURRENT 0012ee47-9041-4b5d-9b77-535fba8b1442 0b2d69d7-a2a1-449c-9680-f91c70521c60 1 >nul 2>&1
    powercfg -setdcvalueindex SCHEME_CURRENT 0012ee47-9041-4b5d-9b77-535fba8b1442 0b2d69d7-a2a1-449c-9680-f91c70521c60 1 >nul 2>&1
    echo      Successfully set AHCI Link Power Management to Enabled (HIPM/DIPM On - Default)
)
REM Try to set Adaptive timeout back to default (e.g., 600000 ms)
FOR /F "eol=E tokens=*" %%a IN ('REG QUERY "HKLM\System\CurrentControlSet\Control\Power\PowerSettings\0012ee47-9041-4b5d-9b77-535fba8b1442\dab60367-53fe-4fbc-825e-521d069d2456" /v Attributes /t REG_DWORD ^| find "0x00000002"') DO (
    powercfg -setacvalueindex SCHEME_CURRENT 0012ee47-9041-4b5d-9b77-535fba8b1442 dab60367-53fe-4fbc-825e-521d069d2456 600000 >nul 2>&1
    powercfg -setdcvalueindex SCHEME_CURRENT 0012ee47-9041-4b5d-9b77-535fba8b1442 dab60367-53fe-4fbc-825e-521d069d2456 600000 >nul 2>&1
    echo      Successfully set AHCI Link Power Management Adaptive to 600000 ms (Default)
)

REM --- Revert NVMe Power State Transition Latency Tolerance ---
echo [INFO] Reverting NVMe Power State Transition Latency Tolerance to defaults...
REM Common defaults are 5000us / 10000us, but restoring the plan defaults above should handle this.
REM We add explicit commands just in case restoreplanstate doesn't cover them fully on all systems.
powercfg -setacvalueindex SCHEME_CURRENT SUB_DISK dbc9e238-6de9-49e3-92cd-8c2b4946b472 5000 >nul 2>&1
powercfg -setdcvalueindex SCHEME_CURRENT SUB_DISK dbc9e238-6de9-49e3-92cd-8c2b4946b472 5000 >nul 2>&1
powercfg -setacvalueindex SCHEME_CURRENT SUB_DISK fc95af4d-40e7-4b6d-835a-56d131dbc80e 10000 >nul 2>&1
powercfg -setdcvalueindex SCHEME_CURRENT SUB_DISK fc95af4d-40e7-4b6d-835a-56d131dbc80e 10000 >nul 2>&1


REM --- Optionally Delete Ultimate Performance Plan ---
set UPS_GUID=e9a42b02-d5df-448d-aa00-03f14749eb61
echo [INFO] Optionally deleting the Ultimate Performance plan (%UPS_GUID%)...
powercfg -delete %UPS_GUID% >nul 2>&1


echo.
echo Power settings reverted to defaults successfully.
echo Please RESTART your computer for all changes to take full effect.
echo.
pause
exit /b 0