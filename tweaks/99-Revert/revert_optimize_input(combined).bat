@echo off
REM Description: Reverts input optimizations applied by optimize_input(combined).bat. Restores default mouse acceleration, keyboard repeat settings, accessibility key features (Sticky, Filter, Toggle Keys), and removes custom thread priority settings.
REM Risk: Low - Restoring default input settings is safe. Users may need to readjust sensitivity or keyboard repeat to personal preference afterward.
REM RevertInfo: Restores default Windows settings. Manual adjustments can be made via Windows Settings / Control Panel (Mouse, Keyboard, Ease of Access).

echo Reverting Combined Input Optimizations to Defaults...
echo This may take a moment.
echo.

REM --- Mouse Settings ---
echo [INFO] Re-enabling Mouse Acceleration (Default Values)...
reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "1" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "6" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "10" /f >nul 2>&1

echo [INFO] Setting Default Mouse Sensitivity (10/20)...
reg add "HKCU\Control Panel\Mouse" /v "MouseSensitivity" /t REG_SZ /d "10" /f >nul 2>&1

echo [INFO] Restoring Mouse Smoothing Curves (Deleting overrides)...
reg delete "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /f >nul 2>&1
reg delete "HKCU\Control Panel\Mouse" /v "SmoothMouseYCurve" /f >nul 2>&1

echo [INFO] Re-enabling Mouse Beep/Sounds...
reg add "HKCU\Control Panel\Mouse" /v "Beep" /t REG_SZ /d "Yes" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "ExtendedSounds" /t REG_SZ /d "Yes" /f >nul 2>&1
echo.

REM --- Keyboard Settings ---
echo [INFO] Restoring Default Keyboard Repeat Rate and Delay...
reg add "HKCU\Control Panel\Keyboard" /v "KeyboardDelay" /t REG_SZ /d "1" /f >nul 2>&1
reg add "HKCU\Control Panel\Keyboard" /v "KeyboardSpeed" /t REG_SZ /d "31" /f >nul 2>&1 REM Default is often 31, adjust manually if needed

echo.

REM --- Accessibility Key Features ---
echo [INFO] Restoring Default Accessibility Key Features (Sticky, Filter, Toggle Keys)...
REM Sticky Keys (Flags: 510 = Default On behavior with warnings/sounds)
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "510" /f >nul 2>&1
REM Filter Keys (Flags: 126 = Default On behavior with warnings/sounds)
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "126" /f >nul 2>&1
REM Toggle Keys (Flags: 62 = Default On behavior with sound)
reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "62" /f >nul 2>&1
echo.

REM --- Input Service Thread Priority ---
echo [INFO] Removing Custom Thread Priority for Mouse and Keyboard Services...
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "ThreadPriority" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "ThreadPriority" /f >nul 2>&1
echo.

echo Input settings reverted to defaults successfully.
echo A Log Off/Log In or a Restart is recommended for all changes to take effect.
echo You may wish to manually adjust mouse sensitivity or keyboard repeat speed afterwards.
echo.
pause
exit /b 0