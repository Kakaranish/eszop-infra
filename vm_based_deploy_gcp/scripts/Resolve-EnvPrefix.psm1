function Resolve-EnvPrefix {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Environment
    )

    $env_prefix_dict = @{
        "StagingVm" = "staging-vm";
    }

    Write-Output $env_prefix_dict[$Environment]
}

Export-ModuleMember -Function Resolve-EnvPrefix