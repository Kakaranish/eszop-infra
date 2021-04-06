$tf_dir = Resolve-Path "$PSScriptRoot\.."

if(-not($env:ASPNETCORE_ENVIRONMENT)) {
  Write-Error "Environment variable ASPNETCORE_ENVIRONMENT not set" -ErrorAction Stop
}

terraform.exe `
  -chdir="$tf_dir" `
  destroy `
  -var="environment=$env_prefix"