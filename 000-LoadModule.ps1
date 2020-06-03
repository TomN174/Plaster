<#PSScriptInfo
.VERSION 1.0.0.0
.GUID 97cec5a5-741f-45a6-95e6-87275fbe590e
.AUTHOR Naumann, Thomas
.COMPANYNAME Brose Fahrzeugteile Se & Co. KG, Bamberg
.COPYRIGHT (c) by Naumann, Thomas
.TAGS Plaster
.RELEASENOTES
02.04.2020 20:57 mofified by Naumann, Thomas

#> 

<# 
.DESCRIPTION 
loading project modules for Plaster
#> 

##end PSScriptInfo
[CmdletBinding(SupportsShouldProcess)]
param()

#region StandardObjects V 2.0
$Log = [PSCustomObject] @{
    LogDate      = ('{0:yyyy.MM.dd_HH.mm.ss}' -f (Get-Date))
    ScriptAlias  = ($PSCommandPath.split('\')[-1].split('.'))[0]
    ScriptName   = $PSCommandPath.split('\')[-1]
    ScriptPath   = $PSScriptRoot
    UserID       = $env:USERNAME
    Computername = $env:COMPUTERNAME
    Error        = $null
    StartTime    = (Get-Date)
    StopTime     = $null
}
$br = [PSCustomObject] @{
    LogFile = ($Log.ScriptPath + '\' + $Log.ScriptName + '-' + $Log.LogDate + '-Log.txt')
    OutFile = ($Log.ScriptPath + '\' + $Log.ScriptName + '-' + $Log.LogDate + '.txt')
}

#endregion StandardObjects
#region Project Path
[System.Collections.ArrayList]$PathArrayList = $log.ScriptPath.Split('\')

while (!((Test-Path "$($PathArrayList -join '\')\Readme.md") -and (Test-Path "$($PathArrayList -join '\')\Modules") ) -and ($PathArrayList.Count -gt 0)) {
    $PathArrayList.RemoveAt($PathArrayList.Count - 1)
} 
$ProjectPath = $PathArrayList -join '\'
#endregion Project Path
#region load project module
if ($ProjectPath) {
    $Modules = Get-ChildItem $ProjectPath\Modules -Directory
    Import-Module $Modules.FullName -Force -Verbose 
}
#endregion load project module
#Script starts here



#Script ends here
$Log.StopTime = Get-Date
Write-Host
Write-Host -ForegroundColor DarkGray "Script Runtime $($Log.StopTime -$Log.StartTime)"
$br | Out-Null
