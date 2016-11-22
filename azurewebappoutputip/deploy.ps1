
Login-AzureRmAccount

$SubscriptionName = "[Azure-subscription]"
Select-AzureRmSubscription -SubscriptionNAme $SubscriptionName

$RGName = "[webapprg]"
$location = "West Europe"
$templatefile = "webappdeploy.json"
$templateparameters = "webappdeploy.parameters.json"



# Create a Resource Group
New-AzureRmResourceGroup -Name $RGName -Location $location
 
# Deploy the Template to the Resource Group
New-AzureRmResourceGroupDeployment -ResourceGroupName $RGName `
                                   -TemplateFile $templatefile `
                                   -TemplateParameterFile $templateparameters