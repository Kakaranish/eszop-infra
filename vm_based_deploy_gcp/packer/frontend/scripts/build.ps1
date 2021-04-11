param(
    [Parameter(Mandatory = $true)]
    [string] $BuildSuffix
)

$project_id = "eszop-309916"

packer build `
    -var "build_suffix=$BuildSuffix" `
    -var "project_id=$project_id" `
    "$PSScriptRoot\..\eszop_frontend.json"

$last_build_json = @{
    build_suffix = $BuildSuffix;
}
$filename = ".last_build"
New-Item -ItemType File -Name $filename -Force | Out-Null
$last_build_json | ConvertTo-Json | Set-Content $filename