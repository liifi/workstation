#!/usr/bin/env pwsh

$promptLogic = @'
function prompt {
  $p = Split-Path -leaf -path (Get-Location)
  $ver = git rev-parse --abbrev-ref HEAD 2>$null
  Write-Host (pwd) -ForegroundColor Cyan
  Write-Host -NoNewline "$([char]0x2937) $p"
  if($ver) {
    Write-Host -NoNewline " "
    Write-Host -NoNewline " $ver " -BackgroundColor DarkBlue -ForegroundColor White
  }
  return "> "
}
'@

# Update Prompt
# read and write whole profile to avoid problems with line endings and encodings
$profileText = Get-Content $profile
if($null -eq ($profileText | Select-String 'function prompt')) {
  Write-Output 'Updating the prompt'
  $new_profile = @($profileText) + $promptLogic
  $new_profile > $profile
} else {
  Write-Output "Prompt already configured. Use 'code `$profile' and remove the function prompt"
}