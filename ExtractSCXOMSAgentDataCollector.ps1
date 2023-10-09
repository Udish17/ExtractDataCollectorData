# This script will extract the tar file collected by the SCOM Linux Data Collector and OMS Agent Troubleshooter
# https://github.com/Udish17/SCOMLinuxDataCollector
# https://github.com/microsoft/OMS-Agent-for-Linux/blob/master/docs/Troubleshooting-Tool.md
# Author: udmudiar (Udishman/Udish)

<#function Expand-Tar($file, $dest) {

    if (-not (Get-Command Expand-7Zip -ErrorAction Ignore)) {
        Install-Package -Scope CurrentUser -Force 7Zip4PowerShell > $null
    }

    try{
        Expand-7Zip $file $dest -ErrorAction Stop
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        Write-Warning "If the file path is too long we might fail. Not a FATAL error."
        $ErrorMessage
    }    
}
#>

function Expand-Tar($file, $dest) {

    try{
        tar.exe xC $dest -f $file
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        Write-Warning "If the file path is too long we might fail. Not a FATAL error."
        $ErrorMessage
    }    
}

function CleanHierarchy()
{
    Write-Host "`t Cleaning Hierarchy.." -ForegroundColor Cyan
    Start-Sleep 2

    try{        
        #complex logic. adding comments for future understanding
        #we want to copy only the files collected by the data collector
        #and not the hirerachy direcotries
        #wso start with get the root directory where the data was collected
        $rootdir = (Get-ChildItem -Path $dest -Directory).FullName

        #from the dest directory get the depth count
        $depth = Get-ChildItem $dest -Recurse -Name | ForEach-Object {($_.ToCharArray() | 
            where-Object {$_ -eq '\'} | Measure-Object).Count} | Measure-Object -Maximum | ForEach-Object Maximum

        Write-Host "Depth = $($depth)" -ForegroundColor Green

        #3 depth is the typical depth as per the strucuture the data collector creates.
        #copy path (from where we will copy our content at the end of the depth) is assigned by enumerating all the depths and selecting the last 1
        if($depth -ge 3){
            $copypath = (Get-ChildItem -Path $rootdir -Directory -Depth ($depth - 3) | Select-Object -Last 1).FullName
        }
        #however, there can also be a depth of 2.
        elseif($depth -eq 2){
            $copypath = (Get-ChildItem -Path $rootdir -Directory -Depth ($depth - 2) | Select-Object -Last 1).FullName
        }
        
        #copy the content
        Copy-Item -Path "$copypath\*" -Destination $dest -Recurse -Force
        #remove the linux folder structure
        Remove-Item -Path $rootdir -Recurse -Force
        #remove the tar file
        #Remove-Item -Path $desttar -Force     
    }
    catch{
        $ErrorMessage = $_.Exception.Message
        $ErrorMessage
        Write-Error "Exiting Script.." 
        Exit
    }
}

#script starts here
Write-Host "Script Started.." -ForegroundColor Green
$sourcepath = (Get-Location).Path
$sourcepath = $sourcepath + "\"
$sourcefiles = Get-ChildItem -Path $sourcepath -Recurse -Include "*tar.gz" , "*tgz"

foreach($sourcefile in $sourcefiles){
    Write-Host "Extracing tar file $($sourcefile) .." -ForegroundColor Magenta
    $setdestinationfolder=$sourcefile.Name.Split(".")[0]

    $tarfile = $sourcepath + $sourcefile.Name
    $dest = $sourcepath + $setdestinationfolder

    if(!(Test-Path $dest))
    {
        Write-Host "`t Extracting data.." -ForegroundColor Cyan
        Start-Sleep 2

        New-Item -Name $setdestinationfolder -ItemType Directory -Force | Out-Null
        #here we are extracting
        Expand-Tar "$tarfile" "$dest"
        #$tar= (Get-ChildItem -Path "$dest").Name
        #$desttar = $dest + "\" + $tar
        #Expand-Tar "$desttar" "$dest"
        
        CleanHierarchy
        #remove the tar.gz or tgz file
        Remove-Item -Path $sourcefile.Name -Recurse -Force
    }
    else
    {
        Write-Warning "`t The destination path is already present. Looks the data is extracted. If you want to reextract, delete the extracted data and rerun the script. Exiting.."
        Start-Sleep 2
        Exit
    }
}

Write-Host "Script Ended.." -ForegroundColor Green






