Import-Module ../../Output/joshooaj.PowerShellBuild -Force

properties {
    # Pester can build the module using both scenarios
    if (Test-Path -Path 'Variable:\PSBuildCompile') {
        $PSBPreference.Build.CompileModule = $global:PSBuildCompile
    } else {
        $PSBPreference.Build.CompileModule = $true
    }

    # Always copy these
    $PSBPreference.Build.CopyDirectories = ('stuff')

    # Don't ever copy these
    $PSBPreference.Build.Exclude = ('excludeme.txt', 'excludemealso*', 'dontcopy')

    # If compiling, insert headers/footers for entire PSM1 and for each inserted function
    $PSBPreference.Build.CompileHeader       = '# Module Header' + [Environment]::NewLine
    $PSBPreference.Build.CompileFooter       = '# Module Footer'
    $PSBPreference.Build.CompileScriptHeader = '# Function header'
    $PSBPreference.Build.CompileScriptFooter = '# Function footer' + [Environment]::NewLine

    # So Pester InModuleScope works
    $PSBPreference.Test.ImportModule           = $true
    $PSBPreference.Test.CodeCoverage.Enabled   = $true
    $PSBPreference.Test.CodeCoverage.Threshold = 0.0
    $PSBPreference.Test.CodeCoverage.OutputFile = 'cc.xml'

    # Override the default output directory
    $PSBPreference.Build.OutDir = Join-Path $psake.build_script_dir 'Output'
}

task default -depends Build

task Build -FromModule joshooaj.PowerShellBuild -minimumVersion 0.6.2
