# netstat-log-powershell

use to investigate TCP/IP port exhaustion

## usage:

to monitor total active TCP/IP connection by interval time

  `.\log-connections.ps1 [-interval <int>] [-timeout <int>]`

to capture TCP port usage group by PID(process id) and state.

  `.\log-port-usage.ps1`
