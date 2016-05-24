# $established = $activeTcp | select-string 'established'
# $listening = $activeTcp | select-string 'listening'
# $wait = $activeTcp | select-string '_wait'

# Write-Host 'Time:' $current -ForegroundColor yellow
# Write-Host 'ESTABLISHED:'.PadRight(20) $established.count
# Write-Host 'LISTENING:'.PadRight(20) $listening.count
# Write-Host '*_WAIT:'.PadRight(20) $wait.count
# Write-Host 'TCP Connections:'.PadRight(20) $activeTcp.count
# Write-Host "---------------"


function Write-Stat([string]$value)
{
    $current = Get-Date
    Write-Host $current.ToString().PadRight(24) -NoNewLine
    Write-Host $value.ToString().PadLeft(5) -ForegroundColor yellow
}

function Write-Header()
{
    Write-Host 'Time'.PadRight(24) 'Active TCP'
}

# just headers
write-header

# set interval and timeout
$timeout = new-timespan -minutes 1
$timer = [diagnostics.stopwatch]::StartNew()

# logging..
while ($timer.elapsed -lt $timeout){
    $activeTcp = (netstat -ano | select-string 'TCP')
    write-stat($activeTcp.count)
    start-sleep -seconds 5
}

write-host "Done"
