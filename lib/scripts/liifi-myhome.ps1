#!/usr/bin/env pwsh

$me = $env:USERNAME # ((whoami) -split "\\")[1]
$null = Remove-Variable -Force -ErrorAction SilentlyContinue HOME;
Set-Variable HOME "C:\Users\$me"
(get-psprovider filesystem).Home = "C:\Users\$me"
if( $env:HOME -eq $null){
  [environment]::SetEnvironmentVariable('HOME',$HOME,'User')
}
$env:HOME = $HOME;