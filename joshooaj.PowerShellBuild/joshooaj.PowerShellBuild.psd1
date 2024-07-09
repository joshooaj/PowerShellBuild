@{
    RootModule        = 'joshooaj.PowerShellBuild.psm1'
    ModuleVersion     = '0.6.2'
    GUID              = '47fe082e-9178-405d-b332-90c8865ec239'
    Author            = 'Brandon Olin'
    CompanyName       = 'Community'
    Copyright         = '(c) Brandon Olin. All rights reserved.'
    Description       = 'A common psake and Invoke-Build task module for PowerShell projects'
    PowerShellVersion = '3.0'
    RequiredModules   = @(
        @{ModuleName = 'BuildHelpers';     ModuleVersion = '2.0.16'}
        @{ModuleName = 'Pester';           ModuleVersion = '5.1.1'}
        @{ModuleName = 'joshooaj.platyPS'; ModuleVersion = '0.15.12'}
        @{ModuleName = 'psake';            ModuleVersion = '4.9.0'}
    )
    FunctionsToExport = @(
        'Build-PSBuildMAMLHelp'
        'Build-PSBuildMarkdown'
        'Build-PSBuildModule'
        'Build-PSBuildUpdatableHelp'
        'Clear-PSBuildOutputFolder'
        'Initialize-PSBuild'
        'Publish-PSBuildModule'
        'Test-PSBuildPester'
        'Test-PSBuildScriptAnalysis'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @('*tasks')
    PrivateData       = @{
        PSData = @{
            Tags         = @('psake', 'build', 'InvokeBuild')
            LicenseUri   = 'https://raw.githubusercontent.com/joshooaj/PowerShellBuild/master/LICENSE'
            ProjectUri   = 'https://github.com/joshooaj/PowerShellBuild'
            IconUri      = 'https://raw.githubusercontent.com/joshooaj/PowerShellBuild/master/media/psaketaskmodule-256x256.png'
            ReleaseNotes = 'https://raw.githubusercontent.com/joshooaj/PowerShellBuild/master/CHANGELOG.md'
        }
    }
}
