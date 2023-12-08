#run data format "mm/dd/yyyy hh:mm:ss (AM/PM)" 
# ./failed_logins -dateFrom '11/25/2023 8:22:07 PM' -dateTo '11/25/2023 8:23:00 PM'
param(
    [switch]$detailed=$false,
    [switch]$remoteOnly = $false,
    [switch]$localOnly = $false,

    [DateTime]$dateFrom = 0,
    [DateTime]$dateTo = 0
)

if($dateFrom -eq 0 -and $dateTo -eq 0){
    $main_inst = Get-WinEvent -FilterHashTable @{LogName="Security"; ID=4625}
}
elseif($dateFrom -eq 0 -and $dateTo -ne 0){
    $dateTo = Get-date $dateTo
    $main_inst = Get-WinEvent -FilterHashTable @{LogName="Security"; ID=4625; EndTime=$dateTo}
}
elseif($dateForm -ne 0 -and $dateTo -eq 0){
    $dateFrom = Get-date $dateFrom
    $main_inst = Get-WinEvent -FilterHashTable @{LogName="Security"; ID=4625; StartTime=$dateFrom}
}
else{
    $dateFrom = Get-Date $dateFrom
    $dateTo = Get-date $dateTo
    $main_inst = Get-WinEvent -FilterHashTable @{LogName="Security"; ID=4625; StartTime=$dateFrom; EndTime=$dateTo}
}

if($remoteOnly){
     $main_inst = $main_inst | Where-Object {$_.Message -match '.*Logon Type:\s*3.*'} 
}
elseif($localOnly){
     $main_inst = $main_inst | Where-Object {$_.Message -match '.*Logon Type:\s*2.*'} 
}

if($detailed){
   $main_inst | Select-Object TimeCreated, Message | Format-Table -Wrap
}
else{
    $main_inst |
    Select-Object TimeCreated,
    @{n='Domain'; e={$_.Properties[6].Value}}, 
    @{n='User'; e={$_.Properties[5].Value}}, 
    @{n='Source IP'; e={$_.Properties[19].Value}},  
    @{n='LogonType'; e={$_.Properties[10].Value}}
}