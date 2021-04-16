$project_id = "eszop-309916"

packer build `
    -var "project_id=$project_id" `
    "$PSScriptRoot\..\redis.json"