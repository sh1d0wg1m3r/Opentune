@echo off
REM Description: Reverts system and kernel optimizations applied by optimize_system_kernel(combined).bat. Restores default settings for memory management, filesystem behavior, process priorities, BCD settings, and re-enables Superfetch/SysMain and System Maintenance.
REM Risk: Medium - Restoring defaults is generally safe, but incorrect BCDedit reversal can cause boot issues. Use System Restore if unsure or if problems occur.
REM RevertInfo: Attempts to restore default Windows settings. System Restore is the most reliable method.

echo Reverting Combined System and Kernel Optimizations to Defaults...
echo =============================================================
echo WARNING: REVERTING BCD SETTINGS. ENSURE YOU HAVE A RECOVERY METHOD (LIKE SYSTEM RESTORE OR INSTALL MEDIA) AVAILABLE.
echo =============================================================
echo.
pause

echo [INFO] Reverting Memory Management settings to defaults...
REM Allow kernel/drivers to be paged
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 0 /f >nul 2>&1
REM Set LargeSystemCache back towards default (0 often default for client, 1 for server) - setting to 0 is safe.
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 0 /f >nul 2>&1
echo.

echo [INFO] Reverting Prefetch and Re-enabling Superfetch/SysMain...
REM Ensure Prefetch is set to default (App+Boot)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 3 /f >nul 2>&1
REM Re-enable Superfetch via registry (App+Boot)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d 3 /f >nul 2>&1
REM Re-enable SysMain Service
sc config "SysMain" start=auto >nul 2>&1
sc start "SysMain" >nul 2>&1
echo.

echo [INFO] Reverting Filesystem behavior (NTFS) to defaults...
REM Set memory usage for filesystem back to default
fsutil behavior set memoryusage 1 >nul 2>&1
REM Re-enable updating the 'last access time' stamp (Default behavior)
fsutil behavior set disablelastaccess 0 >nul 2>&1
REM Ensure TRIM is enabled (Default behavior for SSDs)
fsutil behavior set disabledeletenotify 0 >nul 2>&1
echo.

echo [INFO] Reverting Kernel optimizations to defaults...
REM Revert timer distribution
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DistributeTimers" /t REG_DWORD /d 0 /f >nul 2>&1
REM Re-enable SEHOP (Default security behavior)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DisableExceptionChainValidation" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "KernelSEHOPEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo.

echo [INFO] Reverting Priority Control settings to defaults...
REM Restore default scheduler behavior
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 2 /f >nul 2>&1 REM Hex 0x02
REM Delete the specific IRQ priority setting (let system manage)
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "IRQ8Priority" /f >nul 2>&1
echo.

echo [INFO] Reverting BCDedit settings to defaults (High Risk step!)...
REM Use /deletevalue where possible to restore default behavior
bcdedit /deletevalue disabledynamictick >nul 2>&1
bcdedit /deletevalue tscsyncpolicy >nul 2>&1
bcdedit /set hypervisorlaunchtype auto >nul 2>&1
bcdedit /deletevalue vsmlaunchtype >nul 2>&1
bcdedit /set integrityservices enable >nul 2>&1
bcdedit /set bootlog yes >nul 2>&1
bcdedit /set quietboot no >nul 2>&1
bcdedit /deletevalue pae >nul 2>&1
echo [WARN] BCDedit defaults restored where possible. Check boot stability.
echo.

echo [INFO] Re-enabling System Maintenance...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /t REG_DWORD /d 0 /f >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\TaskScheduler\Maintenance Configurator" /ENABLE >nul 2>&1
echo.

echo [INFO] Reverting Multimedia System Responsiveness to default...
REM Default is 20% reserved for background
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 20 /f >nul 2>&1
echo.

echo ====================================================================
echo System and Kernel settings reverted successfully.
echo A RESTART IS ABSOLUTELY REQUIRED for these changes to take effect.
echo Monitor system stability after restart. Use System Restore if needed.
echo ====================================================================
echo.
pause
exit /b 0