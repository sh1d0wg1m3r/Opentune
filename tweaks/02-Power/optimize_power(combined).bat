@echo off
REM Description: Applies various power optimizations aiming for maximum performance. Activates and sets the Ultimate Performance power plan, disables hibernation and fast startup, disables power throttling, and adjusts CPU/Disk power settings. Primarily intended for desktops.
REM Risk: Medium - May increase power consumption and heat. Disabling hibernation removes fast startup. Aggressive CPU power settings might cause instability on some systems (especially laptops).
REM RevertInfo: Use the corresponding revert script (revert_optimize_power(combined).bat), System Restore, or manually set the Balanced power plan and re-enable hibernation via 'powercfg -h on'.

echo Applying Combined Power Optimizations...
echo This may take a moment.
echo.

REM --- Activate and Set Ultimate Performance Power Plan ---
echo [INFO] Activating and setting Ultimate Performance power plan...
REM Unhide Ultimate Performance Plan (GUID: e9a42b02-d5df-448d-aa00-03f14749eb61)
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 > nul 2>&1
REM Set Ultimate Performance as active
powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61 > nul 2>&1
echo [INFO] Current active power scheme:
for /f "tokens=2 delims=:" %%G in ('powercfg /getactivescheme') do for /f "tokens=*" %%H in ("%%G") do echo %%H
echo.

REM --- Disable Hibernation and Fast Startup ---
echo [INFO] Disabling Hibernation (also disables Fast Startup)...
powercfg -h off >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 0 /f >nul 2>&1

REM --- Disable Power Throttling ---
echo [INFO] Disabling Power Throttling...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f >nul 2>&1

REM --- Apply PowerCFG Tweaks (CPU, Sleep, Disk) for Ultimate Performance Plan ---
set UPS_GUID=e9a42b02-d5df-448d-aa00-03f14749eb61
echo [INFO] Applying specific PowerCFG tweaks to Ultimate Performance plan...

REM CPU - Disable Throttling
powercfg -setacvalueindex %UPS_GUID% sub_processor THROTTLING 0 >nul 2>&1
powercfg -setdcvalueindex %UPS_GUID% sub_processor THROTTLING 0 >nul 2>&1
powercfg -setacvalueindex %UPS_GUID% sub_processor PROCTHROTTLEMIN 100 >nul 2>&1
powercfg -setdcvalueindex %UPS_GUID% sub_processor PROCTHROTTLEMIN 100 >nul 2>&1
powercfg -setacvalueindex %UPS_GUID% sub_processor PROCTHROTTLEMAX 100 >nul 2>&1
powercfg -setdcvalueindex %UPS_GUID% sub_processor PROCTHROTTLEMAX 100 >nul 2>&1

REM CPU - Idle States (Adjust C-State transitions - values from Exm)
powercfg -setacvalueindex %UPS_GUID% sub_processor IDLEPROMOTE 99 >nul 2>&1
powercfg -setacvalueindex %UPS_GUID% sub_processor IDLEDEMOTE 99 >nul 2>&1
powercfg -setacvalueindex %UPS_GUID% sub_processor IDLECHECK 100 >nul 2>&1
powercfg -setacvalueindex %UPS_GUID% sub_processor IDLESCALING 0 >nul 2>&1 REM Prefer performance over idle scaling

REM CPU - P-States & Turbo Boost (Values from Exm - Ensure max performance)
powercfg -setacvalueindex %UPS_GUID% sub_processor PERFAUTONOMOUS 1 >nul 2>&1
powercfg -setacvalueindex %UPS_GUID% sub_processor PERFAUTONOMOUSWINDOW 0 >nul 2>&1
powercfg -setacvalueindex %UPS_GUID% sub_processor PERFCHECK 5 >nul 2>&1
powercfg -setacvalueindex %UPS_GUID% sub_processor PERFEPP 0 >nul 2>&1
powercfg -setacvalueindex %UPS_GUID% sub_processor PERFBOOSTMODE 1 >nul 2>&1 REM Aggressive turbo
powercfg -setacvalueindex %UPS_GUID% sub_processor PERFBOOSTPOL 100 >nul 2>&1

REM Sleep Settings (Disable Hybrid Sleep, Away Mode)
powercfg -setacvalueindex %UPS_GUID% SUB_SLEEP HYBRIDSLEEP 0 >nul 2>&1
powercfg -setdcvalueindex %UPS_GUID% SUB_SLEEP HYBRIDSLEEP 0 >nul 2>&1
powercfg -setacvalueindex %UPS_GUID% SUB_SLEEP AWAYMODE 0 >nul 2>&1
powercfg -setdcvalueindex %UPS_GUID% SUB_SLEEP AWAYMODE 0 >nul 2>&1
powercfg -setacvalueindex %UPS_GUID% SUB_SLEEP STANDBYIDLE 0 >nul 2>&1 REM Disable standby idle timeout
powercfg -setdcvalueindex %UPS_GUID% SUB_SLEEP STANDBYIDLE 0 >nul 2>&1

REM Disk Settings (Turn off HDD/SSD timeout)
powercfg -setacvalueindex %UPS_GUID% SUB_DISK DISKIDLE 0 >nul 2>&1
powercfg -setdcvalueindex %UPS_GUID% SUB_DISK DISKIDLE 0 >nul 2>&1

REM PCI Express Link State Power Management (Off for max performance)
powercfg -setacvalueindex %UPS_GUID% SUB_PCIEXPRESS ASPM 0 >nul 2>&1
powercfg -setdcvalueindex %UPS_GUID% SUB_PCIEXPRESS ASPM 0 >nul 2>&1

REM --- Other Power Registry Tweaks ---
echo [INFO] Applying other power-related registry tweaks...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "EnergyEstimationEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "CsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1 REM Disable Connected Standby if applicable
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul 2>&1 REM Prioritize foreground apps heavily
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Misc" /v "DeviceIdlePolicy" /t REG_DWORD /d 0 /f >nul 2>&1 REM Performance for device idle

REM --- Set Intel/AMD PPM Services to Manual ---
echo [INFO] Setting IntelPPM and AmdPPM services to Manual start...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\IntelPPM" /v Start /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AmdPPM" /v Start /t REG_DWORD /d 3 /f >nul 2>&1

REM --- Disable AHCI Link Power Management (HIPM/DIPM) ---
echo [INFO] Disabling AHCI Link Power Management (HIPM/DIPM)...
FOR /F "tokens=*" %%a IN ('REG QUERY "HKLM\System\CurrentControlSet\Control\Power\PowerSettings\0012ee47-9041-4b5d-9b77-535fba8b1442\0b2d69d7-a2a1-449c-9680-f91c70521c60" /v Attributes /t REG_DWORD ^| find "0x00000002"') DO (
    powercfg -setacvalueindex SCHEME_CURRENT 0012ee47-9041-4b5d-9b77-535fba8b1442 0b2d69d7-a2a1-449c-9680-f91c70521c60 0 >nul 2>&1
    powercfg -setdcvalueindex SCHEME_CURRENT 0012ee47-9041-4b5d-9b77-535fba8b1442 0b2d69d7-a2a1-449c-9680-f91c70521c60 0 >nul 2>&1
    echo      Successfully set AHCI Link Power Management to Active (HIPM/DIPM Off)
)
FOR /F "tokens=*" %%a IN ('REG QUERY "HKLM\System\CurrentControlSet\Control\Power\PowerSettings\0012ee47-9041-4b5d-9b77-535fba8b1442\dab60367-53fe-4fbc-825e-521d069d2456" /v Attributes /t REG_DWORD ^| find "0x00000002"') DO (
    powercfg -setacvalueindex SCHEME_CURRENT 0012ee47-9041-4b5d-9b77-535fba8b1442 dab60367-53fe-4fbc-825e-521d069d2456 0 >nul 2>&1
    powercfg -setdcvalueindex SCHEME_CURRENT 0012ee47-9041-4b5d-9b77-535fba8b1442 dab60367-53fe-4fbc-825e-521d069d2456 0 >nul 2>&1
    echo      Successfully set AHCI Link Power Management Adaptive to 0 ms
)
REM Registry method as fallback/reinforcement (from Exm)
FOR /F "eol=E tokens=*" %%a in ('REG QUERY "HKLM\System\CurrentControlSet\Services" /s /f "EnableHIPM" ^| FINDSTR /V "EnableHIPM"') DO (
    REG ADD "%%a" /v "EnableHIPM" /t REG_DWORD /d 0 /f >nul 2>&1
    REG ADD "%%a" /v "EnableDIPM" /t REG_DWORD /d 0 /f >nul 2>&1
)

REM --- Disable NVMe Power State Transition Latency Tolerance ---
echo [INFO] Setting NVMe Power State Transition Latency Tolerance to lowest (max performance)...
powercfg -setacvalueindex %UPS_GUID% SUB_DISK dbc9e238-6de9-49e3-92cd-8c2b4946b472 0 >nul 2>&1
powercfg -setdcvalueindex %UPS_GUID% SUB_DISK dbc9e238-6de9-49e3-92cd-8c2b4946b472 0 >nul 2>&1
powercfg -setacvalueindex %UPS_GUID% SUB_DISK fc95af4d-40e7-4b6d-835a-56d131dbc80e 0 >nul 2>&1
powercfg -setdcvalueindex %UPS_GUID% SUB_DISK fc95af4d-40e7-4b6d-835a-56d131dbc80e 0 >nul 2>&1


echo.
echo Combined Power optimizations applied successfully.
echo Please RESTART your computer for all changes to take full effect.
echo.
pause
exit /b 0