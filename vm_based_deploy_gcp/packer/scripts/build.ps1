param(
    [Parameter(Mandatory = $true)]
    [string] $BuildSuffix
)

$project_id = "eszop-309916"

packer build `
    -var "build_suffix=$BuildSuffix" `
    -var "project_id=$project_id" `
    "$PSScriptRoot\..\eszop_backend_base.json"