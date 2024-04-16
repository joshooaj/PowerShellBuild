describe 'Build' {

    BeforeAll {
        $script:testModuleProjectPath = Join-Path $env:BHProjectPath 'tests/TestModule/'
        $script:testModuleOutputPath = Join-Path $testModuleProjectPath 'Output/TestModule/0.1.0'
        $null = New-Item -Path $script:testModuleOutputPath -ItemType Directory -Force -ErrorAction Stop
    }

    context 'Compile module' {
        BeforeAll {
            # build in another process so psake doesn't freak out because it's nested
            Start-Job -ArgumentList $script:testModuleProjectPath -ScriptBlock {
                param([string]$path)
                Set-Location $path
                $global:PSBuildCompile = $true
                ./build.ps1 -Task Build -Verbose
            } | Receive-Job -Wait -AutoRemoveJob
        }

        AfterAll {
            Remove-Item $script:testModuleOutputPath -Recurse -Force
        }

        it 'Creates module' {
            $script:testModuleOutputPath | Should -Exist
        }

        it 'Has PSD1 and monolithic PSM1' {
            (Get-ChildItem -Path $script:testModuleOutputPath -File).Count | Should -Be 2
            "$script:testModuleOutputPath/TestModule.psd1"                 | Should -Exist
            "$script:testModuleOutputPath/TestModule.psm1"                 | Should -Exist
            "$script:testModuleOutputPath/Public"                          | Should -Not -Exist
            "$script:testModuleOutputPath/Private"                         | Should -Not -Exist
        }

        it 'Has module header text' {
            "$script:testModuleOutputPath/TestModule.psm1" | Should -FileContentMatch '# Module Header'
        }

        it 'Has module footer text' {
            "$script:testModuleOutputPath/TestModule.psm1" | Should -FileContentMatch '# Module Footer'
        }

        it 'Has function header text' {
            "$script:testModuleOutputPath/TestModule.psm1" | Should -FileContentMatch '# Function header'
        }

        it 'Has function footer text' {
            "$script:testModuleOutputPath/TestModule.psm1" | Should -FileContentMatch '# Function footer'
        }

        it 'Does not contain excluded files' {
            (Get-ChildItem -Path $script:testModuleOutputPath -File -Filter '*excludeme*' -Recurse).Count | Should -Be 0
            "$script:testModuleOutputPath/TestModule.psm1" | Should -Not -FileContentMatch '=== EXCLUDE ME ==='
        }

        it 'Has MAML help XML' {
            "$script:testModuleOutputPath/en-US/TestModule-help.xml" | Should -Exist
        }
    }

    context 'Dot-sourced module' {
        BeforeAll {
            # build in another process so psake doesn't freak out because it's nested
            Start-Job -ArgumentList $script:testModuleProjectPath -ScriptBlock {
                param([string]$path)
                Set-Location $path
                $global:PSBuildCompile = $false
                ./build.ps1 -Task Build
            } | Receive-Job -Wait -AutoRemoveJob
        }

        AfterAll {
            Remove-Item $script:testModuleOutputPath -Recurse -Force
        }

        it 'Creates module' {
            $script:testModuleOutputPath | Should -Exist
        }

        it 'Has PSD1 and dot-sourced functions' {
            (Get-ChildItem -Path $script:testModuleOutputPath).Count | Should -Be 6
            "$script:testModuleOutputPath/TestModule.psd1"           | Should -Exist
            "$script:testModuleOutputPath/TestModule.psm1"           | Should -Exist
            "$script:testModuleOutputPath/Public"                    | Should -Exist
            "$script:testModuleOutputPath/Private"                   | Should -Exist
        }

        it 'Does not contain excluded stuff' {
            (Get-ChildItem -Path $script:testModuleOutputPath -File -Filter '*excludeme*' -Recurse).Count | Should -Be 0
        }

        it 'Has MAML help XML' {
            "$script:testModuleOutputPath/en-US/TestModule-help.xml" | Should -Exist
        }
    }
}
