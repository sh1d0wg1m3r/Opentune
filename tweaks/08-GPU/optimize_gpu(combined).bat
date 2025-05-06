@echo off
setlocal enabledelayedexpansion

REM Description: [RISKY] Applies General and Vendor-Specific GPU optimizations (NVIDIA/AMD/Intel). Includes enabling MSI mode, HAGS, disabling TDR, and applying various registry tweaks for performance. Disabling TDR is risky and can cause system freezes.
REM Risk: High - Modifying GPU driver parameters and disabling TDR can lead to instability, crashes, or system freezes requiring a hard reset. Vendor-specific tweaks might not apply correctly to all driver versions or hardware. System Restore point is essential.
REM RevertInfo: Use the corresponding revert script (revert_optimize_gpu(combined).bat) or System Restore. Manual reversal involves deleting/resetting specific registry keys and re-enabling TDR.

echo ============================================================================
echo                  GPU OPTIMIZATION - HIGH RISK WARNING!
echo ============================================================================
echo.
echo This script will apply General and Vendor-Specific (NVIDIA/AMD/Intel) GPU tweaks.
echo It includes disabling TDR (Timeout Detection & Recovery), which can cause
echo SYSTEM FREEZES instead of driver resets if your GPU hangs.
echo.
echo RISKS: Driver instability, graphical glitches, crashes, system freezes.
echo.
echo ---> DO NOT RUN THIS unless you understand the risks and have a backup! <---
echo --->       System Restore Point is HIGHLY RECOMMENDED before proceeding.   <---
echo.

:PROMPT_VENDOR
echo Select your GPU Vendor:
echo   [1] NVIDIA
echo   [2] AMD
echo   [3] Intel
echo   [4] Apply General Tweaks ONLY (Skip Vendor Specific)
echo   [S] Skip ALL GPU Tweaks
echo.
set /p "VENDOR_CHOICE=Enter choice (1, 2, 3, 4, or S): "

if /I "%VENDOR_CHOICE%"=="1" set VENDOR=NVIDIA& set VENDOR_STRING=NVIDIA& goto GENERAL_TWEAKS
if /I "%VENDOR_CHOICE%"=="2" set VENDOR=AMD& set VENDOR_STRING=AMD& goto GENERAL_TWEAKS
if /I "%VENDOR_CHOICE%"=="3" set VENDOR=Intel& set VENDOR_STRING=Intel& goto GENERAL_TWEAKS
if /I "%VENDOR_CHOICE%"=="4" set VENDOR=GeneralOnly& set VENDOR_STRING=& goto GENERAL_TWEAKS
if /I "%VENDOR_CHOICE%"=="S" goto SKIP_ALL
echo Invalid choice. Please try again.
goto PROMPT_VENDOR

:GENERAL_TWEAKS
echo.
echo Applying General GPU Optimizations...
echo.

echo [INFO] Enabling Hardware-Accelerated GPU Scheduling (HAGS)... Requires Win10 2004+ & Reboot.
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1

echo [INFO] Disabling Fullscreen Optimizations Globally...
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d 1 /f >nul 2>&1

echo [INFO] Disabling TDR (Timeout Detection and Recovery) - RISK: System Freeze on GPU Hang!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrLevel" /t REG_DWORD /d 0 /f >nul 2>&1

echo [INFO] Disabling GpuEnergyDrv Service...
sc config "GpuEnergyDrv" start=disabled >nul 2>&1
sc stop "GpuEnergyDrv" >nul 2>&1

echo [INFO] Enabling MSI Mode for detected GPUs...
for /f "tokens=*" %%g in ('wmic path win32_videocontroller get PNPDeviceID ^| findstr /L "VEN_"') do (
    echo   Processing GPU: %%g
    reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /t REG_DWORD /d 0 /f >nul 2>&1
)

echo.
echo General GPU tweaks applied.
echo.

if /I "%VENDOR%"=="NVIDIA" goto NVIDIA_TWEAKS
if /I "%VENDOR%"=="AMD" goto AMD_TWEAKS
if /I "%VENDOR%"=="Intel" goto INTEL_TWEAKS
goto END_GPU_TWEAKS

:NVIDIA_TWEAKS
echo Applying NVIDIA Specific Optimizations...
echo.

echo [INFO] Disabling NVIDIA Telemetry Tasks...
schtasks /Change /TN "\NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable >nul 2>&1
schtasks /Change /TN "\NvTmRep_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable >nul 2>&1
schtasks /Change /TN "\NvTmRepOnLogon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable >nul 2>&1
schtasks /Change /TN "\NVIDIA GeForce Experience SelfUpdate_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable >nul 2>&1
schtasks /Change /TN "\NvDriverUpdateCheckDaily_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" /Disable >nul 2>&1

echo [INFO] Disabling NVIDIA Telemetry Registry Settings...
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "NvBackend" /f >nul 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID66610" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID64640" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID44231" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d 0 /f >nul 2>&1
sc config "NvTelemetryContainer" start=disabled >nul 2>&1 & sc stop "NvTelemetryContainer" >nul 2>&1

set "GPU_CLASS_KEY="
for /f "tokens=1,2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /s /v DriverDesc ^| findstr /i "HKEY_LOCAL_MACHINE NVIDIA"') do (
    if /I "%%b"=="DriverDesc" (
        echo "%%c" | findstr /i /c:"%VENDOR_STRING%" > nul && if not defined GPU_CLASS_KEY set "GPU_CLASS_KEY=%%a"
    )
)

if not defined GPU_CLASS_KEY (
    echo [WARN] Could not automatically find NVIDIA registry Class Key. Applying common tweaks to ...\0000 path. This might not target the correct GPU.
    set GPU_CLASS_KEY=HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000
)
echo [INFO] Using GPU Class Key: %GPU_CLASS_KEY%

echo [INFO] Disabling NVIDIA Dynamic P-State...
reg add "%GPU_CLASS_KEY%" /v "DisableDynamicPstate" /t REG_DWORD /d 1 /f >nul 2>&1

echo [INFO] Disabling NVIDIA HDCP...
reg add "%GPU_CLASS_KEY%" /v "RMHdcpKeyglobZero" /t REG_DWORD /d 1 /f >nul 2>&1

echo [INFO] Optimizing NVIDIA PowerMizer (Prefer Maximum Performance)...
reg add "%GPU_CLASS_KEY%" /v "PerfLevelSrc" /t REG_DWORD /d 0x2222 /f >nul 2>&1 REM 0x2222 = Max Performance
reg add "%GPU_CLASS_KEY%" /v "PowerMizerEnable" /t REG_DWORD /d 0 /f >nul 2>&1 REM Disable driver power management
reg add "%GPU_CLASS_KEY%" /v "PowerMizerLevel" /t REG_DWORD /d 1 /f >nul 2>&1 REM Max perf level
reg add "%GPU_CLASS_KEY%" /v "PowerMizerLevelAC" /t REG_DWORD /d 1 /f >nul 2>&1 REM Max perf level on AC

echo.
echo NVIDIA specific tweaks applied.
goto END_GPU_TWEAKS

:AMD_TWEAKS
echo Applying AMD Specific Optimizations...
echo.

set "GPU_CLASS_KEY="
for /f "tokens=1,2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /s /v DriverDesc ^| findstr /i "HKEY_LOCAL_MACHINE AMD ATI Radeon"') do (
    if /I "%%b"=="DriverDesc" (
        echo "%%c" | findstr /i /c:"AMD" /c:"ATI" /c:"Radeon" > nul && if not defined GPU_CLASS_KEY set "GPU_CLASS_KEY=%%a"
    )
)

if not defined GPU_CLASS_KEY (
    echo [WARN] Could not automatically find AMD registry Class Key. Applying common tweaks to ...\0000 path. This might not target the correct GPU.
    set GPU_CLASS_KEY=HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000
)
echo [INFO] Using GPU Class Key: %GPU_CLASS_KEY%

echo [INFO] Disabling AMD Power Saving Features (ULPS, PowerGating)...
reg add "%GPU_CLASS_KEY%" /v "EnableUlps" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%GPU_CLASS_KEY%" /v "DisablePowerGating" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%GPU_CLASS_KEY%" /v "DisableDrmdmaPowerGating" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%GPU_CLASS_KEY%" /v "DisableSAMUPowerGating" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%GPU_CLASS_KEY%" /v "PP_SclkDeepSleepDisable" /t REG_DWORD /d 1 /f >nul 2>&1

echo [INFO] Applying AMD Performance Settings...
reg add "%GPU_CLASS_KEY%" /v "StutterMode" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%GPU_CLASS_KEY%" /v "PP_Force3DPerformanceMode" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%GPU_CLASS_KEY%\UMD" /v "FlipQueueSize" /t REG_SZ /d "1" /f >nul 2>&1
reg add "%GPU_CLASS_KEY%\UMD" /v "Main3D" /t REG_SZ /d "1" /f >nul 2>&1
reg add "%GPU_CLASS_KEY%\UMD" /v "Main3D_DEF" /t REG_SZ /d "1" /f >nul 2>&1
reg add "%GPU_CLASS_KEY%\UMD" /v "ShaderCache" /t REG_SZ /d "2" /f >nul 2>&1 REM 2 = AMD Optimized / On
reg add "%GPU_CLASS_KEY%\UMD" /v "Tessellation_OPTION" /t REG_SZ /d "0" /f >nul 2>&1 REM 0 = AMD Optimized / Off
reg add "%GPU_CLASS_KEY%\UMD" /v "TFQ" /t REG_SZ /d "1" /f >nul 2>&1 REM Texture Filtering Quality = Performance/1

echo.
echo AMD specific tweaks applied.
goto END_GPU_TWEAKS

:INTEL_TWEAKS
echo Applying Intel Specific Optimizations...
echo.

set "GPU_CLASS_KEY="
for /f "tokens=1,2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /s /v DriverDesc ^| findstr /i "HKEY_LOCAL_MACHINE Intel"') do (
    if /I "%%b"=="DriverDesc" (
        echo "%%c" | findstr /i /c:"Intel" > nul && if not defined GPU_CLASS_KEY set "GPU_CLASS_KEY=%%a"
    )
)

if not defined GPU_CLASS_KEY (
    echo [WARN] Could not automatically find Intel registry Class Key. Applying common tweaks to ...\0000 path. This might not target the correct GPU.
    set GPU_CLASS_KEY=HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000
)
echo [INFO] Using GPU Class Key: %GPU_CLASS_KEY%

echo [INFO] Applying Intel specific registry tweaks...
reg add "%GPU_CLASS_KEY%" /v "IncreaseFixedSegment" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%GPU_CLASS_KEY%" /v "AdaptiveVsyncEnable" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%GPU_CLASS_KEY%" /v "Disable_OverlayDSQualityEnhancement" /t REG_DWORD /d 1 /f >nul 2>&1

echo [INFO] Setting Intel GMM Dedicated Segment Size (May vary by hardware)...
reg add "HKLM\SOFTWARE\Intel\GMM" /v "DedicatedSegmentSize" /t REG_DWORD /d 512 /f >nul 2>&1

echo.
echo Intel specific tweaks applied.
goto END_GPU_TWEAKS

:SKIP_ALL
echo Skipping all GPU tweaks as requested.
goto END

:END_GPU_TWEAKS
echo ============================================================================
echo                       GPU OPTIMIZATIONS APPLIED
echo ============================================================================
echo General and selected vendor-specific GPU tweaks have been applied.
echo A RESTART IS REQUIRED for these changes (especially HAGS and TDR) to take effect.
echo Monitor system stability and graphics performance.
echo Use System Restore or the revert script if issues occur.
echo Remember: Disabling TDR means a GPU hang may freeze the system!
echo ============================================================================

:END
echo.
pause
exit /b 0