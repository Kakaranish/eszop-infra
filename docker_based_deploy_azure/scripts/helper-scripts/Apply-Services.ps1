param (
  [Parameter(Mandatory = $true)]
  [ValidateSet("dev", "staging", "prod")] 
  [string] $CloudEnv
)

$kubernetes_dir = Resolve-Path -Path "$PSScriptRoot\..\..\kubernetes"

# ------------------------------------------------------------------------------

kubectl apply -k "${kubernetes_dir}\environments\$CloudEnv"