#!/usr/bin/env pwsh

# Update Prompt
# read and write whole profile to avoid problems with line endings and encodings
$profileText = Get-Content $profile
$promptLogic = "function prompt {`"`$(Split-Path -leaf -path (Get-Location))> `"}"
if($null -eq ($profileText | Select-String 'function prompt')) {
  Write-Output 'Updating the prompt'
  $new_profile = @($profileText) + $promptLogic
  $new_profile > $profile
} else {
  Write-Output "Prompt already configured. Use 'code `$profile' and remove the function prompt"
}