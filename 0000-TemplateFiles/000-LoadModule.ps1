<#PSScriptInfo
.VERSION 1.0.0.0
.GUID <%= $PLASTER_Guid5 %>
.AUTHOR <%= $PLASTER_PARAM_Author %>
.COMPANYNAME <%= $PLASTER_PARAM_CompanyName %>
.COPYRIGHT (c) by <%= $PLASTER_PARAM_Author %>
.TAGS <%= $PLASTER_PARAM_Project %>
.RELEASENOTES
<%= $PLASTER_Date %> <%= $PLASTER_Time %> mofified by <%= $PLASTER_PARAM_Author %>

#> 

<# 
.DESCRIPTION 
loading project modules for <%= $PLASTER_PARAM_Project %>
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
# Write-Host "# $ProjectPath #" -ForegroundColor Yellow
#endregion Project Path
#region load project module
if ($ProjectPath) {
    # $ProjectName = (Get-Content $ProjectPath\README.md -TotalCount 1).Replace('## ', '')
    # Write-Host $ProjectName -ForegroundColor Cyan
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