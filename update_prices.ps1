$Login = "CUBQ2026"
$Password = "CUBI2026pro"
$Contract = "ISS246373"

$headers = @{
    'RnCard-Identity-Account-Pass' = [Convert]::ToBase64String(
        [Text.Encoding]::UTF8.GetBytes($Password)
    )
}

$uri = "https://lkapi.rn-card.ru/api/emv/v2/GetPOSList?u=$Login&contract=$Contract&flagActiveOnly=Y&goodsInfo=Y&type=JSON"

$result = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers

$result |
ForEach-Object {

    $dt = $_.GoodsPriceList |
        Where-Object {$_.GoodsCode -eq "gDT"} |
        Select-Object -First 1

    [PSCustomObject]@{
        ID            = $_.ID
        Code          = $_.Code
        BrandName     = $_.BrandName
        AZS           = "$($_.BrandName) $($_.Name)"
        Address       = $_.Address
        Latitude      = $_.Latitude
        Longitude     = $_.Longitude
        DT            = $dt.Price
        RouteName     = $_.RouteName
        RoutePosition = $_.RoutePosition
        RegionCode    = $_.RegionCode
    }
} |
ConvertTo-Json -Depth 10 |
Set-Content "$PSScriptRoot\prices.json" -Encoding UTF8

Write-Host "prices.json РѕР±РЅРѕРІР»РµРЅ"

Get-Content ".\prices.json" -Raw |
ConvertFrom-Json |
Where-Object {
    $_.Address -match "Рњ1"
} |
ConvertTo-Json -Depth 10 |
Set-Content ".\m1.json" -Encoding UTF8

powershell -ExecutionPolicy Bypass -File ".\generate_map.ps1"



