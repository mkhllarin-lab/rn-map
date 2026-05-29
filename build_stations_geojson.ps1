$stations = Get-Content .\stations_master.json -Raw | ConvertFrom-Json

$features = foreach($s in $stations)
{
    @{
        type = "Feature"

        geometry = @{
            type = "Point"
            coordinates = @(
                [double]$s.Longitude,
                [double]$s.Latitude
            )
        }

        properties = @{
            azs      = $s.AZS
            dt       = $s.DT
            road     = $s.RoadName
            roadCode = $s.RoadCode

            roadKm   = [double](
                ($s.RoutePosition -replace ',', '.')
            )

            km       = $s.RoutePosition
            addr     = $s.Address
        }
    }
}

@{
    type     = "FeatureCollection"
    features = @($features)
} |
ConvertTo-Json -Depth 20 |
Set-Content .\stations.geojson -Encoding UTF8

Write-Host ""
Write-Host "stations.geojson rebuilt"
Write-Host "Stations:" $features.Count