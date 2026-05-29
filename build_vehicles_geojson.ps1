$vehicles = Get-Content .\vehicles.json -Raw | ConvertFrom-Json
$features = foreach($v in $vehicles)
{
    if(-not $v.latitude -or -not $v.longitude)
    {
        continue
    }
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
        }
    }
}
@{
    type = "FeatureCollection"
    features = $features
} |
ConvertTo-Json -Depth 20 |
Set-Content .\vehicles.geojson -Encoding UTF8
Write-Host "vehicles.geojson built"
