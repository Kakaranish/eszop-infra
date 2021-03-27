$tf_dir = Resolve-Path "$PSScriptRoot\.."

$environment = $env:ASPNETCORE_ENVIRONMENT
if(-not($environment)){
  $environment = "Staging"
}

terraform.exe `
  -chdir="$tf_dir" `
  destroy `
  -var-file="$tf_dir\vars\$environment.tfvars"