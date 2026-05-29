param(
    [double]$Lat,
    [double]$Lon
)

function Dist($lat1,$lon1,$lat2,$lon2)
{
    [math]::Sqrt(
        [math]::Pow($lat1-$lat2,2) +
        [math]::Pow($lon1-$lon2,2)
    )
}

$data = Get-Content .\stations_master.json -Raw | ConvertFrom-Json

$nearest = $data |
ForEach-Object {

    [PSCustomObject]@{
        RoadCode = $_.RoadCode
        RoadName = $_.RoadName
        Distance = Dist $Lat $Lon $_.Latitude $_.Longitude
    }

} |
Sort-Object Distance |
Select-Object -First 1

$nearest | Format-List
