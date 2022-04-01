
# ########## Define variables for execution ############
# Update with information specific to your environment #
########################################################

$clusterdeets = Import-Csv /Users/keith.olsen/Documents/GitHub/MiscNTNX/clusters.csv # csv file with cluster details (IP, userid, password)
$VMuuid = 6fd8fce2-0e9a-429c-9270-0bb6758dda66
# Establishes variables for cluster details

foreach ($c in $clusterdeets) {
  $prismtIP = $c.IP
  $RESTAPIUser = $c.login
  $RESTAPIPassword = $c.password

  # Creates variable with base API BaseURL

  $BaseURL = "https://" + $prismtIP + ":9440/api/nutanix/v3/"

  # Creates header file for API calls

  $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $headers.Add("Content-Type", "application/json")
  $headers.Add("Authorization", "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($RESTAPIUser+":"+$RESTAPIPassword)))

  # Get VM spec
  $VMspec = Invoke-WebRequest -SkipCertificateCheck $BaseURL'vms/'$VMuuid -Method 'GET' -Headers $headers -Body $body | ConvertFrom-Json
  Write-Host $VMspec


    # creates json payload for API call

    $body = "{`n `"annotation`": "+'"'+ $IMGannotation +'"'+", `n `"image_import_spec`": {`n `"storage_container_uuid`": "+'"'+ $CTRuuid +'"'+", `n `"storage_container_name`": "+'"'+ $CTRname +'"'+", `n `"storage_container_id`": $CTRid, `n `"url`": "+'"'+ $IMGurl +'"'+" `n},`n `"image_type`": "+'"'+ $IMGtype +'"'+", `n `"name`": "+'"'+ $IMGname +'"'+" `n }"
    
  Write-Host $body

  $response = Invoke-WebRequest -SkipCertificateCheck $BaseURL'images/' -Method 'POST' -Headers $headers -Body $body
  Write-Host $response.StatusCode

    Write-host "###############################"
  }
