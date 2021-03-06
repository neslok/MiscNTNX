
# ########## Define variables for execution ############
# Update with information specific to your environment #
########################################################

$clusterdeets = Import-Csv /Users/keith.olsen/Documents/GitHub/MiscNTNX/clusters.csv # csv file with cluster details (IP, userid, password)

# Establishes variables for cluster details

foreach ($c in $clusterdeets) {
  $prismtIP = $c.IP
  $RESTAPIUser = $c.login
  $RESTAPIPassword = $c.password
  $IMGannotation = $c.Annotation
  $IMGname = $c.Img_Name
  $IMGtype = $c.IMG_Type
  $IMGurl =$c.IMG_URL

  # Creates variable with base API BaseURL

  $BaseURL = "https://" + $prismtIP + ":9440/PrismGateway/services/rest/v2.0/"

  # Creates header file for API calls

  $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $headers.Add("Content-Type", "application/json")
  $headers.Add("Authorization", "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($RESTAPIUser+":"+$RESTAPIPassword)))

  # Get container list

  $CTRlist = Invoke-WebRequest -SkipCertificateCheck $BaseURL'storage_containers' -Method 'GET' -Headers $headers -Body $body | ConvertFrom-Json
  #Write-Host $CTRlist.entities

  foreach ($ctr in $CTRlist.entities) {
      if ($ctr.name -eq "Default"){
        $CTRuuid = $ctr.storage_container_uuid
        $CTRname = $ctr.name
        $CTRid = $ctr.id
        Write-Host  $CTRname, $CTRuuid, $CTRid
      }
    }

    # creates json payload for API call

    $body = "{`n `"annotation`": "+'"'+ $IMGannotation +'"'+", `n `"image_import_spec`": {`n `"storage_container_uuid`": "+'"'+ $CTRuuid +'"'+", `n `"storage_container_name`": "+'"'+ $CTRname +'"'+", `n `"storage_container_id`": $CTRid, `n `"url`": "+'"'+ $IMGurl +'"'+" `n},`n `"image_type`": "+'"'+ $IMGtype +'"'+", `n `"name`": "+'"'+ $IMGname +'"'+" `n }"
    
  Write-Host $body

  $response = Invoke-WebRequest -SkipCertificateCheck $BaseURL'images/' -Method 'POST' -Headers $headers -Body $body
  Write-Host $response.StatusCode

    Write-host "###############################"
  }
