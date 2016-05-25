param(
    [int]$interval = 60,
    [int]$timeout = 60
)

function Run-Interval()
{
    # set interval and timeout
    $timespan = new-timespan -minutes $timeout
    $timer = [diagnostics.stopwatch]::StartNew()

    # logging..
    write-header
    while ($timer.elapsed -lt $timespan){
        $activeTcp = (netstat -ano | select-string 'TCP')
        write-stat $activeTcp.count
        start-sleep -seconds $interval
    }
}

function Write-Header()
{
    $line = 'Time'.PadRight(24) + 'Active TCP'
    write-host $line
    append-log $line
}

function Write-Stat([string]$value)
{
    $now = get-date
    $line = $now.ToString().PadRight(24) + $value.ToString().PadLeft(5)
    write-host $line
    append-log $line
}

function Append-Log([string]$line)
{
    $path = (get-item -path ".\netstat.log").FullName
    # $file = New-Object IO.FileStream $path, 'Append', 'Write', 'Read'
    # $fs = New-Object IO.StreamWriter $file
    # $fs.WriteLine($line)
    # $fs.Close()

    $line | Out-File $path -Append -Encoding utf8
}

Write-Host start monitoring netstat every $interval sec. for $timeout minutes.. -ForegroundColor green
Run-Interval
Write-Host "Done." -ForegroundColor green
