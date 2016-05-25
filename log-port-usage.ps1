# process information from netstat -abno requires Administrator permission

function Get-Usages ()
{
    $list = New-Object System.Collections.HashTable

    $tcpStat = netstat -ano | select-string -pattern 'TCP\s+(.+)\:(\d+)\s+(.+)\:(\d+)\s+(\w+)\s+(\d+)'
    $tcpStat | foreach-object {
        $match = $_.Matches[0]
        # $localAddr = $match.groups[1].value
        # $localPort = $match.groups[2].value
        # $remoteAddr = $match.groups[3].value
        # $remotePort = $match.groups[4].value
        $state = $match.groups[5].value
        $id = $match.groups[6].value

        if($list.ContainsKey($id))  #already exists
        {
            $item = $list[$id]
            $list[$id] = Add-Usage $item $state
        }
        else    #new process
        {
            $item = New-Process $id $state
            $item = Add-Usage $item $state
            $list.Add($id,$item)
        }
    }

    write-host 'Total:' $tcpStat.count -ForegroundColor cyan

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

$out = Get-Usages | Sort-Object -Property Total -Descending | Format-Table -AutoSize
Write-Output $out
