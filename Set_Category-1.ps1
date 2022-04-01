
# ########## Define variables for execution ############
# Update with information specific to your environment #
########################################################

$prismcentIP = "192.168.1.1"
$RESTAPIUser = "admin"
$RESTAPIPassword = "Password"
$VMuuid = "6fd8fce2-0e9a-429c-9270-0bb6758dda66"


# Creates variable with base API BaseURL

$BaseURL = "https://" + $prismcentIP + ":9440/api/nutanix/v3/"
Write-Host $BaseURL

# Creates header file for API calls

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$headers.Add("Authorization", "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($RESTAPIUser+":"+$RESTAPIPassword)))

# Get VM spec

$VMspec = Invoke-WebRequest -SkipCertificateCheck $BaseURL'vms/'$VMuuid -Method 'GET' -Headers $headers

# Update Category - NOTE: assumes current categories is blank - and is updated with Category Name and Value

$VMspec = $VMspec.Content.Replace('"categories": {}', '"categories": {"KOTEST": "KOTEST1"}') | ConvertFrom-Json

# Create Spec and Metadata sections from $VMspec array

$NewSpec = $VMspec.spec | ConvertTo-Json -depth 15
$Newmeta = $VMspec.metadata | ConvertTo-Json -depth 15

# Create body for VM update 

$body = '{"spec":' + $NewSpec + "," + '"metadata": ' + $Newmeta + '}'
#Write-Host $body

# Update VM 

$response = Invoke-RestMethod -SkipCertificateCheck $BaseURL'vms/'$VMuuid -Method 'PUT' -Headers $headers -Body $body
Write-Host $response.StatusCode



