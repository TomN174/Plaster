<#PSScriptInfo
.VERSION 1.0.0.0
.GUID 878d00b2-2d8a-4e64-b900-d96ba28cca0e
.AUTHOR Thomas Naumann - Tom 
.COMPANYNAME Brose Fahrzeugteile
.COPYRIGHT (c) by Thomas Naumann
.TAGS Tom Version Script Repository
.RELEASENOTES
2018.03.07_13.42.54 mofified by adminthn

#> 

<# 
.DESCRIPTION 
Create new Powershell Project
#> 

##end PSScriptInfo
[CmdletBinding(SupportsShouldProcess)]
param(
    [String]
    $DestinationPath,
    [ValidateSet('SRX/SRX-ZIS-RT-WIN', 'SRX/SRX-ZIS-AP', 'ZIS-RT-Win', 'ZIS-AP' )]
    $Department = 'SRX/SRX-ZIS-RT-WIN',
    # Parameter help description
    [Parameter(
        Mandatory = $true,
        HelpMessage = "Enter a project name"
    )]
    [string]    
    $Project, #= Read-Host -Prompt 'Project Name?'
    [Parameter(
        Mandatory = $true,
        HelpMessage = "Enter a project description"
    )]
    [string]    
    $PrjDescription #= Read-Host -Prompt 'Description?'
)

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
    Site         = $null
}

$br = [PSCustomObject] @{
    LogFile = ($Log.ScriptPath + '\' + $Log.ScriptName + '-' + $Log.LogDate + '-Log.txt')
    OutFile = ($Log.ScriptPath + '\' + $Log.ScriptName + '-' + $Log.LogDate + '.txt')
}

#region Project Path
[System.Collections.ArrayList]$PathArrayList = $log.ScriptPath.Split('\')
$ProjectPath = $PathArrayList -join '\'
while ((!(Test-Path "$($PathArrayList -join '\')\Readme.md")) -and ($PathArrayList.Count -gt 0)) {
    $PathArrayList.RemoveAt($PathArrayList.Count - 1)
    $ProjectPath = $PathArrayList -join '\'
} 
#endregion
#region load project module
if ($ProjectPath) {
    $ProjectName = (Get-Content $ProjectPath\README.md -TotalCount 1).Replace('## ', '')
    $ModulePath = "$ProjectPath\$ProjectName"
    Import-Module $ModulePath -Force #-Verbose 
}
#endregion load project module
# write-host 'dddd'

#Script starts here
If (!$DestinationPath) {
    if (Test-Path D:\git.local ) {
        $DestinationPath = 'D:\Git.Local'
    }
    elseif (Test-Path D:\Git-Local ) {
        $DestinationPath = 'D:\Git-Local'
    }
    elseif (Test-Path c:\git.local ) {
        $DestinationPath = 'C:\Git.Local'
    }
    else {
        Write-Warning  'No DestinationPath found'
        break
    }
    # $DestinationPath
}



if ($env:USERDOMAIN -eq $env:COMPUTERNAME) {
    try {
        $User = Get-ADUser $env:USERNAME -Properties DisplayName 
    }
    catch {

        $User = [PSCustomObject]@{
            # DisplayName = 'Naumann, Thomas der 1te'
            DisplayName = 'Naumann, Thomas'
        }
    }
}
$env:USERNAME


$Company = 'AD-NT'
$Company = 'Brose Fahrzeugteile Se & Co. KG, Bamberg'

$DepartmentRepositoryPath = $Department.Replace('SRX/SRX-', '')

$plaster = [ordered]@{
    DestinationPath          = "$DestinationPath\$Project"
    TemplatePath             = "$ProjectPath\0000-TemplateFiles"
    Project                  = $Project
    Author                   = $User.DisplayName
    ModuleDesc               = $PrjDescription
    Version                  = "1.0.0"
    GitHubUserName           = $env:USERNAME
    GitHubRepo               = $Project
    DepartmentRepositoryPath = $DepartmentRepositoryPath
    CompanyName              = $Company
}


$plaster |Out-String
break
Invoke-Plaster @plaster #-Verbose 

# Write-Host 'Run GIT?' -ForegroundColor Green
# Pause

# $CurrentDir = Get-Location 
# Set-Location $plaster.DestinationPath
# git init 
# git add *
# git commit -m "1st Project Upload"
# git remote add origin git@scm.brose.net:$Department/$Project.git
# git push --set-upstream origin master
# git checkout -b dev
# git push -u origin dev
# git push --set-upstream origin dev

# Set-Location $CurrentDir
# # 'git@scm.brose.net:ZIS-RT-WIN/W2016-DC-Migration.git'


#Script ends here

$Log.StopTime = Get-Date
Write-Host
Write-Host -ForegroundColor DarkGray "Script Runtime $($Log.StopTime -$Log.StartTime)"
$br | Out-Null