#!/usr/bin/env pwsh

git add --all
git commit -m "Processing update revision"
$revision    = git rev-parse --short HEAD
$remoteAsIs  = (git remote get-url --all origin);
if(!($remoteAsIs.startsWith("http"))){
  $remote = (git remote get-url --all origin) -replace ".git","";
  $remote = $remote.replace(":","/")
  $remote = "https://$remote"
} else {
  $remote = $remoteAsIs
}
$remoteRaw = ""
if($remote.startsWith('https://github.com')) { $remoteRaw = $remote -replace "github","raw.githubusercontent" }
else { $remoteRaw = $remote -replace ".com",".com/raw" }
$remoteParts = $remote.split("/")
$project     = $remoteParts.Get($remoteParts.Count-1)
$liifis      = (Get-ChildItem lib/scripts | ?{ $_.name.StartsWith("liifi-"); })

$version = (Get-Date -UFormat "%Y-%m-%d-%H-%M")
$liifis | %{
  $manifestName = "bucket/$($_.basename).json"
  $scriptName = $_.name;
  $hash = (Get-FileHash $_.FullName).hash

  if(!(Test-Path $manifestName)){
    Write-Host "Adding missing manifest for $scriptName" -ForegroundColor "Yellow"
    $newManifest = @{
      "homepage"= "$remote"
      "version"= "$version"
      "url"= "$remoteRaw/$revision/lib/scripts/$scriptName"
      "hash"= "$hash"
      "bin"= @("$scriptName")
    }
    $newManifest | ConvertTo-Json | Set-Content $manifestName
  }

  Write-Host -NoNewline ("--- $($manifestName) ").Trim(40).PadRight(40,".")
  $manifest = (Get-Content $manifestName | ConvertFrom-Json)
  if($hash -ne $manifest.hash){
    Write-Host -NoNewline " Was: $($manifest.hash)"
    Write-Host -NoNewline " Is:  $hash" -ForegroundColor "Yellow"
    $manifest.url     = ($manifest.url -replace "$project/[a-zA-Z0-9]+","$project/$revision")
    $manifest.version = $version
    $manifest.hash    = $hash
  } else {
    Write-Host -NoNewline " Up to date"
  }
  # Make sure to have a new line
  Write-Host ""
  $manifest | ConvertTo-Json | Set-Content $manifestName
}

$basicsManifestName = "liifi-scoop-basics";
$basicsManifest = "$($basicsManifestName).json"
$basics = (Get-Content "bucket/$basicsManifest" | ConvertFrom-Json)
$currentLiifis = $basics.depends
$existingLiifis = ($liifis | ?{ $_.BaseName -ne $basicsManifestName } | %{ $_.basename })
if($currentLiifis.Count -ne $existingLiifis.Count){
  Write-Host "Updating dependencies of liifi-scoop-basics" -ForegroundColor "Yellow"
  $basics.version = $version
}
$basics.depends = $existingLiifis;
$basics | ConvertTo-Json | Set-Content "bucket/$basicsManifest"

git add --all
git commit -m "Completed revision update"
