@echo off
REM Description: Reverts visual optimizations applied by optimize_visuals(combined).bat. Restores default Windows visual settings for animations, transparency, shadows, and other UI effects.
REM Risk: Low - Restoring default visual settings is safe.
REM RevertInfo: This script attempts to restore default visual settings. Alternatively, use System Restore or manually adjust settings via System Properties -> Advanced -> Performance Settings and choose 'Let Windows choose what's best for my computer'.

echo Reverting Combined Visual Optimizations to Defaults...
echo This may take a moment.
echo.

REM --- Restore Performance Preset (Let Windows choose) ---
echo [INFO] Setting visual effects preset to 'Let Windows choose what's best'...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 0 /f >nul 2>&1

REM --- Re-enable Specific Animations ---
echo [INFO] Re-enabling specific window and taskbar animations...
REM Minimize/Maximize animations
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "1" /f >nul 2>&1
REM Taskbar animations
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d 1 /f >nul 2>&1
REM Remove aggressive DWM animation disabling policies (if they exist)
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DWM" /v "DisallowAnimations" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DWM" /v "DWMWA_TRANSITIONS_FORCEDISABLED" /f >nul 2>&1

REM --- Re-enable Aero Effects ---
echo [INFO] Re-enabling Aero Peek and Transparency...
reg add "HKCU\Software\Microsoft\Windows\DWM" /v "EnableAeroPeek" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\DWM" /v "AlwaysHibernateThumbnails" /t REG_DWORD /d 0 /f >nul 2>&1 REM Default is typically 0

REM --- Re-enable Shadows ---
echo [INFO] Re-enabling listview shadows...
REM Note: Other shadows are typically handled by 'VisualFXSetting=0'
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewShadow" /t REG_DWORD /d 1 /f >nul 2>&1

REM --- Re-enable Other UI Effects ---
echo [INFO] Re-enabling Aero Shake and Balloon Tips...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisallowShaking" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "EnableBalloonTips" /t REG_DWORD /d 1 /f >nul 2>&1

REM --- Ensure Font Smoothing & Thumbnails Remain Enabled (Already default, but good practice) ---
echo [INFO] Ensuring font smoothing and thumbnails remain enabled...
reg add "HKCU\Control Panel\Desktop" /v "FontSmoothing" /t REG_SZ /d "2" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v "FontSmoothingType" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "IconsOnly" /t REG_DWORD /d 0 /f >nul 2>&1

echo.
echo Visual settings reverted to defaults successfully.
echo Some changes may require a Log Off/Log In or a Restart to take full effect.
echo.
pause
exit /b 0