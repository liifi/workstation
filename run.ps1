#!/usr/bin/env pwsh

switch ($args[0]) {
  "revision" { . "$PSScriptRoot/lib/scripts/_update-revision.ps1" }
  "update" { ./run.ps1 revision; git push; }
  Default {
    Write-Host "Usage: ./run.ps1 <revision|update>" -ForegroundColor Yellow
  }
}
