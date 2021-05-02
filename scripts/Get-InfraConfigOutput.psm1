function Get-InfraConfigOutput {
  param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("dev", "staging", "prod")] 
    [string] $CloudEnv
  )
  
  $config_path = "$PSScriptRoot\..\config\infra_config_output\${CloudEnv}.yaml"
  $apps_config = Get-Content -Path $config_path | ConvertFrom-Yaml -Ordered

  return $apps_config
}

Export-ModuleMember -Function Get-InfraConfigOutput