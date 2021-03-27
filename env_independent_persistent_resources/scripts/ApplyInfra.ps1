param(
  [switch] $Init
)

$tf_dir = Resolve-Path "$PSScriptRoot\.."

if ($Init) {
  terraform.exe -chdir="$tf_dir" init
}

terraform.exe `
  -chdir="$tf_dir" `
  apply