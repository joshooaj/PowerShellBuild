[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $Uninstall
)

if ($Uninstall) {
    Unregister-PSRepository -Name PowerShellBuild-local
} else {
    Register-PSRepository -Name PowerShellBuild-local -SourceLocation $PSScriptRoot/Modules
}
