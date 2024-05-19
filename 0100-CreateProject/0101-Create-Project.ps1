<#PSScriptInfo
.VERSION 1.0.0.0
.GUID 27ffc3b4-e3f5-4abc-9c55-793fd782bfce
.AUTHOR tom
.COMPANYNAME Brose Fahrzeugteile Se & Co. KG, Bamberg
.COPYRIGHT (c) by tom
.TAGS Script Repository
.RELEASENOTES
2020.06.03_18.51.27 mofified by tom

#> 

<# 
.DESCRIPTION 
Script for Project Plaster
#> 

##end PSScriptInfo
[CmdletBinding(SupportsShouldProcess)]
param(
    [String]
    $DestinationPath,
    [ValidateSet('SRX/SRX-ZIS-RT-WIN', 'SRX/SRX-ZIS-AP', 'SRX/SRX-ZIS-O365', 'ZIS-RT-Win', 'ZIS-AP' )]
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



if ($env:USERDOMAIN -ne $env:COMPUTERNAME) {
    try {
        # Throw 'XX'
        $User = Get-ADUser $env:USERNAME -Properties DisplayName, Company, mail
        if (!$User.Company) {
            $User.Company = $env:USERDOMAIN
        }
    }
    catch {

        $User = [PSCustomObject]@{
            # DisplayName = 'Naumann, Thomas der 1te'
            DisplayName = 'Naumann, Thomas'
            Company     = $env:USERDOMAIN
        }
    }
}
else {
    $User = [PSCustomObject]@{
        # DisplayName = 'Naumann, Thomas der 1te'
        DisplayName = 'Naumann, Thomas'
        Company     = 'Toms PS Wonderland'
    }
}

# $Company = 'Brose Fahrzeugteile Se & Co. KG, Bamberg'

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
    CompanyName              = $User.Company
    Date                     = Get-Date -UFormat %Y-%m-%d
}


$plaster | Out-String
# break
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


# git remote add origin https://github.com/TomN174/Plaster.git
# git push -u origin master

#Script ends here
$Log.StopTime = Get-Date
Write-Host
Write-Host -ForegroundColor DarkGray "Script Runtime $($Log.StopTime -$Log.StartTime)"
$br | Out-Null
