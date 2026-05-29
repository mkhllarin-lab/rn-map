$vehicles = Get-Content .\vehicles.json -Raw | ConvertFrom-Json
$stations = Get-Content .\stations_master.json -Raw | ConvertFrom-Json

function Dist($lat1,$lon1,$lat2,$lon2)
{
    [math]::Pow($lat1 - $lat2, 2) +
    [math]::Pow($lon1 - $lon2, 2)
}

$features = foreach($v in $vehicles)
{
    if($null -eq $v.latitude -or $null -eq $v.longitude)
    {
        continue
    }

    $nearest = $stations |
    Sort-Object {
        Dist `
            ([double]$v.latitude) `
            ([double]$v.longitude) `
            ([double]$_.Latitude) `
            ([double]$_.Longitude)
    } |
    Select-Object -First 1

    $roadKm = [double](
        ($nearest.RoutePosition -replace ',', '.')
    )

    @{
        type = "Feature"

        geometry = @{
            type = "Point"
            coordinates = @(
                [double]$v.longitude,
                [double]$v.latitude
            )
        }

        properties = @{
            vehicle   = $v.vehicle
            fuel      = $v.fuel
            speed     = $v.speed
            direction = $v.direction

            roadCode  = $nearest.RoadCode
            roadKm    = $roadKm
        }
    }
}

$geojson = @{
    type     = "FeatureCollection"
    features = @($features)
}

$geojson |
ConvertTo-Json -Depth 20 |
Set-Content .\vehicles.geojson -Encoding UTF8

Write-Host "vehicles.geojson rebuilt"
Write-Host "Vehicles:" $features.Count