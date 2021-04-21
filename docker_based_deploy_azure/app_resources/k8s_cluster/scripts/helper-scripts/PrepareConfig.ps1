param (
    [string] $IngressExternalAddress
)

$config_path = "$PSScriptRoot\..\..\config\config.yaml"
$config_yaml = Get-Content -Path $config_path | ConvertFrom-Yaml -Ordered

$config_yaml.data.ESZOP_API_URL = "https://$IngressExternalAddress/api"
$config_yaml.data.ESZOP_CLIENT_URI = "https://$IngressExternalAddress"

$config_yaml | ConvertTo-Yaml | Set-Content $config_path