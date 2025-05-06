@echo off
REM Description: Provides important information regarding the file cleanup process. Explains that deleted temporary files, caches, logs, and Recycle Bin contents are generally non-recoverable and outlines limited data recovery possibilities. This is NOT a revert script.
REM Risk: N/A (Informational Only)
REM RevertInfo: File deletion by the cleanup script is permanent. Data recovery relies on specialized tools used immediately after deletion or pre-existing backups.

echo ============================================================================
echo          IMPORTANT INFORMATION REGARDING FILE CLEANUP SCRIPT
echo ============================================================================
echo.
echo The 'optimize_cleanup(combined).bat' script PERMANENTLY DELETED files
echo from various locations on your system to free up disk space.
echo This action is generally NOT REVERSIBLE using simple methods.
echo.
echo ----------------------------------------------------------------------------
echo WHAT WAS DELETED?
echo ----------------------------------------------------------------------------
echo The script targeted files and folders within these locations:
echo   - User Temporary Files (%%TEMP%%)
echo   - Windows Temporary Files (C:\Windows\Temp)
echo   - Prefetch Cache (C:\Windows\Prefetch)
echo   - Windows Update Cache (C:\Windows\SoftwareDistribution\Download)
echo   - Thumbnail Cache (%%LocalAppData%%\Microsoft\Windows\Explorer)
echo   - Memory Dump Files (Minidump folder, MEMORY.DMP)
echo   - CBS Logs (C:\Windows\Logs\CBS)
echo   - The Recycle Bin was emptied.
echo.
echo These files are typically temporary, cached, diagnostic, or already discarded
echo data that Windows and applications can function without or regenerate.
echo.
echo ----------------------------------------------------------------------------
echo WHY IS IT (MOSTLY) IRREVERSIBLE?
echo ----------------------------------------------------------------------------
echo   - Standard Deletion: Files deleted by the script bypass the Recycle Bin
echo     (or the Recycle Bin was emptied separately).
echo   - Overwriting: When files are deleted, the space they occupied is marked
echo     as available. Continued use of your computer (saving files, installing
echo     apps, even just Browse) quickly overwrites this space with new data.
echo   - SSD TRIM Command: Modern Solid State Drives (SSDs) use the TRIM command
echo     to proactively erase data blocks marked as deleted. This improves SSD
echo     performance but makes data recovery significantly harder, often
echo     impossible, very shortly after deletion.
echo.
echo ----------------------------------------------------------------------------
echo POTENTIAL (LIMITED) RECOVERY OPTIONS - NO GUARANTEES!
echo ----------------------------------------------------------------------------
echo If you accidentally deleted something critical that happened to be in a
echo temporary location (which is not recommended practice):
echo.
echo   1. STOP USING THE DRIVE IMMEDIATELY: The less data written to the drive
echo      after deletion, the slightly higher the chance of recovery.
echo.
echo   2. FILE RECOVERY SOFTWARE: Specialized software (e.g., Recuva, EaseUS Data
echo      Recovery Wizard, Disk Drill - availability and features vary) can
echo      sometimes recover recently deleted files IF the data hasn't been
echo      overwritten or TRIMmed.
echo      - Success is NOT guaranteed and decreases rapidly over time.
echo      - Recovery chances on SSDs are generally MUCH LOWER than on HDDs.
echo      - Install and run recovery software from a DIFFERENT drive if possible.
echo.
echo   3. SYSTEM RESTORE: System Restore does NOT recover deleted personal files
echo      or application data like temporary files. It only reverts system
echo      settings, drivers, and registry configuration. It is NOT a data
echo      recovery tool for deleted files.
echo.
echo   4. BACKUPS: The most reliable way to recover lost data is from a backup
echo      you created BEFORE running the cleanup script.
echo.
echo ----------------------------------------------------------------------------
echo CONCLUSION
echo ----------------------------------------------------------------------------
echo The cleanup script performed its intended function of removing disposable
echo files. Data recovery is unlikely and difficult. Regularly back up any
echo important data to prevent permanent loss.
echo.
pause
exit /b 0