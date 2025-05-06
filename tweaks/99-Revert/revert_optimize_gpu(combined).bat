@echo off
setlocal enabledelayedexpansion

REM Description: [RISKY REVERT] Reverts General and Vendor-Specific GPU optimizations. Re-enables TDR, disables HAGS, restores default FSO behavior, disables MSI mode, and attempts to restore vendor default settings (NVIDIA/AMD/Intel).
REM Risk: Medium-High - Restoring defaults is generally safer, but GPU driver interactions can be complex. Re-enabling TDR is crucial for stability. System Restore is the recommended revert method if issues occur.
REM RevertInfo: Attempts to restore default Windows and driver settings. Manual checks in NVIDIA Control Panel / AMD Software / Intel Graphics Command Center may be needed. System Restore is preferred.

echo Reverting Combined GPU Optimizations to Defaults...
echo =====================================================
echo WARNING: Reverting GPU settings. TDR will be re-enabled.
echo          System Restore is the safest way to undo changes.
echo =====================================================
echo.
pause

echo Applying General GPU Reverts...
echo.

echo [INFO] Disabling Hardware-Accelerated GPU Scheduling (HAGS - Default Off)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 1 /f >nul 2>&1

echo [INFO] Re-enabling Fullscreen Optimizations Globally (Default)...
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d 0 /f >nul 2>&1

echo [INFO] Re-enabling TDR (Timeout Detection and Recovery - Default Level 3)... CRITICAL FOR STABILITY!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrLevel" /t REG_DWORD /d 3 /f >nul 2>&1
REM Optionally delete TdrDelay if it was set (optimizer didn't, but good practice)
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDelay" /f >nul 2>&1

echo [INFO] Re-enabling GpuEnergyDrv Service (Default: Demand)...
sc config "GpuEnergyDrv" start=demand >nul 2>&1

echo [INFO] Disabling MSI Mode for detected GPUs (Default)...
for /f "tokens=*" %%g in ('wmic path win32_videocontroller get PNPDeviceID ^| findstr /L "VEN_"') do (
    echo   Processing GPU: %%g
    reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d 0 /f >nul 2>&1
    reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f >nul 2>&1
)

echo.
echo General GPU reverts applied. Attempting vendor-specific reverts...
echo.

REM --- Vendor Detection ---
echo [INFO] Detecting GPU Vendor for specific reverts...
set VENDOR_DETECTED=Unknown
for /f "usebackq tokens=*" %%a in (`wmic path win32_videocontroller get Name /value`) do (
    for /f "tokens=2 delims==" %%b in ("%%a") do (
        set VENDOR_NAME=%%b
        echo !VENDOR_NAME! | findstr /i /c:"NVIDIA" > nul && set VENDOR_DETECTED=NVIDIA
        echo !VENDOR_NAME! | findstr /i /c:"AMD" /c:"Radeon" > nul && set VENDOR_DETECTED=AMD
        echo !VENDOR_NAME! | findstr /i /c:"Intel" > nul && set VENDOR_DETECTED=Intel
    )
)
echo    Detected Vendor: %VENDOR_DETECTED%
echo.

if /I "%VENDOR_DETECTED%"=="NVIDIA" goto NVIDIA_REVERT
if /I "%VENDOR_DETECTED%"=="AMD" goto AMD_REVERT
if /I "%VENDOR_DETECTED%"=="Intel" goto INTEL_REVERT
echo [WARN] Could not reliably detect GPU vendor or vendor is unsupported by specific reverts. Skipping vendor-specific reverts.
goto END_GPU_REVERT

:NVIDIA_REVERT
echo Applying NVIDIA Specific Reverts...
echo.

echo [INFO] Re-enabling NVIDIA Telemetry Tasks...
schtasks /Change /TN "\NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Enable >nul 2>&1
schtasks /Change /TN "\NvTmRep_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Enable >nul 2>&1
schtasks /Change /TN "\NvTmRepOnLogon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Enable >nul 2>&1
schtasks /Change /TN "\NVIDIA GeForce Experience SelfUpdate_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Enable >nul 2>&1
schtasks /Change /TN "\NvDriverUpdateCheckDaily_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Enable >nul 2>&1

echo [INFO] Reverting NVIDIA Telemetry Registry Settings...
reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID66610" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID64640" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID44231" /f >nul 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d 1 /f >nul 2>&1
sc config "NvTelemetryContainer" start=auto >nul 2>&1 & sc start "NvTelemetryContainer" >nul 2>&1

set "GPU_CLASS_KEY="
for /f "tokens=1,2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /s /v DriverDesc ^| findstr /i "HKEY_LOCAL_MACHINE NVIDIA"') do (
    if /I "%%b"=="DriverDesc" (
        echo "%%c" | findstr /i /c:"NVIDIA" > nul && if not defined GPU_CLASS_KEY set "GPU_CLASS_KEY=%%a"
    )
)
if not defined GPU_CLASS_KEY set GPU_CLASS_KEY=HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000
echo [INFO] Using GPU Class Key: %GPU_CLASS_KEY%

echo [INFO] Reverting NVIDIA Dynamic P-State, HDCP, PowerMizer...
reg delete "%GPU_CLASS_KEY%" /v "DisableDynamicPstate" /f >nul 2>&1
reg delete "%GPU_CLASS_KEY%" /v "RMHdcpKeyglobZero" /f >nul 2>&1
reg delete "%GPU_CLASS_KEY%" /v "PerfLevelSrc" /f >nul 2>&1
reg delete "%GPU_CLASS_KEY%" /v "PowerMizerEnable" /f >nul 2>&1
reg delete "%GPU_CLASS_KEY%" /v "PowerMizerLevel" /f >nul 2>&1
reg delete "%GPU_CLASS_KEY%" /v "PowerMizerLevelAC" /f >nul 2>&1

echo.
echo NVIDIA specific reverts applied.
goto END_GPU_REVERT

:AMD_REVERT
echo Applying AMD Specific Reverts...
echo.

set "GPU_CLASS_KEY="
for /f "tokens=1,2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /s /v DriverDesc ^| findstr /i "HKEY_LOCAL_MACHINE AMD ATI Radeon"') do (
    if /I "%%b"=="DriverDesc" (
        echo "%%c" | findstr /i /c:"AMD" /c:"ATI" /c:"Radeon" > nul && if not defined GPU_CLASS_KEY set "GPU_CLASS_KEY=%%a"
    )
)
if not defined GPU_CLASS_KEY set GPU_CLASS_KEY=HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000
echo [INFO] Using GPU Class Key: %GPU_CLASS_KEY%

echo [INFO] Reverting AMD Power Saving Features (ULPS, PowerGating)...
reg add "%GPU_CLASS_KEY%" /v "EnableUlps" /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "%GPU_CLASS_KEY%" /v "DisablePowerGating" /f >nul 2>&1
reg delete "%GPU_CLASS_KEY%" /v "DisableDrmdmaPowerGating" /f >nul 2>&1
reg delete "%GPU_CLASS_KEY%" /v "DisableSAMUPowerGating" /f >nul 2>&1
reg delete "%GPU_CLASS_KEY%" /v "PP_SclkDeepSleepDisable" /f >nul 2>&1

echo [INFO] Reverting AMD Performance Settings...
reg delete "%GPU_CLASS_KEY%" /v "StutterMode" /f >nul 2>&1
reg delete "%GPU_CLASS_KEY%" /v "PP_Force3DPerformanceMode" /f >nul 2>&1
reg delete "%GPU_CLASS_KEY%\UMD" /v "FlipQueueSize" /f >nul 2>&1
reg delete "%GPU_CLASS_KEY%\UMD" /v "Main3D" /f >nul 2>&1
reg delete "%GPU_CLASS_KEY%\UMD" /v "Main3D_DEF" /f >nul 2>&1
reg add "%GPU_CLASS_KEY%\UMD" /v "ShaderCache" /t REG_SZ /d "1" /f >nul 2>&1 REM 1 = Driver Default/On
reg delete "%GPU_CLASS_KEY%\UMD" /v "Tessellation_OPTION" /f >nul 2>&1
reg delete "%GPU_CLASS_KEY%\UMD" /v "TFQ" /f >nul 2>&1 REM Texture Filtering Quality

echo.
echo AMD specific reverts applied.
goto END_GPU_REVERT

:INTEL_REVERT
echo Applying Intel Specific Reverts...
echo.

set "GPU_CLASS_KEY="
for /f "tokens=1,2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /s /v DriverDesc ^| findstr /i "HKEY_LOCAL_MACHINE Intel"') do (
    if /I "%%b"=="DriverDesc" (
        echo "%%c" | findstr /i /c:"Intel" > nul && if not defined GPU_CLASS_KEY set "GPU_CLASS_KEY=%%a"
    )
)
if not defined GPU_CLASS_KEY set GPU_CLASS_KEY=HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000
echo [INFO] Using GPU Class Key: %GPU_CLASS_KEY%

echo [INFO] Reverting Intel specific registry tweaks...
reg delete "%GPU_CLASS_KEY%" /v "IncreaseFixedSegment" /f >nul 2>&1
reg add "%GPU_CLASS_KEY%" /v "AdaptiveVsyncEnable" /t REG_DWORD /d 1 /f >nul 2>&1 REM Default is likely 1 (On)
reg delete "%GPU_CLASS_KEY%" /v "Disable_OverlayDSQualityEnhancement" /f >nul 2>&1

echo [INFO] Reverting Intel GMM Dedicated Segment Size (Deleting override)...
reg delete "HKLM\SOFTWARE\Intel\GMM" /v "DedicatedSegmentSize" /f >nul 2>&1

echo.
echo Intel specific reverts applied.
goto END_GPU_REVERT

:END_GPU_REVERT
echo ============================================================================
echo                    GPU OPTIMIZATION REVERT APPLIED
echo ============================================================================
echo General and attempted vendor-specific GPU reverts have been applied.
echo A RESTART IS REQUIRED for these changes (especially HAGS and TDR) to take effect.
echo TDR (Timeout Detection & Recovery) has been re-enabled for stability.
echo Monitor system stability. Use System Restore if issues persist.
echo ============================================================================
echo.
pause
exit /b 0