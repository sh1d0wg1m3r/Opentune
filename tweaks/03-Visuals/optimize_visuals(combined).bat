@echo off
REM Description: Disables various Windows visual effects like animations, transparency, and shadows to improve UI responsiveness and potentially system performance, especially on lower-end hardware.
REM Risk: Low - Changes are primarily cosmetic and unlikely to cause instability. Some users may prefer the default visual appearance.
REM RevertInfo: Use the corresponding revert script (revert_optimize_visuals(combined).bat), System Restore, or manually adjust settings via System Properties -> Advanced -> Performance Settings.

echo Applying Combined Visual Optimizations...
echo This may take a moment.
echo.

REM --- Set Performance Preset (Adjust for best performance equivalent) ---
echo [INFO] Setting visual effects preset to 'Adjust for best performance'...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f >nul 2>&1

REM --- Disable Specific Animations ---
echo [INFO] Disabling specific window and taskbar animations...
REM Minimize/Maximize animations
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f >nul 2>&1
REM Taskbar animations
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d 0 /f >nul 2>&1
REM General DWM animations/transitions (More aggressive)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DWM" /v "DisallowAnimations" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DWM" /v "DWMWA_TRANSITIONS_FORCEDISABLED" /t REG_DWORD /d 1 /f >nul 2>&1

REM --- Disable Aero Effects ---
echo [INFO] Disabling Aero Peek and Transparency...
reg add "HKCU\Software\Microsoft\Windows\DWM" /v "EnableAeroPeek" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\DWM" /v "AlwaysHibernateThumbnails" /t REG_DWORD /d 0 /f >nul 2>&1 REM Often disabled with Aero Peek

REM --- Disable Shadows ---
echo [INFO] Disabling listview shadows...
REM Note: Window shadows are typically disabled by 'VisualFXSetting=2'
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewShadow" /t REG_DWORD /d 0 /f >nul 2>&1

REM --- Disable Other UI Effects ---
echo [INFO] Disabling Aero Shake and Balloon Tips...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisallowShaking" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "EnableBalloonTips" /t REG_DWORD /d 0 /f >nul 2>&1

REM --- Ensure Font Smoothing Remains Enabled (Important for Readability) ---
echo [INFO] Ensuring font smoothing is enabled...
reg add "HKCU\Control Panel\Desktop" /v "FontSmoothing" /t REG_SZ /d "2" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "FontSmoothingType" /t REG_DWORD /d 2 /f >nul 2>&1

REM --- Ensure Thumbnails Remain Enabled (Often Preferred) ---
echo [INFO] Ensuring thumbnail previews are enabled...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "IconsOnly" /t REG_DWORD /d 0 /f >nul 2>&1

echo.
echo Combined Visual optimizations applied successfully.
echo Some changes may require a Log Off/Log In or a Restart to take full effect.
echo.
pause
exit /b 0