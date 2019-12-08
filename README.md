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