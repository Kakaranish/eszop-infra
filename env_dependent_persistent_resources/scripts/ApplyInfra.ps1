param(
  [switch] $Init
)

$environment = $env:ASPNETCORE_ENVIRONMENT
if(-not($environment)){
  $environment = "Staging"
}

$tf_dir = Resolve-Path "$PSScriptRoot\.."

if ($Init) {
  terraform.exe -chdir="$tf_dir" init
}

terraform.exe `
  -chdir="$tf_dir" `
  apply `
  -var-file="$tf_dir\vars\$environment.tfvars"