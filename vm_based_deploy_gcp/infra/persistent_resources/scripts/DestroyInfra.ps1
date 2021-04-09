$tf_dir = Resolve-Path "$PSScriptRoot\.."

terraform.exe `
    -chdir="$tf_dir" `
    destroy