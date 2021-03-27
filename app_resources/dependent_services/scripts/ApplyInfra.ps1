param(
  [switch] $Init
)

$default_environment = "Staging"
$environment = $env:ASPNETCORE_ENVIRONMENT
if(-not($environment)){
  $environment = $default_environment
}

$tf_dir = Resolve-Path "$PSScriptRoot\.."

if ($Init) {
  terraform.exe -chdir="$tf_dir" init
}

$my_ip = (Invoke-WebRequest ifconfig.me/ip).Content.Trim()

terraform.exe `
  -chdir="$tf_dir" `
  apply `
  -var="allowed_ip=$my_ip" `
  -var-file="$tf_dir\vars\$environment.tfvars"