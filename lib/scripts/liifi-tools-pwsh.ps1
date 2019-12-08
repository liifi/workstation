$null = get-command ssh -ErrorAction SilentlyContinue -ErrorVariable ProcessError
if(!$ProcessError){
  Write-Host "You already have pwsh at: $(which pwsh)" -ForegroundColor Yellow
} else {
  scoop install pwsh
}