$softwareList = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*,
                                 HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
                Select-Object DisplayName, InstallDate, InstallLocation, PSPath |
                Where-Object { $_.DisplayName -ne $null }

$numberRepaired=0
$noInstallDate = $softwareList | Where-Object { $_.InstallDate -eq $null }
    foreach ($software in $noInstallDate) {
        if($software.InstallLocation -ne $null){
            $path = $software.InstallLocation.Substring(0, $software.InstallLocation.Length - 1)
            $dateDir = Get-Item -LiteralPath $path
            $regDate = $dateDir.CreationTime.ToString("yyyyMMdd")
            Set-ItemProperty -Path $software.PSPath -Name "InstallDate" -Value $regDate
            $numberRepaired = $numberRepaired + 1
        }
    }
echo "$($numberRepaired) dates were corrected"