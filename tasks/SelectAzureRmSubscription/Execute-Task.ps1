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
    $subscription = Select-AzureRmSubscription -SubscriptionName $Context["AzureSubscriptionName"]
}

End
{
    $result.Add("AzureRmSubscription", $subscription)
    return $result
}