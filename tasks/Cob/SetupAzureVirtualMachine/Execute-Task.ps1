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
    $username = $Context["Cob/AdminUsername"]
    $hostname = $Context["VMHost"]
    $secpasswd = $Context["Cob/AdminPassword"]
    $credential = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)

    $session = New-SSHSession -ComputerName $hostname -Credential $credential
}

Process
{
    $result = Invoke-SSHCommand -Index $session.SessionId -Command "uname"
    $result.Output | ForEach-Object {
        Write-Verbose $_
    }
}

End
{
    Remove-SSHSession -SessionId $sessionId
    return $result
}