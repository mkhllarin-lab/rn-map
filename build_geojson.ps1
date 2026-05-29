$stations = Get-Content .\all_stations.json -Raw | ConvertFrom-Json
$features = foreach($s in $stations)
{
    if(-not $s.Latitude -or -not $s.Longitude)
    {
        continue
    }
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
            azs  = $s.AZS
            dt   = $s.DT
            road = $s.RouteName
            km   = $s.RoutePosition
            addr = $s.Address
        }
    }
}
@{
    type = "FeatureCollection"
    features = $features
} |
ConvertTo-Json -Depth 20 |
Set-Content .\stations.geojson -Encoding UTF8
Write-Host "stations.geojson built"
