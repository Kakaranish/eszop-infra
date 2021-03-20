$tf_dir = Resolve-Path "$PSScriptRoot\.."

terraform.exe `
  -chdir="$tf_dir" `
  destroy `
  -var="allowed_ip=$my_ip" `
  -var-file="$tf_dir\vars\$env:ASPNETCORE_ENVIRONMENT.tfvars"