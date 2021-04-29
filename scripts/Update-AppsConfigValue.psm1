function Update-AppsConfigValue {
  param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("dev", "staging", "prod")] 
    [string] $CloudEnv,
    
    [Parameter(Mandatory = $true)]
    [string] $Field, 

    [Parameter(Mandatory = $true)]
    [string] $Value
  )

  $config_path = "$PSScriptRoot\..\config\app\$CloudEnv.yaml"
  $infra_config = Get-Content -Path $config_path | ConvertFrom-Yaml -Ordered

  $infra_config.$Field = $Value

  $infra_config | ConvertTo-Yaml | Set-Content $config_path -NoNewline

  return $infra_config
}

Export-ModuleMember -Function Update-AppsConfigValue