[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$TaskSequence,

    [Parameter(Mandatory=$false)]
    [hashtable]$Context = @{},

    [Parameter(Mandatory=$false)]
    [Switch]$Validate
)

Begin
{
    $tasksPath = Join-Path -Path $(Get-Location) -ChildPath "tasks"

}

Process
{
    $TaskSequence | ForEach-Object {
        $executePath = Join-Path -Path $tasksPath -ChildPath "Run-Task.ps1"
        $Context += & $executePath -TaskName $_ -Context $Context -Validate $Validate -Verbose
    }
}

End
{

}