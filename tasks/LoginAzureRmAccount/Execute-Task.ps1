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
}

Process
{
    try
    {
        $azureRmContext = Get-AzureRmContext
    }
    catch [Exception]
    {
        Login-AzureRmAccount
    }


    $azureRmContext = Get-AzureRmContext

    if ($azureRmContext -eq $null) {
        & $Root\utils\Write-Log -Log "Failed to get Azure context" -File $LogFile
        throw "Failed to get Azure context"
    }

    $result.Add("AzureRmContext", $azureRmContext)
}

End
{
    return $result
}