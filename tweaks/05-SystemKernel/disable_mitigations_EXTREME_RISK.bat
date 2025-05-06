@echo off
REM Name: disable_mitigations_EXTREME_RISK.bat
REM Description: [EXTREME RISK!] Disables CPU hardware security mitigations (Spectre/Meltdown variants) and system-wide process exploit mitigations. This significantly reduces system security for a potential minor performance gain. USE ONLY IF YOU FULLY UNDERSTAND THE RISKS AND HAVE A RECOVERY PLAN.
REM Risk: Extreme - Disables critical security features, increases vulnerability to exploits, may cause system instability or crashes. NOT RECOMMENDED FOR GENERAL USE.
REM RevertInfo: System Restore is the STRONGLY RECOMMENDED method to revert. Manual reversion involves deleting specific registry keys and re-enabling process mitigations (complex). See revert_mitigations_EXTREME_RISK.bat.

echo ============================================================================
echo                  EXTREME RISK WARNING - READ CAREFULLY!
echo ============================================================================
echo.
echo This script will attempt to disable:
echo 1. CPU Hardware Mitigations (Spectre, Meltdown variants) via registry.
echo 2. Windows Process Exploit Mitigations (ASLR, DEP, CFG, etc.) via PowerShell/registry.
echo.
echo BENEFITS:
echo - POTENTIALLY minor performance increase in certain CPU-heavy tasks.
echo.
echo RISKS:
echo - SIGNIFICANTLY INCREASES vulnerability to known security exploits.
echo - May cause SYSTEM INSTABILITY, application crashes, or boot failures.
echo - May be reset by Windows updates.
echo.
echo ---> DO NOT RUN THIS unless you understand these risks and have a backup! <---
echo --->       System Restore Point is HIGHLY RECOMMENDED before proceeding.     <---
echo.

set /p "confirm=Are you absolutely sure you want to continue? (Type YES to proceed): "
if /I not "%confirm%"=="YES" (
    echo Aborted by user. No changes were made.
    pause
    exit /b 1
)

echo Proceeding with disabling mitigations...
echo.

REM --- Disable CPU Hardware Mitigations (Spectre/Meltdown etc.) ---
echo [INFO] Disabling CPU hardware mitigations via registry...
REM Setting FeatureSettingsOverride=3 and FeatureSettingsOverrideMask=3 attempts to disable mitigations.
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d 3 /f >nul 2>&1
echo [WARN] CPU hardware mitigation registry keys set. This reduces security.
echo.

REM --- Disable System-Wide Process Mitigations ---
echo [INFO] Disabling system-wide process exploit mitigations (ASLR, DEP, CFG etc.)...
echo [INFO] Running PowerShell command Set-ProcessMitigation...
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "ForEach($v in (Get-Command -Name 'Set-ProcessMitigation').Parameters['Disable'].Attributes.ValidValues){Write-Host '  Disabling:' $v; Set-ProcessMitigation -System -Disable $v.ToString() -ErrorAction SilentlyContinue}"
echo [INFO] Applying registry override for process mitigations (Kernel)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationOptions" /t REG_BINARY /d 222222222222222222222222222222222222222222222222 /f >nul 2>&1
echo [WARN] System process exploit mitigations disabled. This reduces security.
echo.

echo ============================================================================
echo                    MITIGATIONS DISABLED - REBOOT REQUIRED
echo ============================================================================
echo Security mitigations have been disabled. Your system is now MORE VULNERABLE.
echo A RESTART IS REQUIRED for changes to take full effect.
echo.
echo TO REVERT: Use System Restore OR run the corresponding revert script.
echo Manual reversion is complex and not recommended.
echo ============================================================================
echo.
pause
exit /b 0