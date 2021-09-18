#
# Package Manager Cache Redirect
#

param (
    # Cache root directory
    [Parameter(Mandatory=$false,
               Position=0,
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true,
               HelpMessage="The caches root directory to set. default '{user}/.cache'")]
    [Alias("root","r")]
    [string]
    $CacheRoot,

    # Package manager name
    [Parameter(Mandatory=$false,
               HelpMessage="all or [nuget,npm,yarn,yarn.v1,yarn.v2]'")]
    [Alias("n")]
    [string[]]
    $Name
)


function Redirect-Nuget(){
    #C:\Users\sn_l\AppData\Roaming\NuGet\NuGet.Config
    "_______"
    "[nuget]"
    "-------"
    $cacheDir = nuget locals global-packages -list
    $cacheDir = $cacheDir.SubString($cacheDir.IndexOf(' ') + 1 )
    write-host "  '$cacheDir'" -ForegroundColor DarkGray
    $cacheDir = Join-Path -Path $cacheRoot -ChildPath "nuget"
    nuget config -Set globalPackagesFolder=$cacheDir

    # check
    $temp = nuget locals global-packages -list
    $temp = $cacheDir.SubString($cacheDir.IndexOf(' ') + 1 )
    if($temp -eq $cacheDir){
        write-host "    -->" -ForegroundColor Yellow
        "  '${temp}'"
    }else{
        Write-Error "Set failed current: $temp"
    }
    
}

function Redirect-Npm(){
    #C:\Users\{user}\.npmrc
    "_____"
    "[npm]"
    "-----"
    $cacheDir = npm config get cache
    write-host "  '$cacheDir'" -ForegroundColor DarkGray
    $cacheDir = Join-Path -Path $cacheRoot -ChildPath "npm"
    npm config set cache $cacheDir

    # check
    $temp = npm config get cache
    if($temp -eq $cacheDir){
        write-host "    -->" -ForegroundColor Yellow
        "  '${temp}'"
    }else{
        Write-Error "Set failed current: $temp"
    }
}

function Redirect-Yarn_v1(){
    #C:\Users\{user}\.yarnrc
    "_________"
    "[yarn v1]"
    "---------"
    $cacheDir = yarn config get cache-folder
    write-host "  '$cacheDir'" -ForegroundColor DarkGray
    $cacheDir = Join-Path -Path $cacheRoot -ChildPath "yarn.v1"
    yarn config set cache-folder $cacheDir

    # check
    $temp = yarn config get cache-folder
    if($temp -eq $cacheDir){
        write-host "    -->" -ForegroundColor Yellow
        "  '${temp}'"
    }else{
        Write-Error "Set failed current: $temp"
    }
    
}

function Redirect-Yarn_v2(){
    #C:\Users\{user}\.yarnrc.yml
    "_________"
    "[yarn v2]"
    "---------"
    try {

        #should check {user}/.yarnrc.yml.
        #this set just in folder
        $yarnVersion = yarn -v;
        if ($yarnVersion.StartsWith('1.')) {
            write-host "Cause current is yarn v1. now create a temp folder to set v2." -ForegroundColor DarkGray
            $tempFolderPath = (New-Item -Path $(Join-Path $env:Temp "yarn.v2_$(New-Guid)") -ItemType "directory").FullName
            write-host "  >>> $tempFolderPath " -ForegroundColor DarkGray
            Set-Location $tempFolderPath
            yarn set version berry
            $yarnVersion = yarn -v
            if($yarnVersion.StartsWith('1.'))
            {
                throw "Set yarn v2 faild."
            }
            yarn init -p
        }
        
        $cacheDir = yarn config get globalFolder
        write-host "  '$cacheDir'" -ForegroundColor DarkGray
        $cacheDir = Join-Path -Path $cacheRoot -ChildPath "yarn.v2"
        yarn config set globalFolder $cacheDir -H
        yarn config set enableGlobalCache true -H

        # check
        $temp = yarn config get globalFolder
        if($temp -eq $cacheDir){
            write-host "    -->" -ForegroundColor Yellow
            "  '${temp}'"
        }else{
            Write-Error "Set failed current: $temp"
        }
    }
    catch {
        throw 
    }finally {
        if($tempFolderPath){
            "  >>> $currentDir "
            Set-Location $currentDir
            # $confirm = Read-Host "Remove or keep the temp folder? [y/n] default 'y' for remove"
            # if($confirm -ne 'n'){
                Remove-Item -Path $tempFolderPath -Recurse -Force
                write-host "Temp folder removed." -ForegroundColor DarkGray
            # }
        }
    }
}


function Create-Folder-IfNotExists([string] $dir){
    try {
        if(-not(Test-Path -Path $dir -PathType Container)){
            New-Item -Path $dir -ItemType "directory" | Out-Null
            Write-Debug "Created: [$dir]"
        }else{
            Write-Debug "File already exists."
        }
    }
    catch {
        throw
    }
}
################################################################################

$currentDir = Get-Location 
write-host " Package Manager Cache Redirect " -BackgroundColor White -ForegroundColor White
write-host " Package Manager Cache Redirect " -BackgroundColor White -ForegroundColor Black
write-host " Package Manager Cache Redirect " -BackgroundColor White -ForegroundColor White

if(-not $cacheRoot){
    $cacheRoot = Join-Path -Path $env:USERPROFILE -ChildPath ".cache" 
}

$cacheRoot = "E:\.caches"

Create-Folder-IfNotExists $cacheRoot

write-host "Root: $cacheRoot" -ForegroundColor White
""
if(-not $Name){
    $Name = 'nuget', 'npm', 'yarn.v1', 'yarn.v2' 
}

foreach ($item in $Name) {
    switch -regex ($item) {
        '^nuget$'             { Redirect-Nuget ; break }
        '^npm$'               { Redirect-Npm ; break }
        '^yarn(.v1)?$'        { Redirect-Yarn_v1 ; break }
        '^yarn.v[2-9]+$'      { Redirect-Yarn_v2 ; break }
        default               { Write-Warning "Unsupported: $item"; break }
    }  
}

""
"____________________________________"
"                               Done."
