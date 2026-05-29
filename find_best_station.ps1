param(
    [double]$Lat,
    [double]$Lon,
    [string]$Direction = "forward"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Dist($lat1,$lon1,$lat2,$lon2)
{
    [math]::Sqrt(
        [math]::Pow($lat1-$lat2,2) +
        [math]::Pow($lon1-$lon2,2)
    )
}

$data = Get-Content .\stations_master.json -Raw | ConvertFrom-Json

# Определяем ближайшую АЗС и текущую трассу

$nearest = $data |
ForEach-Object {

    [PSCustomObject]@{
        RoadCode      = $_.RoadCode
        RoadName      = $_.RoadName
        RoutePosition = [double]$_.RoutePosition
        Distance      = Dist $Lat $Lon $_.Latitude $_.Longitude
    }

} |
Sort-Object Distance |
Select-Object -First 1

$roadCode  = $nearest.RoadCode
$currentKM = $nearest.RoutePosition

Write-Host ""
Write-Host "Трасса: $roadCode"
Write-Host "Текущий км: $currentKM"
Write-Host "Направление: $Direction"
Write-Host ""

if ($Direction -eq "forward")
{
    $result = $data | Where-Object {
        $_.RoadCode -eq $roadCode -and
        ([double]($_.RoutePosition) -gt $currentKM)
    }
}
else
{
    $result = $data | Where-Object {
        $_.RoadCode -eq $roadCode -and
        ([double]($_.RoutePosition) -lt $currentKM)
    }
}

$result |
Sort-Object RoutePosition |
Select-Object AZS,RoutePosition,DT,Address -First 10 |
Format-Table -AutoSize