function Update-InfraConfigOutput {
  param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("dev", "staging", "prod")] 
    [string] $CloudEnv,
  
    [Parameter(Mandatory = $true)]
    [hashtable] $Entries
  )

  $config_path = "$PSScriptRoot\..\config\infra_config_output\${CloudEnv}.yaml"
  if (-not(Test-Path -Path $config_path)) {
    @{} | ConvertTo-Yaml | Set-Content $config_path | Out-Null
  }
  $config_yaml = Get-Content -Path $config_path | ConvertFrom-Yaml -Ordered
  
  foreach ($entry in $Entries.Keys) {
    $config_yaml.$entry = $Entries[$entry]
  }

  $config_yaml | ConvertTo-Yaml | Set-Content $config_path -NoNewline
}

Export-ModuleMember -Function Update-InfraConfigOutput