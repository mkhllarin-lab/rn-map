$data = Get-Content ".\m1.json" -Encoding UTF8 -Raw | ConvertFrom-Json

$jsonData = $data | ConvertTo-Json -Depth 10 -Compress

$updateTime = (Get-Date).ToString("dd.MM.yyyy HH:mm:ss")

$html = @"
<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="utf-8">
<title>АЗС М1 Смоленская область</title>

<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>

<style>
html,body,#map{
height:100%;
margin:0;
padding:0;
}

.info{
position:absolute;
top:10px;
left:60px;
z-index:1000;
background:white;
padding:10px;
border-radius:8px;
box-shadow:0 0 5px rgba(0,0,0,.3);
font-family:Arial;
font-size:14px;
}
</style>

</head>

<body>

<div class="info">
<b>АЗС М1 (Смоленская область)</b><br>
Обновлено: $updateTime
</div>

<div id="map"></div>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<script>

var map = L.map('map');

L.tileLayer(
'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
{
maxZoom:19
}
).addTo(map);

const stations = $jsonData;

const bounds = [];

stations.forEach(p => {

    bounds.push([p.Latitude,p.Longitude]);

    let color = 'blue';

    if (p.DT < 76.15)
        color = 'green';

    if (p.DT > 76.15)
        color = 'red';

    const marker = L.circleMarker(
        [p.Latitude,p.Longitude],
        {
            radius:8,
            color:color,
            fillColor:color,
            fillOpacity:0.8
        }
    );

    marker.addTo(map);

    

    marker.bindPopup(
        '<b>' + p.AZS + '</b><br>' +
        p.Address +
        '<br><b>KM:</b> ' + p.KM +
        '<br><b>DT:</b> ' + p.DT + ' RUB/L'
    );
});

map.fitBounds(bounds);

</script>

</body>
</html>
"@

[System.IO.File]::WriteAllText(
    ".\index.html",
    $html,
    [System.Text.UTF8Encoding]::new($false)
)

Write-Host "Карта обновлена"





