#!/usr/bin/env pwsh

switch ($args[0]) {
  "revision" { Invoke-Item "$PSScriptRoot/lib/scripts/_helper-update-revision.ps1" }
  "push" { git push }
  Default {
    Write-Host "Usage: ./run.ps1 <revision|push>" -ForegroundColor Yellow
  }
}
