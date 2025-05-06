@echo off
REM Description: Provides information about the debloating process. Explains that app and feature removal is generally irreversible via script and outlines potential methods for manually reinstalling components like using the Microsoft Store, DISM, or official installers. This is NOT a revert script.
REM Risk: N/A (Informational Only)
REM RevertInfo: App/Feature removal is largely permanent from a script perspective. Reinstallation requires manual steps specific to the component.

echo ============================================================================
echo          IMPORTANT INFORMATION REGARDING WINDOWS DEBLOAT SCRIPT
echo ============================================================================
echo.
echo The 'optimize_debloat(interactive).bat' script removed selected built-in
echo Windows Apps (UWP) and Optional Features based on your choices during
echo script execution.
echo.
echo This removal process is generally NOT REVERSIBLE with another script.
echo The components were uninstalled from the system.
echo.
echo ----------------------------------------------------------------------------
echo WHAT CATEGORIES MIGHT HAVE BEEN REMOVED?
echo ----------------------------------------------------------------------------
echo Depending on your selections, components from these categories were targeted:
echo   - General UWP Apps (Weather, News, Maps, Alarms, Camera, Office Hub, etc.)
echo   - 3D Related Apps (3D Viewer, Print 3D, Mixed Reality Portal)
echo   - Xbox / Gaming Apps (Xbox App, Game Bar Overlay, Identity Provider)
echo   - OneDrive
echo   - Optional Windows Features (Internet Explorer 11, Media Player, Work Folders)
echo.
echo ----------------------------------------------------------------------------
echo HOW TO POTENTIALLY RESTORE COMPONENTS (Manual Steps):
echo ----------------------------------------------------------------------------
echo If you find you need a specific app or feature that was removed, here are
echo the common ways to attempt restoration:
echo.
echo   1. MICROSOFT STORE (For UWP Apps):
echo      - Many removed apps (like Camera, Mail, Calendar, Calculator, Photos,
echo        Solitaire, Sticky Notes, Xbox apps, etc.) can often be found and
echo        reinstalled directly from the Microsoft Store app.
echo      - Open the Microsoft Store, search for the specific app name, and
echo        click 'Install' or 'Get'.
echo      - Note: Not all built-in apps are available on the Store.
echo.
echo   2. OPTIONAL FEATURES (Using DISM):
echo      - Features removed via DISM can usually be re-enabled.
echo      - Open Command Prompt or PowerShell AS ADMINISTRATOR.
echo      - Use the 'DISM /Online /Enable-Feature' command. Examples:
echo          DISM /Online /Enable-Feature /FeatureName:"Internet-Explorer-Optional-amd64" /All
echo          DISM /Online /Enable-Feature /FeatureName:"WindowsMediaPlayer" /All
echo          DISM /Online /Enable-Feature /FeatureName:"WorkFolders-Client" /All
echo      - A restart might be required after enabling features.
echo.
echo   3. ONEDRIVE:
echo      - If OneDrive was removed, it needs to be reinstalled manually.
echo      - Download the latest installer from the official Microsoft OneDrive website:
echo        (Typically: https://www.microsoft.com/microsoft-365/onedrive/download)
echo      - Run the downloaded installer.
echo.
echo   4. SYSTEM RESTORE:
echo      - If you created a System Restore point BEFORE running the debloat
echo        script, restoring to that point is the most reliable way to revert
echo        ALL changes, including app/feature removals.
echo      - This will undo other changes made since the restore point was created.
echo.
echo   5. WINDOWS RESET / REINSTALL (Last Resort):
echo      - Resetting or reinstalling Windows will restore all default apps
echo        and features, but will also require reinstalling all your programs
echo        and potentially losing data if not backed up.
echo.
echo ----------------------------------------------------------------------------
echo NEED SPECIFIC HELP?
echo ----------------------------------------------------------------------------
echo If you are unsure how to reinstall a specific app or feature, you can
echo describe your situation and ask your favorite AI Assistant 
echo for detailed, up-to-date steps. For example:
echo      "How do I reinstall the Windows Camera app on Windows 11?"
echo      "Command to re-enable Windows Media Player using DISM?"
echo.
echo ----------------------------------------------------------------------------
echo CONCLUSION
echo ----------------------------------------------------------------------------
echo Debloating offers customization but requires manual steps to reverse if needed.
echo Consider carefully which components you remove in the future.
echo.
pause
exit /b 0