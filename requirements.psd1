@{
    'PSDependOptions'  = @{
        Target = 'CurrentUser'
    }
    'BuildHelpers'     = '2.0.16'
    'Pester'           = @{
        MinimumVersion = '5.5.0'
        Parameters     = @{
            SkipPublisherCheck = $true
        }
    }
    'psake'            = '4.9.0'
    'PSScriptAnalyzer' = '1.22.0'
    'InvokeBuild'      = '5.11.1'
    'joshooaj.platyPS' = '0.15.12'
}
