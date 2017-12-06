[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$TaskName,

    [Parameter(Mandatory=$true)]
    [hashtable]$Context,

    [Parameter(Mandatory=$false)]
    [Boolean]$Validate
)

Begin
{
    Write-Verbose "$($TaskName)`: Task starts."
    $currentPath = Get-Location
    $root = (Get-Item $currentPath).parent
    $taskPath = [io.path]::combine($currentPath, "tasks" , "$TaskName")
    $logFile = [io.path]::combine($taskPath, "log.txt")

    $configPath = [io.path]::combine($taskPath, "configuration.json")
    $executePath = [io.path]::combine($taskPath, "Execute-Task.ps1")
    $settings = Get-Content -Path $configPath -Raw | ConvertFrom-Json
    
    $settings.RequiredParameters | ForEach-Object -Process {
        if ($Context.ContainsKey($_) -eq $false) {
            Write-Error "$TaskName`: Task failed."
            Write-Error "$TaskName`: Parameter $_ is missing."
            throw "Parameter $_ is missing"
        }
    }
}

Process
{
    if ($Validate)
    {
        $newContext = @{}
        $settings.OutputParameters | ForEach-Object -Process {
            $newContext[$_] = "dummy"
        }
    }
    else
    {
        try
        {
            $newContext = & $executePath -Context $Context -Root $root -LogFile $logFile
        }
        catch
        {
            Write-Error "`n$TaskName`: Task failed with message $($_.Exception.Message)"
            Write-Error "$TaskName`: $($_.Exception)"
        }
    }
    return $newContext
}

End
{
    Write-Verbose "$($TaskName)`: Task ended."
}