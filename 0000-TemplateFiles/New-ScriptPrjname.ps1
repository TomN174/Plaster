function New-Script<%= $PLASTER_PARAM_Project %> {
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
        $CompanyName = '<%= $PLASTER_PARAM_CompanyName %>',
		
        [Parameter(Mandatory = $false, Position = 3)]
        [System.String]
        $CopyRight,
		
        [Parameter(Mandatory = $false, Position = 4)]
        [System.String]
        $Description = 'Script for Project <%= $PLASTER_PARAM_Project %>',
		
        [Parameter(Mandatory = $false, Position = 5)]
        [System.String]
        $Tags = 'Script Repository'
    )
    if ($env:USERDNSDOMAIN) {
        $AdUSer = Get-ADUser $env:USERNAME
        if (!$Author) {
            $Author = "$($AdUSer.GivenName) $($AdUSer.Surname) "
        }
        if (!$CopyRight) {
            $CopyRight = "$($AdUSer.GivenName) $($AdUSer.Surname) "
        }
    }
    else {
        if (!$Author) {
            $Author = $env:USERNAME
        }
        if (!$CopyRight) {
            $CopyRight = $env:USERNAME
        }
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
