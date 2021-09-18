## tools

### PackageManager-Cache-Redirect.ps1

A powershell script to config package manager's global cache directory.

**Now available:**
> Notice: when execute this script at a _yarn v2_ project folder, can not set _yarn v1_ cache folder.

* npm
* yarn v1
* yarn v2
* nuget

__Usage__

```bash
$ PackageManager-Cache-Redirect.ps1 [[-CacheRoot] <string>] [-Name <string[]>] 

e.g.
# set all available, default root folder is '{userdir}\.cache'.
$ PackageManager-Cache-Redirect.ps1  
# set all available, with specified cache folder.
$ PackageManager-Cache-Redirect.ps1 "D:\caches" 
# select whichs to config, with specified cache folder.
$ PackageManager-Cache-Redirect.ps1 "D:\caches" -Name npm,yarn.v2,nuget  
```
