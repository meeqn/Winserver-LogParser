#.\iis_parser.ps1 -startDate "11/08/2023 09:37:00 PM" -endDate "11/08/2023 9:40:00 PM"

param (
    [DateTime]$startDate,
    [DateTime]$endDate
)

$logsDirectory = "C:\inetpub\logs\wmsvc\W3SVC1"

# Pobierz listę plików z określonego katalogu
$files = Get-ChildItem -Path $logsDirectory -Filter "ex*.log"


[Regex]$regex = '^(?<date>[\d-]+)\s(?<time>[\d\:]+)\s(?<ServerIP>[\d\.:a-fA-F%]+)\s(?<method>\S+)\s(?<path>\S+)\s(?<querystring>\S+)\s(?<port>\d+)\s(?<username>\S+)\s(?<clientIP>[\d\.:a-fA-F%]+)\s(?<browser>\S+)\s(?<fulluri>\S+)\s(?<HttpStatus>\d+)\s(?<a>\d+)\s(?<b>\d+)\s(?<c>\d+)$'




foreach ($file in $files) {
Get-Content $file.FullName | ForEach-Object {
    # Sprawdź, czy linia zawiera dane zgodne z formatem logów
    if ($_ -match '^\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}\s' -and $_ -match '\s+') {
        # Spróbuj dopasować linie do wyrażenia regularnego
        if ($_ -match $regex) {
                $logObject = [PSCustomObject]$Matches
                $fullDate =  $logObject.date + " " + $logObject.time
                $date = [DateTime]::ParseExact($fullDate, "yyyy-MM-dd HH:mm:ss", $null)
                if (($date -ge $startDate) -and ($date -le $endDate)) {
                    # Wypisz wybrane pola z obiektu
                    echo "Date: $($logObject.date), Time: $($logObject.time), Method: $($logObject.method), Path: $($logObject.path), Username: $($logObject.username)"
                }
        } else {

            throw "Unexpected line format: '$_'"
        }
    }
}
}