param(
  [int]$threshold = 5000,
  [string]$file = '.\handle.log',
  [string]$process = 'svchost*'
)

function Get-HandleCount([String]$process)
{
  $path = '\Process(' + $process + ')\Handle Count'
  $counter = Get-Counter $path
  return $counter.CounterSamples
}

function Log-Counter([object[]] $items)
{
  $date = Get-Date -format 'yyyy-MM-dd hh:mm:ss z'
  $output = $items | format-table -property Path, CookedValue -auto
  Write-Log $date
  Write-Log $output
  Write-Output $output
}

function Write-Log([object] $info)
{
  $info | Out-File $file -Append -Encoding ascii
}

# check if threshold is exceeded..
[array]$found = (Get-HandleCount $process | where {$_.CookedValue -gt $threshold})

if($found.length -gt 0)
{
  Write-Host 'Handle Count threshold is exceeded! >' $threshold -foregroundcolor DarkRed
  Log-Counter $found
}
else
{
  Write-Host 'OK, seems good.' -foregroundcolor green
}

# cleanup
Remove-Variable found
