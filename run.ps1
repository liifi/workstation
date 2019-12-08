#!/usr/bin/env pwsh

switch ($args[0]) {
  "revision" { . "$PSScriptRoot/lib/scripts/_update-revision.ps1" }
  "push" { git push }
  Default {
    Write-Host "Usage: ./run.ps1 <revision|push>" -ForegroundColor Yellow
  }
}
