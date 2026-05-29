param(
    [double]$Lat,
    [double]$Lon
)

$data = Get-Content .\federal_roads.json -Raw | ConvertFrom-Json

function Dist($lat1,$lon1,$lat2,$lon2){
    [math]::Sqrt(
        [math]::Pow($lat1-$lat2,2) +
        [math]::Pow($lon1-$lon2,2)
    )
}

$result = $data | ForEach-Object {

    [PSCustomObject]@{
        AZS      = $_.AZS
        Route    = $_.RouteName
        KM       = $_.RoutePosition
        DT       = $_.DT
        Distance = [math]::Round(
            (Dist $Lat $Lon $_.Latitude $_.Longitude),
            3
        )
    }
}

$result |
Sort-Object Distance |
Select-Object -First 10 |
Format-Table -AutoSize
