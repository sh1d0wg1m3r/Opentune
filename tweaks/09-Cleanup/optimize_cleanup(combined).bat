@echo off
setlocal enabledelayedexpansion

REM Description: Cleans various temporary file locations, caches, logs, and empties the Recycle Bin to free up disk space. Targets User Temp, Windows Temp, Prefetch, Windows Update Cache, Thumbnail Cache, Memory Dumps, CBS Logs, and runs basic Disk Cleanup.
REM Risk: Low-Medium - While generally safe, deleting temporary files currently in use by an application could cause issues with that specific app. Closing major applications before running is recommended. Data deleted is generally non-recoverable without backups.
REM RevertInfo: File deletion is largely irreversible. Temporary files and caches will be recreated by the system and applications as needed. Use System Restore if unexpected problems occur.

echo =====================================================================
echo                         SYSTEM CLEANUP SCRIPT
echo =====================================================================
echo This script will delete temporary files, logs, caches, and empty the
echo Recycle Bin. It is recommended to CLOSE major applications before
echo proceeding. Data deletion is PERMANENT.
echo =====================================================================
echo.
pause

echo [INFO] Cleaning User Temporary Files (%TEMP%)...
pushd "%TEMP%" >nul 2>&1
if errorlevel 1 (
    echo [WARN] Cannot access %TEMP% directory. Skipping.
) else (
    del /F /S /Q *.* >nul 2>&1
    for /d %%D in (*) do rd /S /Q "%%D" >nul 2>&1
    popd
    echo      User Temp files cleaned.
)
echo.

echo [INFO] Cleaning Windows Temporary Files (%WINDIR%\Temp)...
pushd "%WINDIR%\Temp" >nul 2>&1
if errorlevel 1 (
    echo [WARN] Cannot access %WINDIR%\Temp directory. Skipping.
) else (
    del /F /S /Q *.* >nul 2>&1
    for /d %%D in (*) do rd /S /Q "%%D" >nul 2>&1
    popd
    echo      Windows Temp files cleaned.
)
echo.

echo [INFO] Cleaning Prefetch Files (%WINDIR%\Prefetch)...
pushd "%WINDIR%\Prefetch" >nul 2>&1
if errorlevel 1 (
    echo [WARN] Cannot access %WINDIR%\Prefetch directory. Skipping.
) else (
    del /F /Q *.* >nul 2>&1
    popd
    echo      Prefetch files cleaned.
)
echo.

echo [INFO] Cleaning Windows Update Cache (%WINDIR%\SoftwareDistribution\Download)...
echo      Stopping Windows Update Service...
net stop wuauserv >nul 2>&1
pushd "%WINDIR%\SoftwareDistribution\Download" >nul 2>&1
if errorlevel 1 (
    echo [WARN] Cannot access SoftwareDistribution\Download directory. Skipping.
) else (
    del /F /S /Q *.* >nul 2>&1
    for /d %%D in (*) do rd /S /Q "%%D" >nul 2>&1
    popd
    echo      Windows Update Cache cleaned.
)
echo      Starting Windows Update Service...
net start wuauserv >nul 2>&1
echo.

echo [INFO] Cleaning Thumbnail Cache (%LocalAppData%\Microsoft\Windows\Explorer)...
pushd "%LocalAppData%\Microsoft\Windows\Explorer" >nul 2>&1
if errorlevel 1 (
    echo [WARN] Cannot access Explorer directory for Thumbnails. Skipping.
) else (
    del /F /A:H /Q thumbcache_*.db >nul 2>&1
    popd
    echo      Thumbnail cache cleaned. (May require explorer restart to see full effect)
)
echo.

echo [INFO] Cleaning Memory Dumps...
del /F /Q %SystemRoot%\MEMORY.DMP >nul 2>&1
del /F /Q %SystemRoot%\Minidump\*.* >nul 2>&1
echo      Memory dumps cleaned (if found).
echo.

echo [INFO] Cleaning CBS Logs (%WINDIR%\Logs\CBS)...
pushd "%WINDIR%\Logs\CBS" >nul 2>&1
if errorlevel 1 (
    echo [WARN] Cannot access CBS Logs directory. Skipping.
) else (
    del /F /Q *.log >nul 2>&1
    del /F /Q *.cab >nul 2>&1
    del /F /Q *.persist >nul 2>&1
    popd
    echo      CBS logs cleaned.
)
echo.

echo [INFO] Emptying Recycle Bin...
PowerShell.exe -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
echo      Recycle Bin emptied.
echo.

echo [INFO] Running basic Disk Cleanup (cleanmgr /autoclean)...
REM This runs cleanmgr with settings possibly defined by sagerun:1 previously, or defaults.
REM For more control, use cleanmgr /sageset:1 first to select items manually.
cleanmgr /autoclean > nul 2>&1
echo      Basic Disk Cleanup initiated.
echo.

echo =====================================================================
echo                         CLEANUP COMPLETE
echo =====================================================================
echo Various temporary files, caches, and logs have been removed.
echo Disk space may have been freed. Restarting Explorer or the PC
echo might be needed for some changes (like icon cache) to fully apply.
echo =====================================================================
echo.
pause
exit /b 0