# workstation

Generic windows workstation setup. Leverages **scoop** which is a Dependency manager for almost any sort of binary/tool used during development cycle. Use it instead of downloading items from websites and configuring environmental variables. Find configurations for popular tools with ```scoop list liifi-``` after following the **Prerequesites**.

### Prerequesites

- On **powershell** run the following
- **Allow** script execution ```Set-ExecutionPolicy RemoteSigned -scope CurrentUser```
- (optional) **Corporate CA** run ```iex (new-object net.webclient).downloadstring("https://raw.githubusercontent.com/liifi/workstation/master/lib/scripts/liifi-corpca.ps1")```
- **Basic Tools** run ```iex (new-object net.webclient).downloadstring("https://raw.githubusercontent.com/liifi/workstation/master/lib/scripts/liifi-scoop-basics.ps1")```
- Done, now you can use ```scoop install``` and ```scoop search```

### Extra information
- Type ```scoop basics-liifi``` to re run the latest version of prerequesites
- Type ```scoop help``` for more info
- Type ```scoop list liifi-``` to view available configurations (recipes you can run)
- Type ```scoop update-liifi``` to get latest version of configurations. You can also update specific configurations with ```scoop latest liifi-<name>```
- After updating or installing a config, use ```liifi-<name>``` to run it. Most try to be as idempotent as possible (as in you can run it mulitple times and its ok)

---

## Changing this repo

### If you are a user of this repo

- To edit the scoop bucket, do ```liifi-edit-bucket```, change manifests or add new ones and commit

### Updating liifi-* scripts

- Clone this repo
- Perform needed changes
- Run ```./run.ps1 revision``` or ```./run.ps1 push``` to push the changes right away
- **From user machine**, run ```scoop update-liifi``` or to update confs and configure basics ```scoop basics-liifi```

---

## WSL Distros

### Requirements

- Windows 10
- WSL 2 default. ```wsl --set-default-version 2```
- Docker (used to build image that is imported as wsl distro)

### Usage

- Run one of the ```liifi-wsl-*``` commands
- ```wsl -d liifi-*``` to run the distro as usual (it will also show on Windows Terminal if you have it installed)

#### K3S notes

Starting - K3S wsl image is not set to start by default, you must use:
```powershell
wsl -d liifi-k3s
k3s server &
exit
```

After starting - To ensure it works from windows. Is there a better way?
```powershell
$kubeconfig='//wsl$/liifi-k3s/etc/rancher/k3s/k3s.yaml'
sc $kubeconfig ((gc -raw $kubeconfig) -replace '127.0.0.1','localhost')
```

From windows - To use ```kubectl``` from windows make sure to have set the environment variable for KUBECONFIG
```powershell
$env:KUBECONFIG='//wsl$/liifi-k3s/etc/rancher/k3s/k3s.yaml'
```

From VSCode - Use the kubernetes extension and set the kubeconfig file to ```//wsl$/liifi-k3s/etc/rancher/k3s/k3s.yaml```