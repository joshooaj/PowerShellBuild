Import-Module ../../Output/joshooaj.PowerShellBuild -Force
. PowerShellBuild.IB.Tasks

$PSBPreference.Build.CompileModule = $true

task Build $PSBPreference.build.dependencies

task . Build
