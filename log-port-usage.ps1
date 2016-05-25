# process information from netstat -abno requires Administrator permission

function Get-Usages ()
{
    $list = New-Object System.Collections.HashTable

    $tcpStat = netstat -ano | Select-String -Pattern 'TCP\s+(.+)\:(\d+)\s+(.+)\:(\d+)\s+(\w+)\s+(\d+)'
    $tcpStat | Foreach-Object {
        $match = $_.Matches[0]
        $state = $match.groups[5].value
        $id = $match.groups[6].value

        if($list.ContainsKey($id))  #already exists
        {
            $item = $list[$id]
            $list[$id] = Add-Usage $item $state
        }
        else    #new process
        {
            $item = New-Process $id
            $item = Add-Usage $item $state
            $list.Add($id,$item)
        }
    }
    Write-Host 'Total:' $tcpStat.Count -ForegroundColor cyan

    return $list.Values
}

function New-Process([int]$id)
{
    $info = New-Object PSObject
    Add-Member -InputObject $info -MemberType 'NoteProperty' -Name 'PID' -Value $id
    Add-Member -InputObject $info -MemberType 'NoteProperty' -Name 'Established' -Value 0
    Add-Member -InputObject $info -MemberType 'NoteProperty' -Name 'Listening' -Value 0
    Add-Member -InputObject $info -MemberType 'NoteProperty' -Name 'Wait' -Value 0
    Add-Member -InputObject $info -MemberType 'NoteProperty' -Name 'Total' -Value 0

    return $info
}

function Add-Usage([object]$item, [string]$state)
{
    $item.Total ++

    if($state -like 'ESTABLISHED')
    {
        $item.Established ++
    }
    if($state -like 'Listening')
    {
        $item.Listening ++
    }
    if($state.EndsWith('_WAIT'))
    {
        $item.Wait ++
    }

    return $item
}

# start collect usage statistic.
$file = '.\usage.log'
Get-Date -Format 'yyyy-MMM-dd hh:mm:ss z' >> $file

$output = Get-Usages | Sort-Object -Property Total -Descending | Format-Table -AutoSize
$output | Out-File $file -Append -Encoding utf8
Write-Output $output

# cleanup
Remove-Variable file
Remove-Variable output
