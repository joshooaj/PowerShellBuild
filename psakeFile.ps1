properties {
    $settings = . ([IO.Path]::Combine($PSScriptRoot, 'build.settings.ps1'))
    if ($galleryApiKey) {
        $settings.PSGalleryApiKey = $galleryApiKey.GetNetworkCredential().password
    }
}

task default -depends Test

task Init {
    "STATUS: Testing with PowerShell $($settings.PSVersion)"
    'Build System Details:'
    Get-Item ENV:BH*
} -description 'Initialize build environment'

task Test -Depends Init, Analyze, Pester -description 'Run test suite'

task Analyze -depends Build {
    $analysis = Invoke-ScriptAnalyzer -Path $settings.ModuleOutDir -Recurse -Verbose:$false -Settings ([IO.Path]::Combine($env:BHModulePath, 'ScriptAnalyzerSettings.psd1'))
    $errors   = $analysis | Where-Object {$_.Severity -eq 'Error'}
    $warnings = $analysis | Where-Object {$_.Severity -eq 'Warning'}
    if (@($errors).Count -gt 0) {
        Write-Error -Message 'One or more Script Analyzer errors were found. Build cannot continue!'
        $errors | Format-Table -AutoSize
    }

    if (@($warnings).Count -gt 0) {
        Write-Warning -Message 'One or more Script Analyzer warnings were found. These should be corrected.'
        $warnings | Format-Table -AutoSize
    }
} -description 'Run PSScriptAnalyzer'

task Pester -depends Build {
    Remove-Module $settings.ProjectName -ErrorAction SilentlyContinue -Verbose:$false
    $shell = (Get-Process -Id $PID).Name -split '\.' | Select-Object -First 1
    $config = New-PesterConfiguration @{
        Run          = @{
            Path                   = $settings.Tests
            PassThru               = $true
            SkipRemainingOnFailure = 'Container'
        }
        CodeCoverage = @{
            <# TODO:
                Setup code coverage. Tests currently cover the psake/IB tasks and not specific PowerShellBuild functions
                so I'm not sure the best way to implement code coverage at the moment.
            #>
            Enabled    = $false
            Path       = Join-Path $psake.build_script_dir "$($settings.ProjectName)/Public/"
            OutputPath = Join-Path $psake.build_script_dir 'Output/coverage.xml'
        }
        TestResult   = @{
            Enabled    = $true
            OutputPath = Join-Path $psake.build_script_dir "Output/testResults-$shell.xml"
        }
    }
    $testResults = Invoke-Pester -Configuration $config

    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
        Write-Error -Message 'One or more Pester tests failed. Build cannot continue!'
    }
} -description 'Run Pester tests'

task Clean -depends Init {
    if (Test-Path -Path $settings.ModuleOutDir) {
        Remove-Item -Path $settings.ModuleOutDir -Recurse -Force -Verbose:$false
    }

    $testModuleOutDir = [io.path]::Combine($psake.build_script_dir, 'tests', 'TestModule', 'Output')
    if (Test-Path -Path $testModuleOutDir) {
        Remove-Item -Path $testModuleOutDir -Recurse -Force -Verbose:$false
    }

    Get-PSRepository -Name PowerShellBuild-local -ErrorAction SilentlyContinue | Unregister-PSRepository
}

task Build -depends Init, Clean {
    New-Item -Path $settings.ModuleOutDir -ItemType Directory -Force > $null
    Copy-Item -Path "$($settings.SUT)/*" -Destination $settings.ModuleOutDir -Recurse

    # Commented out rather than removed to allow easy use in future
    # Generate Invoke-Build tasks from Psake tasks
    # $psakePath = [IO.Path]::Combine($settings.ModuleOutDir, 'psakefile.ps1')
    # $ibPath    = [IO.Path]::Combine($settings.ModuleOutDir, 'IB.tasks.ps1')
    # & .\Build\Convert-PSAke.ps1 $psakePath | Out-File -Encoding UTF8 $ibPath
}

task Publish -depends Test {
    "    Publishing version [$($settings.Manifest.ModuleVersion)] to PSGallery..."
    if ($settings.PSGalleryApiKey) {
        Publish-Module -Path $settings.ModuleOutDir -NuGetApiKey $settings.PSGalleryApiKey
    } else {
        throw 'Did not find PSGallery API key!'
    }
} -description 'Publish to PowerShellGallery'
