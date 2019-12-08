# BASED ON
# https://github.com/lukesampson/pshazz/blob/master/plugins/ssh.ps1

# based on script from here:
# https://help.github.com/articles/working-with-ssh-key-passphrases#platform-windows

# Note: $env:USERPROFILE/.ssh/environment should not be used, as it
#       already has a different purpose in SSH.
$envfile="$env:USERPROFILE/.ssh/agent.env.ps1"

try { gcm ssh-agent -ea stop > $null } catch { return }

# Note: Don't bother checking SSH_AGENT_PID. It's not used
#       by SSH itself, and it might even be incorrect
#       (for example, when using agent-forwarding over SSH).
function agent_is_running() {
	if($env:SSH_AUTH_SOCK) {
		# ssh-add returns:
		#   0 = agent running, has keys
		#   1 = agent running, no keys
		#   2 = agent not running
		ssh-add -l 2>&1 > $null;
		$lastexitcode -ne 2
	} else {
		$false
	}
}

function agent_has_keys {
	ssh-add -l 2>&1 > $null; $lastexitcode -eq 0
}

function agent_load_env {
	if(test-path $envfile) { . $envfile > $null }
}

function agent_start {
	$script = ssh-agent

	# translate bash script to powershell
	$script = $script -creplace '([A-Z_]+)=([^;]+).*', '$$env:$1="$2"' `
		-creplace 'echo ([^;]+);', 'echo "$1"'

	if(!(test-path "$env:USERPROFILE/.ssh")) { mkdir "$env:USERPROFILE/.ssh" > $null }

	$script > $envfile
	. $envfile > $null
}

function add_keys {
  if( !(scoop which ssh).contains("win32-openssh") ) {

  # $env:SSH_ASKPASS = resolve-path "$psscriptroot\..\..\askpass.exe"
  $env:SSH_ASKPASS = resolve-path (scoop which askpass)
	$env:DISPLAY = "localhost:0.0"

  $null | ssh-add

  } else {
    ssh-add
  }
}

# pshazz plugin entry point
# function pshazz:ssh:init {
function ssh:init {
	if(!(agent_is_running)) {
		agent_load_env
	}

	if(!(agent_is_running)) {
		agent_start
		add_keys
	} elseif(!(agent_has_keys)) {
		add_keys
	}

	# $global:pshazz.completions.ssh = resolve-path "$psscriptroot\..\libexec\ssh-complete.ps1"
}


# Remove some powershell aliases
# read and write whole profile to avoid problems with line endings and encodings
$profileText = Get-Content $profile
if($null -eq ($profileText | Select-String 'liifi-ssh-id-add')) {
  Write-Output 'Ensuring ssh agent is running and configured on powershell start'
  $new_profile = @($profileText) + "try { liifi-ssh-id-add } catch { }"
  $new_profile > $profile
}


# Init right away
ssh:init