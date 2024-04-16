[cmdletbinding(DefaultParameterSetName = 'Task')]
param(
    # Build task(s) to execute
    [parameter(ParameterSetName = 'task', position = 0)]
    [ArgumentCompleter( {
        param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
        $psakeFile = './psakeFile.ps1'
        switch ($Parameter) {
            'Task' {
                if ([string]::IsNullOrEmpty($WordToComplete)) {
                    Get-PSakeScriptTasks -buildFile $psakeFile | Select-Object -ExpandProperty Name
                }
                else {
                    Get-PSakeScriptTasks -buildFile $psakeFile |
                        Where-Object { $_.Name -match $WordToComplete } |
                        Select-Object -ExpandProperty Name
                }
            }
            Default {
            }
        }
    })]
    [string[]]$Task = 'default',

    # Bootstrap dependencies
    [switch]$Bootstrap = $true,

    # List available build tasks
    [parameter(ParameterSetName = 'Help')]
    [switch]$Help,

    [pscredential]$PSGalleryApiKey
)

$ErrorActionPreference = 'Stop'

# Bootstrap dependencies
if ($Bootstrap.IsPresent) {
    try {
        $localRepoName = 'PowerShellBuild-local'
        if ($null -eq (Get-PSRepository -Name $localRepoName -ErrorAction SilentlyContinue)) {
            $splargs = @{
                Name               = $localRepoName
                SourceLocation     = Join-Path $PSScriptRoot 'Modules/'
                InstallationPolicy = 'Trusted'
            }
            Register-PSRepository @splargs
        }
        Get-PackageProvider -Name Nuget -ForceBootstrap | Out-Null
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        if (-not (Get-Module -Name PSDepend -ListAvailable)) {
            Install-module -Name PSDepend -Repository PSGallery
        }
        Import-Module -Name PSDepend -Verbose:$false
        Invoke-PSDepend -Path './requirements.psd1' -Install -Import -Force -WarningAction SilentlyContinue
    } catch {
        throw
    } finally {
        if (Get-PSRepository -Name PowerShellBuild-locall -ErrorAction SilentlyContinue) {
            Unregister-PSRepository -Name PowerShellBuild-local -ErrorAction Stop
        }
    }
}

# Execute psake task(s)
$psakeFile = './psakeFile.ps1'
if ($PSCmdlet.ParameterSetName -eq 'Help') {
    Get-PSakeScriptTasks -buildFile $psakeFile  |
        Format-Table -Property Name, Description, Alias, DependsOn
} else {
    Set-BuildEnvironment -Force
    $parameters = @{}
    if ($PSGalleryApiKey) {
        $parameters['galleryApiKey'] = $PSGalleryApiKey
    }
    Invoke-psake -buildFile $psakeFile -taskList $Task -nologo -parameters $parameters
    exit ( [int]( -not $psake.build_success ) )
}
