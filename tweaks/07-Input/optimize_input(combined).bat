@echo off
REM Description: Applies common mouse and keyboard optimizations to potentially reduce input latency and improve responsiveness. Disables mouse acceleration, smoothing, accessibility key features (Sticky, Filter, Toggle Keys), optimizes keyboard repeat rate/delay, and sets high thread priority for input services.
REM Risk: Low - These changes primarily affect the 'feel' of input devices and are unlikely to cause system instability. Some users may prefer default settings (e.g., mouse acceleration).
REM RevertInfo: Use the corresponding revert script (revert_optimize_input(combined).bat), System Restore, or manually adjust settings via Windows Settings / Control Panel (Mouse, Keyboard, Ease of Access).

echo Applying Combined Input Optimizations...
echo This may take a moment.
echo.

REM --- Mouse Settings ---
echo [INFO] Disabling Mouse Acceleration (Enhance Pointer Precision)...
reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f >nul 2>&1

echo [INFO] Setting 1:1 Mouse Movement (Sensitivity 10/20)...
reg add "HKCU\Control Panel\Mouse" /v "MouseSensitivity" /t REG_SZ /d "10" /f >nul 2>&1

echo [INFO] Disabling Mouse Smoothing Curves...
reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d 00000000000000000000000000000000000000000000000000000000000000000000000000000000 /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseYCurve" /t REG_BINARY /d 00000000000000000000000000000000000000000000000000000000000000000000000000000000 /f >nul 2>&1

echo [INFO] Disabling Mouse Beep/Sounds...
reg add "HKCU\Control Panel\Mouse" /v "Beep" /t REG_SZ /d "No" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "ExtendedSounds" /t REG_SZ /d "No" /f >nul 2>&1
echo.

REM --- Keyboard Settings ---
echo [INFO] Optimizing Keyboard Repeat Rate and Delay...
reg add "HKCU\Control Panel\Keyboard" /v "KeyboardDelay" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Keyboard" /v "KeyboardSpeed" /t REG_SZ /d "31" /f >nul 2>&1
echo.

REM --- Accessibility Key Features ---
echo [INFO] Disabling Sticky Keys, Filter Keys, Toggle Keys prompts/features...
REM Sticky Keys (Flags: 506 = Off, No sound, No warning)
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "506" /f >nul 2>&1
REM Filter Keys (Flags: 122 = Off, No sound, No warning)
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "122" /f >nul 2>&1
REM Toggle Keys (Flags: 58 = Off, No sound, No warning)
reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "58" /f >nul 2>&1
echo.

REM --- Input Service Thread Priority ---
echo [INFO] Setting High Thread Priority for Mouse and Keyboard Services...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "ThreadPriority" /t REG_DWORD /d 31 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "ThreadPriority" /t REG_DWORD /d 31 /f >nul 2>&1
echo.

echo Combined Input optimizations applied successfully.
echo A Log Off/Log In or a Restart is recommended for all changes to take effect.
echo.
pause
exit /b 0