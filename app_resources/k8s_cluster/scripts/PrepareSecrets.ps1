Import-Module $PSScriptRoot\..\..\..\scripts\Resolve-EnvPrefix.psm1 -Force

# ---  FILL VALUES BELOW vvv  --------------------------------------------------

$ESZOP_AZURE_STORAGE_CONN_STR = ""
$ESZOP_AZURE_EVENTBUS_CONN_STR = ""
$ESZOP_REDIS_CONN_STR = ""

$db_username = ""
$db_password = ""

# ------------------------------------------------------------------------------

if (-not($env:ASPNETCORE_ENVIRONMENT)) {
    Write-Error "Environment variable ASPNETCORE_ENVIRONMENT not set" -ErrorAction Stop
}
  
$env_prefix = Resolve-EnvPrefix -Environment $env:ASPNETCORE_ENVIRONMENT
if (-not($env_prefix)) {
    Write-Error "Invalid environment variable ASPNETCORE_ENVIRONMENT" -ErrorAction Stop
}

$services = @("offers", "identity", "carts", "orders", "notification")
$ESZOP_SQLSERVER_CONN_STR_template = "Server=tcp:eszop-{env_prefix}-sqlserver.database.windows.net,1433;Initial Catalog=eszop-{env_prefix}-{service_name}-db;Persist Security Info=False;User ID={db_username};Password={db_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

function ToBase64 {
    param (
        [string] $Text
    )
    
    $encodedText = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Text))
    Write-Output "$encodedText"
}

$secrets_path = "$PSScriptRoot\..\config\secrets.yaml"
$secrets_yaml = Get-Content -Path $secrets_path | ConvertFrom-Yaml

if(-not($secrets_yaml.data)) {
    $secrets_yaml.data = @{}
}

$secrets_yaml.data.ESZOP_AZURE_STORAGE_CONN_STR = ToBase64 -Text $ESZOP_AZURE_STORAGE_CONN_STR
$secrets_yaml.data.ESZOP_AZURE_EVENTBUS_CONN_STR = ToBase64 -Text $ESZOP_AZURE_EVENTBUS_CONN_STR
$secrets_yaml.data.ESZOP_REDIS_CONN_STR = ToBase64 -Text $ESZOP_REDIS_CONN_STR

foreach ($service in $services) {
    $service_name = $service.ToUpperInvariant()
    $conn_str = $ESZOP_SQLSERVER_CONN_STR_template `
        -replace "{env_prefix}", $env_prefix `
        -replace "{service_name}", $service `
        -replace "{db_username}", $db_username `
        -replace "{db_password}", $db_password
    
    $secret_name = "ESZOP_SQLSERVER_CONN_STR_$service_name"
    $secrets_yaml.data.$secret_name = ToBase64 -Text $conn_str
}

$secrets_yaml | ConvertTo-Yaml | Set-Content $secrets_path