function ConvertTo-Base64 {
  param (
    [string] $Text
  )
    
  $encodedText = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Text))
  Write-Output "$encodedText"
}

Export-ModuleMember -Function ConvertTo-Base64