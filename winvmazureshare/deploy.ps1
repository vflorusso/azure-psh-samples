## script to create a Storage File Share - get the keys and input them to a VM creation script
$tenantName = "vitolo"
$RGName = $tenantName + "VMFileShare"
$subscriptionName =  "vitolo-internal"
$RGName = $tenantName + "ShareVMRG"
$location = "West Europe"
$stgtemplatefile = "1-azuredeploy-storage.json"
$stgtemplateparameters = "1-azuredeploy-storage.parameters.json"
$vmtemplatefile = "2-azuredeploy-vm.json"
$stgshareName =  $tenantName + "share001"
$pshdscscriptUrl = "https://vitolofiles.blob.core.windows.net/isv/addazureshare.ps1.zip?raw=true"
$vmAdminName = "vitolo"
$vmAdminPwd = "Password.1234"

Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName $subscriptionName


# Create the Resource Group
New-AzureRmResourceGroup -Name $RGName -Location $location


# Deploy the Template to the Resource Group
$stgDeploy = New-AzureRmResourceGroupDeployment -ResourceGroupName $RGName `
                                   -TemplateFile $stgtemplatefile `
                                   -TemplateParameterFile $stgtemplateparameters

# Get information from Template Outputs
$stgName = $stgDeploy.Outputs.storageName.Value
$stgPrimaryKey = $stgDeploy.Outputs.listKeysOutput.Value.keys.First.value.ToString()

# Create Storage context and file share
$stgContext = New-AzureStorageContext -StorageAccountName $stgName -StorageAccountKey $stgPrimaryKey
$stgShare = New-AzureStorageShare -Name $stgshareName  -Context $stgContext

$vmDeployParameters = @{"location"= $location; "newStorageAccountName"= $tenantName + "vmstg01"; "adminUsername"= $vmAdminName; "adminPassword" = $vmAdminPwd; "vmSize" = "Standard_DS1"; "dataDiskSize" = "128"; "dnsNameForPublicIP" = "w2012azureshareip"; "fileshareAccountName" = $stgName; "fileshareAccountKey" = $stgPrimaryKey; "fileshareName" = $stgshareName; "initScriptUrl" = $pshdscscriptUrl}

$vmDeploy = New-AzureRmResourceGroupDeployment -ResourceGroupName $RGName `
                                   -TemplateFile $vmtemplatefile `
                                   -TemplateParameterObject $vmDeployParameters
