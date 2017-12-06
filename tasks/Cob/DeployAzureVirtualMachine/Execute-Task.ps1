[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [hashtable]$Context,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$LogFile,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Root
)

Begin
{
    $result = @{}
    $location = $Context["Cob/Location"]
    $resourceName = $Context["Cob/ResourceName"]
    $username = $Context["Cob/AdminUsername"]
    $password = $Context["Cob/AdminPassword"]
    $templateFile = $Context["Cob/TemplateUri"]

    $parameters = @{}
    $parameters.Add("resourceName", $resourceName)
    $parameters.Add("adminUsername", $username)
    $parameters.Add("adminPassword", $password)

    Write-Verbose "ResourceName: $resourceName"
    Write-Verbose "Username: $username"
    Write-Verbose "TemplateUri: $templateFile"
}

Process
{
    $operation = "Ready to deploy $resourceName"
    $target = "Region: $location"

    if ($PSCmdlet.ShouldProcess($target, $operation))
    {
        $resourceGroup = New-AzureRmResourceGroup -Location $location -Name $resourceName -Force
        $deployment = New-AzureRmResourceGroupDeployment -Name $($resourceName + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
            -ResourceGroupName $resourceName `
            -TemplateFile $templateFile `
            -TemplateParameterObject $parameters `
            -Force -Verbose `
            -ErrorVariable ErrorMessage
    }
}

End
{
    $result.Add("ResourceGroup", $resourceGroup)
    $result.Add("VMDeployment", $deployment)
    $result.Add("VMHost", "$($resourceName.ToLower()).$($location.ToLower()).cloudapp.azure.com")
    return $result
}