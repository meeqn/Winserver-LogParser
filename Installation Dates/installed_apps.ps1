# .\installed_apps.ps1 -startDate '11/25/2023' -endDate '11/26/2023' -hideWarnings
# registry doesn't store data for hour of installation. Inputted start date and end date includes the day given.
param(
    [DateTime]$startDate=0,
    [DateTime]$endDate=0,
    [switch] $hideWarnings = $false
)

$softwareList = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*,
                                 HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
                Select-Object DisplayName, Publisher, InstallDate, DisplayVersion, InstallLocation |
                Where-Object { $_.DisplayName -ne $null }

if($startDate -ne 0 -and $endDate -ne 0){
    $installedInRange = $softwareList | Where-Object {
        if ($_.InstallDate) {
            if($_.InstallDate -match '[0-9]{8}'){
                $installDate = [DateTime]::ParseExact($_.InstallDate, "yyyyMMdd", $null)
            }
            elseif($_.InstallDate -match '[0-9]{2}\.[0-9]{2}\.[0-9]{4}'){
                $installDate = [DateTime]::ParseExact($_.InstallDate, "dd.mm.yyyy", $null)
            }
            $installDate -ge $startDate -and $installDate -le $endDate
        }
    }
    echo "Installed Software within the specified date range:" " "
    foreach ($software in $installedInRange | Sort-Object { $_.DisplayName }) {
        echo "Name: $($software.DisplayName)"
        echo "Publisher: $($software.Publisher)"
        echo "Version: $($software.DisplayVersion)"
        $installDate = [DateTime]::ParseExact($software.InstallDate, "yyyyMMdd", $null)
        echo "Install Date: $($installDate.ToString('yyyy-MM-dd'))"
        if($software.InstallLocation -ne $null -and $software.InstallLocation.Length -gt 0){
            echo "Install Location: $($software.InstallLocation)"
        }
        echo "______________________________________________"    
    }
}
else{
    echo "Installed Software"
    foreach ($software in $softwareList | Sort-Object { $_.DisplayName }) {
        echo "Name: $($software.DisplayName)"
        echo "Publisher: $($software.Publisher)"
        echo "Version: $($software.DisplayVersion)"
        if($software.InstallDate -ne $null -and $software.InstallDate.Length -gt 0){
            $installDate = [DateTime]::ParseExact($software.InstallDate, "yyyyMMdd", $null)
            echo "Install Date: $($installDate.ToString('yyyy-MM-dd'))"
        }
        if($software.InstallLocation -ne $null -and $software.InstallLocation.Length -gt 0){
            echo "Install Location: $($software.InstallLocation)"
        }
        echo "______________________________________________"    
    }
}

if($hideWarnings -eq $false){
    $noInstallDate = $softwareList | Where-Object { $_.InstallDate -eq $null }
    echo " "
    Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red
    Write-Host "WARNING! No date specified for following software:" -ForegroundColor Red
    foreach ($software in $noInstallDate | Sort-Object { $_.DisplayName }) {
        Write-Host "Name: $($software.DisplayName)" -ForegroundColor Red
        Write-Host "Publisher: $($software.Publisher)" -ForegroundColor Red
        Write-Host "Version: $($software.DisplayVersion)" -ForegroundColor Red
        if($software.InstallLocation -ne $null -and $software.InstallLocation.Length -gt 0){
            Write-Host "Install Location: $($software.InstallLocation)" -ForegroundColor Red
        }
        echo "______________________________________________"
    }
}
