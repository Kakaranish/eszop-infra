$project_id = "eszop-309916"
$build_suffix = ""

packer build `
    -var "build_suffix=$build_suffix" `
    -var "project_id=$project_id" `
    "$PSScriptRoot\..\eszop_backend_base.json"