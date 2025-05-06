@echo off
REM Description: Applies various network optimizations for potentially lower latency and better throughput. Includes disabling NIC power saving, Nagle's algorithm, network throttling, and adjusting TCP/IP parameters. Designed primarily for Ethernet connections.
REM Risk: Medium - Incorrect settings or hardware/driver incompatibility might cause connectivity issues. Disabling offloads can slightly increase CPU usage.
REM RevertInfo: Use the corresponding revert script (revert_optimize_network(combined).bat) or System Restore. Key default values are often noted in the revert script.

echo Applying Combined Network Optimizations...
echo This may take a moment.
echo.

REM --- Disable Network Throttling ---
echo [INFO] Disabling Network Throttling Index...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 4294967295 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d 0 /f >nul 2>&1
REM Also add firewall rule just in case (from Exm) - less common approach
echo [INFO] Adding firewall rule to potentially help against throttling (Note: Effectiveness may vary)...
netsh advfirewall firewall add rule name="Opentune_StopThrottling" dir=in action=block remoteip=173.194.55.0/24,206.111.0.0/16 enable=yes >nul 2>&1

REM --- Core TCP/IP Parameter Tweaks (Registry) ---
echo [INFO] Applying core TCP/IP registry tweaks...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DefaultTTL" /t REG_DWORD /d 64 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "EnablePMTUDiscovery" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Tcp1323Opts" /t REG_DWORD /d 1 /f >nul 2>&1 REM Default is often 1 or 3, 1 enables Window Scaling & Timestamps
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxDupAcks" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "SackOpts" /t REG_DWORD /d 1 /f >nul 2>&1 REM Enable SACK, generally beneficial
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MaxUserPort" /t REG_DWORD /d 65534 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d 30 /f >nul 2>&1

REM --- Disable Nagle's Algorithm (Registry) ---
echo [INFO] Disabling Nagle's Algorithm (TcpAckFrequency, TCPNoDelay)...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\MSMQ\Parameters" /v "TCPNoDelay" /t REG_DWORD /d 1 /f >nul 2>&1
REM Apply globally and per-interface (loop might be needed for robustness, but this covers most cases)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TCPNoDelay" /t REG_DWORD /d 1 /f >nul 2>&1

REM --- AFD Parameters (Registry) ---
echo [INFO] Applying AFD parameter tweaks...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DefaultReceiveWindow" /t REG_DWORD /d 16384 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DefaultSendWindow" /t REG_DWORD /d 16384 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "FastSendDatagramThreshold" /t REG_DWORD /d 1024 /f >nul 2>&1 REM Smaller value from some guides
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "IgnorePushBitOnReceives" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "NonBlockingSendSpecialBuffering" /t REG_DWORD /d 1 /f >nul 2>&1

REM --- Optimize Network Adapter Settings via Registry (Loop through adapters) ---
echo [INFO] Optimizing specific network adapter settings (Power Saving, Offloads, Buffers)...
for /f "tokens=*" %%n in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}" /s /v "*SpeedDuplex" ^| findstr /i /c:"HKEY_LOCAL_MACHINE"') do (
    echo [INFO]   Processing Adapter: %%n

    REM Disable Power Saving Features
    reg add "%%n" /v "AutoPowerSaveModeEnabled" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "AutoDisableGigabit" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "AdvancedEEE" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "*EEE" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "EEE" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "EnablePME" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "EnableGreenEthernet" /t REG_SZ /d "0" /f >nul 2>1
    reg add "%%n" /v "PowerSavingMode" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "ReduceSpeedOnPowerDown" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "S5WakeOnLan" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "*WakeOnMagicPacket" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "*WakeOnPattern" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "WakeOnLink" /t REG_SZ /d "0" /f >nul 2>&1

    REM Disable Flow Control
    reg add "%%n" /v "*FlowControl" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "FlowControl" /t REG_SZ /d "0" /f >nul 2>&1

    REM Disable Interrupt Moderation
    reg add "%%n" /v "*InterruptModeration" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "ITR" /t REG_SZ /d "0" /f >nul 2>&1 REM Common Intel reg value for this
    reg add "%%n" /v "InterruptModerationRate" /t REG_SZ /d "0" /f >nul 2>&1

    REM Adjust Buffers (Values from Exm, may need tweaking per system)
    reg add "%%n" /v "TransmitBuffers" /t REG_SZ /d "512" /f >nul 2>&1
    reg add "%%n" /v "ReceiveBuffers" /t REG_SZ /d "512" /f >nul 2>&1

    REM Disable specific Offloads (May increase CPU usage slightly)
    reg add "%%n" /v "*IPChecksumOffload" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "*TCPChecksumOffloadIPv4" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "*TCPChecksumOffloadIPv6" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "*UDPChecksumOffloadIPv4" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "*UDPChecksumOffloadIPv6" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "*LsoV2IPv4" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "*LsoV2IPv6" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "*PMARPOffload" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "*PMNSOffload" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%n" /v "*TSOEnable" /t REG_SZ /d "0" /f >nul 2>&1

    REM Enable RSS (Receive Side Scaling)
    reg add "%%n" /v "*RSS" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%n" /v "*NumRssQueues" /t REG_SZ /d "4" /f >nul 2>&1 REM Adjust based on CPU cores (e.g., 2 or 4)
)
echo [INFO]   Finished processing adapters.

REM --- Netsh TCP Global Settings ---
echo [INFO] Applying Netsh TCP global settings...
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global congestionprovider=ctcp >nul 2>&1
netsh int tcp set global ecncapability=enabled >nul 2>&1
netsh int tcp set global timestamps=disabled >nul 2>&1
netsh int tcp set global initialRto=2000 >nul 2>&1
netsh int tcp set global rsc=disabled >nul 2>&1
netsh int tcp set heuristics disabled >nul 2>&1

REM --- Netsh IP Global Settings ---
echo [INFO] Applying Netsh IP global settings...
netsh int ip set global icmpredirects=disabled >nul 2>&1
netsh int ip set global multicastforwarding=disabled >nul 2>nul

REM --- Netsh Interface State ---
echo [INFO] Disabling Teredo, ISATAP, 6to4 interfaces...
netsh interface teredo set state disabled >nul 2>&1
netsh interface isatap set state disabled >nul 2>&1
netsh interface 6to4 set state disabled >nul 2>&1

REM --- Disable NetBIOS over TCP/IP ---
echo [INFO] Disabling NetBIOS over TCP/IP for appropriate adapters...
wmic nicconfig where TcpipNetbiosOptions=0 call SetTcpipNetbios 2 >nul 2>&1
wmic nicconfig where TcpipNetbiosOptions=1 call SetTcpipNetbios 2 >nul 2>&1

REM --- DNS Priority Settings ---
echo [INFO] Setting DNS provider priority...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "LocalPriority" /t REG_DWORD /d 4 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "HostsPriority" /t REG_DWORD /d 5 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "DnsPriority" /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "NetbtPriority" /t REG_DWORD /d 7 /f >nul 2>&1

REM --- Flush DNS Cache ---
echo [INFO] Flushing DNS cache...
ipconfig /flushdns >nul

echo.
echo Network optimizations applied successfully.
echo It is recommended to RESTART your computer for all changes to take effect.
echo.
pause
exit /b 0