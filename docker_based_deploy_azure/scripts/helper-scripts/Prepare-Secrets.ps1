param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("dev", "staging", "prod")] 
  [string] $CloudEnv
)

$repo_root = "$PSScriptRoot\..\..\.."
$secrets_path = "$PSScriptRoot\..\..\kubernetes\secrets.yaml"

Import-Module "$PSScriptRoot\ConvertTo-Base64.psm1" -Force
Import-Module "${repo_root}\scripts\Get-InfraConfig.psm1" -Force

# ------------------------------------------------------------------------------

$apps_config = Get-AppsConfig -CloudEnv $CloudEnv

$secrets_yaml = Get-Content -Path $secrets_path | ConvertFrom-Yaml -Ordered
if (-not($secrets_yaml.data)) {
  $secrets_yaml.data = @{}
}

$secrets_yaml.data.ESZOP_AZURE_STORAGE_CONN_STR = ConvertTo-Base64 -Text $apps_config.AZURE_STORAGE_CONN_STR
$secrets_yaml.data.ESZOP_AZURE_EVENTBUS_CONN_STR = ConvertTo-Base64 -Text $apps_config.AZURE_EVENTBUS_CONN_STR

$redis_conn_str = "$($apps_config.REDIS_ADDRESS):$($apps_config.REDIS_PORT),password=$($apps_config.REDIS_PASSWORD)"
$secrets_yaml.data.ESZOP_REDIS_CONN_STR = ConvertTo-Base64 -Text $redis_conn_str

$services = @("offers", "identity", "carts", "orders", "notification")
foreach ($service in $services) {
  $service_name = $service.ToUpperInvariant()
  $conn_str = $apps_config.SQLSERVER_CONN_STR_TEMPLATE `
    -replace "{env_prefix}", $CloudEnv `
    -replace "{service_name}", $service `
    -replace "{db_username}", $apps_config.SQLSERVER_USERNAME `
    -replace "{db_password}", $apps_config.SQLSERVER_PASSWORD
    
  $secret_name = "ESZOP_SQLSERVER_CONN_STR_$service_name"
  $secrets_yaml.data.$secret_name = ConvertTo-Base64 -Text $conn_str
}

$secrets_yaml | ConvertTo-Yaml | Set-Content $secrets_path -NoNewline