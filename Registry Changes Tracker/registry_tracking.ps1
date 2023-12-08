#run data format "mm/dd/yyyy hh:mm:ss (AM/PM)" 
# ./registry_tracking -dateFrom '11/25/2023 8:22:07 PM' -dateTo '11/25/2023 8:23:00 PM'
param(

    [DateTime]$dateFrom = 0,
    [DateTime]$dateTo = 0
)
if($dateFrom -eq 0 -and $dateTo -eq 0){
    $main_inst = Get-WinEvent -FilterHashTable @{LogName="Security"; ID=4657,4663}
}
elseif($dateFrom -eq 0 -and $dateTo -ne 0){
    $dateTo = Get-date $dateTo
    $main_inst = Get-WinEvent -FilterHashTable @{LogName="Security"; ID=4657,4663; EndTime=$dateTo}
}
elseif($dateForm -ne 0 -and $dateTo -eq 0){
    $dateFrom = Get-date $dateFrom
    $main_inst = Get-WinEvent -FilterHashTable @{LogName="Security"; ID=4657,4663; StartTime=$dateFrom}
}
else{
    $dateFrom = Get-Date $dateFrom
    $dateTo = Get-date $dateTo
    $main_inst = Get-WinEvent -FilterHashTable @{LogName="Security"; ID=4657,4663; StartTime=$dateFrom; EndTime=$dateTo}
}

    $main_inst |
    Select-Object ID,
    TimeCreated,
    @{n='About'; e={"Changes in key value"}},
    @{n='Domain'; e={$_.Properties[2].Value}}, 
    @{n='User'; e={$_.Properties[1].Value}},
    @{n='Object'; e={$_.Properties[4].Value}},
    @{n='ValName'; e={$_.Properties[5].Value}},
    @{n='OpType'; e={$_.Properties[7].Value}},
    @{n='OldVal'; e={$_.Properties[9].Value}},
    @{n='NewVal'; e={$_.Properties[11].Value}} | Where-Object ID -EQ "4657"

    $main_inst |
    Select-Object ID,
    TimeCreated,
    @{n='About'; e={"Key was deleted"}},
    @{n='Domain'; e={$_.Properties[2].Value}}, 
    @{n='User'; e={$_.Properties[1].Value}},
    @{n='Type'; e={$_.Properties[5].Value}},
    @{n='Object'; e={$_.Properties[6].Value}},
    @{n='AccessMask'; e={$_.Properties[9].Value}}|
    Where-Object {$_.ID -eq 4663 -and $_.AccessMask -eq 0x10000} 

    $main_inst |
    Select-Object ID,
    TimeCreated,
    @{n='About'; e={"Key was created"}},
    @{n='Domain'; e={$_.Properties[2].Value}}, 
    @{n='User'; e={$_.Properties[1].Value}},
    @{n='Type'; e={$_.Properties[5].Value}},
    @{n='Object'; e={$_.Properties[6].Value}},
    @{n='AccessMask'; e={$_.Properties[9].Value}}|
    Where-Object {$_.ID -eq 4663 -and $_.AccessMask -eq 0x6}
