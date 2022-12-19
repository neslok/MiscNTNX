
# ########## Define variables for execution ############
# Update with information specific to your environment #
########################################################

$prismcentIP = "10.42.156.40"
$RESTAPIUser = "admin"
$RESTAPIPassword = "nx2Tech156!"
$VMfilter = "ko"
$CatName = "KOTEST"
$CatValue = "KOTEST2"


# Creates variable with base API BaseURL

$BaseURL = "https://" + $prismcentIP + ":9440/api/nutanix/v3/"
Write-Host $BaseURL

# Creates header file for API calls

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$headers.Add("Authorization", "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($RESTAPIUser+":"+$RESTAPIPassword)))


# Get VMs - NOTE - update "length" as required based on total number of VMs in PC

$body = '{"kind": "vm",
        "length": 200   
        }'

$Vmlist = Invoke-WebRequest -SkipCertificateCheck $BaseURL'vms/list' -Method 'POST' -Headers $headers -Body $body | ConvertFrom-Json

# filter for string in VM Name

foreach ($vm in $Vmlist.entities) {
    if ($vm.spec.name -like "*" + $VMfilter + "*") {
            $VMuuid = $vm.metadata.uuid
            Write-Host $VMuuid

            # Get VM spec

            $VMspec = Invoke-WebRequest -SkipCertificateCheck $BaseURL'vms/'$VMuuid -Method 'GET' -Headers $headers

            # Update Category - NOTE: assumes current categories is blank - and is updated with Category Name and Value

            $VMspec = $VMspec.Content.Replace('"categories": {}', '"categories": {"' + $CatName + '": "' + $CatValue + '"}') | ConvertFrom-Json

            # Create Spec and Metadata sections from $VMspec array

            $NewSpec = $VMspec.spec | ConvertTo-Json -depth 15
            $Newmeta = $VMspec.metadata | ConvertTo-Json -depth 15

            # Create body for VM update 

            $body = '{"spec":' + $NewSpec + "," + '"metadata": ' + $Newmeta + '}'
            #Write-Host $body

            # Update VM 

            $response = Invoke-WebRequest -SkipCertificateCheck $BaseURL'vms/'$VMuuid -Method 'PUT' -Headers $headers -Body $body
            Write-Host $response.StatusDescription
    }
}



