@echo off
REM Description: Applies various system and kernel optimizations aimed at potentially improving responsiveness and performance. Includes adjustments to memory management, filesystem behavior, process priorities, BCD settings, and disabling Superfetch/SysMain. USE WITH EXTREME CAUTION.
REM Risk: High - Modifying kernel, memory management, and BCD settings carries significant risk of instability or boot issues. Not recommended for novice users. System Restore point is essential.
REM RevertInfo: Use the corresponding revert script (revert_optimize_system_kernel(combined).bat) or System Restore. Manual reversal of BCDedit commands might be necessary if boot issues occur ('bcdedit /deletevalue <identifier> <valuename>').

echo Applying Combined System and Kernel Optimizations...
echo =====================================================
echo WARNING: MODIFYING KERNEL AND BCD SETTINGS IS RISKY!
echo PROCEED ONLY IF YOU HAVE A SYSTEM RESTORE POINT AND UNDERSTAND THE CHANGES.
echo =====================================================
echo.
pause

echo [INFO] Optimizing Memory Management settings...
REM Prioritize processes over file cache
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 0 /f >nul 2>&1
REM Keep kernel and drivers in physical RAM (may increase RAM usage)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f >nul 2>&1
echo.

echo [INFO] Optimizing Prefetch and Disabling Superfetch/SysMain...
REM Configure Prefetch for Apps and Boot
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 3 /f >nul 2>&1
REM Disable Superfetch/SysMain via registry
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d 0 /f >nul 2>&1
REM Disable SysMain Service (responsible for Superfetch)
sc config "SysMain" start=disabled >nul 2>&1
sc stop "SysMain" >nul 2>&1
echo.

echo [INFO] Optimizing Filesystem behavior (NTFS)...
REM Increase Paged Pool memory usage for file system operations
fsutil behavior set memoryusage 2 >nul 2>&1
REM Disable updating the 'last access time' stamp on files/folders (reduces disk I/O)
fsutil behavior set disablelastaccess 1 >nul 2>&1
REM Ensure TRIM is enabled for SSDs (Default is usually 0 - Enabled)
fsutil behavior set disabledeletenotify 0 >nul 2>&1
echo.

echo [INFO] Applying Kernel optimizations...
REM Distribute timers more evenly across processors
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DistributeTimers" /t REG_DWORD /d 1 /f >nul 2>&1
REM Disable kernel mitigations related to SEHOP (Potential small perf gain, slight security risk reduction)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DisableExceptionChainValidation" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "KernelSEHOPEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
echo.

echo [INFO] Adjusting Priority Control settings...
REM Prioritize foreground applications more heavily (Short, Fixed interval, Max Boost)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 38 /f >nul 2>&1 REM Hex 0x26
REM Increase priority of the Real-Time Clock interrupt
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "IRQ8Priority" /t REG_DWORD /d 1 /f >nul 2>&1
echo.

echo [INFO] Applying BCDedit settings (High Risk - Affects Boot!)...
REM Disable dynamic timer ticks (can improve perf stability, may affect power saving)
bcdedit /set disabledynamictick yes >nul 2>&1
REM Use legacy TSC synchronization (can help on some systems)
bcdedit /set tscsyncpolicy Legacy >nul 2>&1
REM Disable Hypervisor (If not using Hyper-V, WSL2, VBS) - Check first!
bcdedit /set hypervisorlaunchtype off >nul 2>&1
REM Disable Virtualization Based Security features (Reduces overhead, lowers security)
bcdedit /set vsmlaunchtype off >nul 2>&1
REM Disable integrity services (Lowers security)
bcdedit /set integrityservices disable >nul 2>&1
REM Disable boot log
bcdedit /set bootlog no >nul 2>&1
REM Disable boot animation
bcdedit /set quietboot yes >nul 2>&1
REM Attempt to enforce disabling PAE (Physical Address Extension)
bcdedit /set pae ForceDisable >nul 2>&1
echo [WARN] BCDedit changes applied. Incorrect settings here can prevent Windows from booting!
echo.

echo [INFO] Disabling System Maintenance...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\TaskScheduler\Maintenance Configurator" /DISABLE >nul 2>&1
echo.

echo [INFO] Adjusting Multimedia System Responsiveness...
REM Ensure foreground applications get priority, allow 10% for background
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 10 /f >nul 2>&1
echo.

echo ====================================================================
echo Combined System and Kernel optimizations applied successfully.
echo A RESTART IS ABSOLUTELY REQUIRED for these changes to take effect.
echo If your system fails to boot, use Windows Recovery options to access
echo the command prompt and run 'bcdedit /deletevalue <settingname>' or
echo use System Restore.
echo ====================================================================
echo.
pause
exit /b 0