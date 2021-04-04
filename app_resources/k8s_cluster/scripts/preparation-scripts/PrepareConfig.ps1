param (
    [string] $IngressExternalIP
)

$config_path = "$PSScriptRoot\..\..\config\config.yaml"
$config_yaml = Get-Content -Path $config_path | ConvertFrom-Yaml -Ordered

$config_yaml.data.ESZOP_API_URL = "https://$IngressExternalIP/api"
$config_yaml.data.ESZOP_CLIENT_URI = "https://$IngressExternalIP"

$config_yaml | ConvertTo-Yaml | Set-Content $config_path