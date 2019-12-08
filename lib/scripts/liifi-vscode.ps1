scoop install vscode
. liifi-myhome

$userDataDir = "$env:APPDATA\Code\User\"
$userSettings = "$userDataDir\settings.json"
$extensions = @(
  'editorconfig.editorconfig',
  'ms-vscode-remote.vscode-remote-extensionpack',
  'ms-azuretools.vscode-docker',
  'ms-kubernetes-tools.vscode-kubernetes-tools',
  'ms-vscode.powershell'
  # 'vscjava.vscode-java-pack',
) 
# 'vscjava.vscode-java-debug','vscjava.vscode-java-test','vscjava.vscode-maven'
# Write-Host "If the following fails due to certificate issue, add the following : $userSettings, then run this conf again. Do not forget to set it to true after done"
# Write-Host '"http.proxyStrictSSL": false' -ForegroundColor Yellow
Write-Host "If the following fails due to certificate, then type 'code' and under extensions search/install: "
Write-Host ($extensions -join ", ") -ForegroundColor Yellow

$extensions | % {
  Write-Host "Installing $_" -ForegroundColor Yellow
  code --install-extension $_
}