function New-Script {
    <#
			.SYNOPSIS
			Short Description
			.DESCRIPTION
			Detailed Description
			.EXAMPLE
			Update-ScriptVersion
			explains how to use the command
			can be multiple lines
			.EXAMPLE
			Update-ScriptVersion
			another example
			can have as many examples as you like
	#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false, Position = 0)]
        [System.String]
        $Path = $null,
		
        [Parameter(Mandatory = $false, Position = 1)]
        [System.String]
        $Author,
		
        [Parameter(Mandatory = $false, Position = 2)]
        [System.String]
        $CompanyName = 'Brose Fahrzeugteile',
		
        [Parameter(Mandatory = $false, Position = 3)]
        [System.String]
        $CopyRight,
		
        [Parameter(Mandatory = $false, Position = 4)]
        [System.String]
        $Description = 'There Should be a Description',
		
        [Parameter(Mandatory = $false, Position = 5)]
        [System.String]
        $Tags = 'Script Repository'
    )
    $AdUSer = Get-ADUser $env:USERNAME
    if (!$Author) {
        $Author = "$($AdUSer.GivenName) $($AdUSer.Surname) "
    }
    if (!$CopyRight) {
        $CopyRight = "$($AdUSer.GivenName) $($AdUSer.Surname) "
    }
    

    $Logdate = ('{0:yyyy.MM.dd_HH.mm.ss}' -f (Get-Date))	
	
    $NewVersion = '1.0.0.0'
    $ScriptReleaseNotes = "$LogDate mofified by $env:USERNAME"
    $ScriptGuId = [guid]::NewGuid()
    $ScriptAuthor = $Author
    $ScriptCompanyName = $CompanyName
    $ScriptCopyRight = "(c) by $CopyRight"
    $ScriptDescription = $Description
    $ScriptTags = $Tags
	
	
	
    $Header1 = @"
<#PSScriptInfo
.VERSION $NewVersion
.GUID $ScriptGuId
.AUTHOR $ScriptAuthor
.COMPANYNAME $ScriptCompanyName
.COPYRIGHT $ScriptCopyRight
.TAGS $ScriptTags
.RELEASENOTES
$ScriptReleaseNotes

#> 

<# 
.DESCRIPTION 
$ScriptDescription
#> 

##end PSScriptInfo

"@

    $Header2 = @'
[CmdletBinding(SupportsShouldProcess)]
param()

#region StandardObjects V 1.0

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
$ProjectPath = $PathArrayList -join '\'
while ((!(Test-Path "$($PathArrayList -join '\')\Readme.md")) -and ($PathArrayList.Count -gt 0)) {
    $PathArrayList.RemoveAt($PathArrayList.Count - 1)
    $ProjectPath = $PathArrayList -join '\'
} 
#endregion
#region load project module
if ($ProjectPath) {
    $ProjectName = (Get-Content $ProjectPath\README.md -TotalCount 1).Replace('## ', '')
    $ModuleName = $ProjectName + "Module"
    $ModulePath = "$ProjectPath\$ModuleName"
    if (Test-Path $ModulePath) {
        Import-Module $ModulePath -Force #-Verbose
    }
}

#endregion load project module

#Script starts here




#Script ends here

$Log.StopTime = Get-Date
Write-Host
Write-Host -ForegroundColor DarkGray "Script Runtime $($Log.StopTime -$Log.StartTime)"
$br |Out-Null


'@
    $Header = $Header1 + $Header2
    if ($psISE) {
    
        $IseTab = $psISE.CurrentPowerShellTab.Files.Add()
        $IseTab.Editor.InsertText($Header)
        #$psISE.CurrentFile.Editor.InsertText($Clip)    
    }

    elseif ($psEditor) {
        Write-Host 'VsCode'
        $psEditor.Workspace.NewFile()
        #$psEditor
        $psEditor.GetEditorContext().CurrentFile.InsertText($Header)
        
    }

}
