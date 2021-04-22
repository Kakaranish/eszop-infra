Import-Module $PSScriptRoot\Config.psm1 -Force

$tf_dir = Resolve-Path "$PSScriptRoot\.."

if ($Init) {
    terraform.exe -chdir="$tf_dir" init
}

# image_name is taken from Config.psm1
$image_name_to_apply = if ($ImageName) { $ImageName } else { $image_name }

terraform.exe `
    -chdir="$tf_dir" `
    destroy `
    -var="redis_password=$redis_password" `
    -var="image_name=$image_name_to_apply" 