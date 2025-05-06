@echo off
REM Name: revert_mitigations_EXTREME_RISK.bat
REM Description: [IMPORTANT SECURITY REVERT] Attempts to re-enable CPU hardware security mitigations (Spectre/Meltdown variants) and core Windows process exploit mitigations (DEP, ASLR, CFG). Aims to restore system security features disabled by disable_mitigations_EXTREME_RISK.bat.
REM Risk: Medium - While aiming to restore security, improperly re-enabling mitigations could theoretically cause issues. System Restore is the safest revert method.
REM RevertInfo: Attempts to restore default security mitigation settings. System Restore is strongly recommended if available. A reboot is required.

echo ============================================================================
echo                RE-ENABLING SECURITY MITIGATIONS - READ CAREFULLY!
echo ============================================================================
echo.
echo This script will attempt to re-enable:
echo 1. CPU Hardware Mitigations (Spectre, Meltdown variants) via registry.
echo 2. Core Windows Process Exploit Mitigations (DEP, ASLR, CFG) via PowerShell/registry.
echo.
echo This process aims to RESTORE essential security features.
echo.
echo ---> System Restore is still the most reliable way to revert changes. <---
echo.

set /p "confirm=Are you sure you want to re-enable system security mitigations? (Type YES to proceed): "
if /I not "%confirm%"=="YES" (
    echo Aborted by user. No changes were made.
    pause
    exit /b 1
)

echo Proceeding with re-enabling mitigations...
echo.

REM --- Re-enable CPU Hardware Mitigations (Spectre/Meltdown etc.) ---
echo [INFO] Re-enabling CPU hardware mitigations via registry (Setting to OS Default)...
REM Setting FeatureSettingsOverride=0 and FeatureSettingsOverrideMask=0 allows OS/firmware defaults.
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d 0 /f >nul 2>&1
echo [INFO] CPU hardware mitigation registry keys set to OS Default behavior.
echo.

REM --- Re-enable System-Wide Process Mitigations ---
echo [INFO] Re-enabling core system-wide process exploit mitigations (DEP, ASLR, CFG)...
echo [INFO] Running PowerShell command Set-ProcessMitigation...
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Set-ProcessMitigation -System -Enable DEP; Set-ProcessMitigation -System -Enable ASLR; Set-ProcessMitigation -System -Enable CFG; Write-Host 'Attempted to re-enable core process mitigations (DEP, ASLR, CFG). Other mitigations will use system defaults.' -ForegroundColor Green"
echo [INFO] Removing registry override for process mitigations (Kernel)...
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationOptions" /f >nul 2>&1
echo [INFO] Core system process exploit mitigations re-enabled where possible.
echo.

echo ============================================================================
echo                  MITIGATION REVERT APPLIED - REBOOT REQUIRED
echo ============================================================================
echo Security mitigations have been re-enabled where possible.
echo A RESTART IS REQUIRED for changes to take full effect.
echo Monitor system stability after restart. Use System Restore if needed.
echo ============================================================================
echo.
pause
exit /b 0