@echo off
REM Description: Reverts network optimizations applied by optimize_network(combined).bat. Restores default values for TCP/IP parameters, NIC settings (power saving, offloads, etc.), network throttling, and removes related firewall rule.
REM Risk: Low-Medium - Restoring defaults is generally safe but might remove a beneficial tweak or potentially conflict if other tools have modified settings. A System Restore point is the most reliable revert method.
REM RevertInfo: This script attempts to set known Windows defaults. If issues persist, use System Restore or consult network adapter documentation.

echo Reverting Combined Network Optimizations to Defaults...
echo This may take a moment.
echo.

REM --- Revert Network Throttling ---
echo [INFO] Restoring Network Throttling Index to default (10)...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 10 /f >nul 2>&1
echo [INFO] Restoring NonBestEffortLimit to default (0)...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d 0 /f >nul 2>&1
echo [INFO] Removing Opentune firewall rule...
netsh advfirewall firewall delete rule name="Opentune_StopThrottling" >nul 2>&1

REM --- Revert Core TCP/IP Parameter Tweaks (Registry) ---
echo [INFO] Reverting core TCP/IP registry tweaks to defaults...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DefaultTTL" /t REG_DWORD /d 128 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnablePMTUDiscovery" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Tcp1323Opts" /t REG_DWORD /d 1 /f >nul 2>&1 REM Default is typically 1 or 3
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxDupAcks" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "SackOpts" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MaxUserPort" /t REG_DWORD /d 65534 /f >nul 2>&1 REM Or delete to let system manage
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d 60 /f >nul 2>&1 REM Common modern default

REM --- Re-enable Nagle's Algorithm (Default Behavior) ---
echo [INFO] Re-enabling Nagle's Algorithm (Removing TcpAckFrequency, TCPNoDelay)...
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v "TcpAckFrequency" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\MSMQ\Parameters" /v "TCPNoDelay" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpAckFrequency" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TCPNoDelay" /f >nul 2>&1

REM --- Revert AFD Parameters (Delete to use defaults) ---
echo [INFO] Reverting AFD parameters (deleting specific values to use defaults)...
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DefaultReceiveWindow" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DefaultSendWindow" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "FastSendDatagramThreshold" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "IgnorePushBitOnReceives" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "NonBlockingSendSpecialBuffering" /f >nul 2>&1

REM --- Revert Network Adapter Settings via Registry (Loop through adapters) ---
echo [INFO] Reverting specific network adapter settings to defaults (Power Saving, Offloads, Buffers)...
for /f "tokens=*" %%n in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}" /s /v "*SpeedDuplex" ^| findstr /i /c:"HKEY_LOCAL_MACHINE"') do (
    echo [INFO]   Processing Adapter: %%n

    REM Enable Power Saving Features (Set to 1 or driver default)
    reg add "%%n" /v "AutoPowerSaveModeEnabled" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "AutoDisableGigabit" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "AdvancedEEE" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "*EEE" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "EEE" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "EnablePME" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "EnableGreenEthernet" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "PowerSavingMode" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "ReduceSpeedOnPowerDown" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "S5WakeOnLan" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "*WakeOnMagicPacket" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "*WakeOnPattern" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "WakeOnLink" /t REG_SZ /d "1" /f >nul 2>&1

    REM Enable Flow Control (Set to Auto or driver default)
    reg add "%%n" /v "*FlowControl" /t REG_SZ /d "3" /f >nul 2>&1
    reg add "%%n" /v "FlowControl" /t REG_SZ /d "3" /f >nul 2>&1

    REM Enable Interrupt Moderation (Set to 1 or driver default)
    reg add "%%n" /v "*InterruptModeration" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "ITR" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "InterruptModerationRate" /t REG_SZ /d "1" /f >nul 2>&1

    REM Revert Buffers (Delete the keys to let driver use defaults)
    reg delete "%%n" /v "TransmitBuffers" /f >nul 2>&1
    reg delete "%%n" /v "ReceiveBuffers" /f >nul 2>&1

    REM Enable Offloads (Set to 1 or driver default)
    reg add "%%n" /v "*IPChecksumOffload" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "*TCPChecksumOffloadIPv4" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "*TCPChecksumOffloadIPv6" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "*UDPChecksumOffloadIPv4" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "*UDPChecksumOffloadIPv6" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "*LsoV2IPv4" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "*LsoV2IPv6" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "*PMARPOffload" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "*PMNSOffload" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "*TSOEnable" /t REG_SZ /d "1" /f >nul 2>&1

    REM Revert RSS (Ensure enabled, delete queue count to let driver decide)
    reg add "%%n" /v "*RSS" /t REG_SZ /d "1" /f >nul 2>&1
    reg delete "%%n" /v "*NumRssQueues" /f >nul 2>&1
)
echo [INFO]   Finished processing adapters.

REM --- Revert Netsh TCP Global Settings ---
echo [INFO] Reverting Netsh TCP global settings to default...
netsh int tcp set global autotuninglevel=default >nul 2>&1
netsh int tcp set global congestionprovider=default >nul 2>&1
netsh int tcp set global ecncapability=default >nul 2>&1
netsh int tcp set global timestamps=default >nul 2>&1
netsh int tcp set global initialRto=3000 >nul 2>&1
netsh int tcp set global rsc=default >nul 2>&1
netsh int tcp set heuristics default >nul 2>&1

REM --- Revert Netsh IP Global Settings ---
echo [INFO] Reverting Netsh IP global settings to default...
netsh int ip set global icmpredirects=default >nul 2>&1
netsh int ip set global multicastforwarding=default >nul 2>&1

REM --- Revert Netsh Interface State ---
echo [INFO] Reverting Teredo, ISATAP, 6to4 interfaces to default state...
netsh interface teredo set state default >nul 2>&1
netsh interface isatap set state default >nul 2>&1
netsh interface 6to4 set state default >nul 2>&1

REM --- Revert NetBIOS over TCP/IP (Set to Default/DHCP) ---
echo [INFO] Reverting NetBIOS over TCP/IP to default (Use DHCP Setting)...
wmic nicconfig where TcpipNetbiosOptions=2 call SetTcpipNetbios 0 >nul 2>&1

REM --- Revert DNS Priority Settings ---
echo [INFO] Reverting DNS provider priority to defaults...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "LocalPriority" /t REG_DWORD /d 4 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "HostsPriority" /t REG_DWORD /d 5 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "DnsPriority" /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "NetbtPriority" /t REG_DWORD /d 7 /f >nul 2>&1

REM --- Flush DNS Cache ---
echo [INFO] Flushing DNS cache...
ipconfig /flushdns >nul

echo.
echo Network settings reverted to defaults successfully.
echo It is recommended to RESTART your computer for all changes to take effect.
echo.
pause
exit /b 0