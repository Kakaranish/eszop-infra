function Get-InfraConfig {
  param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("dev", "staging", "prod", "global")] 
    [string] $CloudEnv
  )

  $config_path = "$PSScriptRoot\..\config\infra\$CloudEnv.yaml"
  $infra_config = Get-Content -Path $config_path | ConvertFrom-Yaml -Ordered

  return $infra_config
}

Export-ModuleMember -Function Get-InfraConfig