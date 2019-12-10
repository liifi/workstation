#!/usr/bin/env pwsh

Push-Location $PSScriptRoot
switch ($args[0]) {
  "revision" { . "$PSScriptRoot/lib/scripts/_update-revision.ps1" }
  "update" { ./run.ps1 revision; git push; }
  "checkver" {
    if($args.Count -gt 1) { iex -command "./bin/checkver.ps1 $($args[-1..-1] |% { "$_ " })"; } # -Update, -ForceUpdate
    else { ./bin/checkver.ps1 }
    # dos2unix .\bucket\*  2>&1 > $null;
  }
  Default {
    Write-Host "Usage: ./run.ps1 <revision|update|checkver>" -ForegroundColor Yellow
  }
}
Pop-Location