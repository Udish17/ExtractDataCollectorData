# This script will extract the tar file collected by the SCOM Linux Data Collector
# https://github.com/Udish17/SCOMLinuxDataCollector
# Author: udmudiar (Udishman/Udish)

function Expand-Tar($tarFile, $dest) {

    if (-not (Get-Command Expand-7Zip -ErrorAction Ignore)) {
        Install-Package -Scope CurrentUser -Force 7Zip4PowerShell > $null
    }

    try{
        Expand-7Zip $tarFile $dest -ErrorAction Stop
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
        $break = "False"
        $data = Get-ChildItem -Path $dest -Exclude "*tar"
        for($i = 1; $i -lt 10; $i++)
        {
            $items = Get-ChildItem -Path $data -Depth $i
    
            foreach($item in $items)
            {
                if($item.Name -eq "SCXDetails.txt" -or $item.Name -eq "omsagent.log")
                {
                    $copypath = $item.DirectoryName + "\*"
                    $removepath = $dest + "\" + $data.Name
                    Copy-Item -Path $copypath -Destination $dest -Recurse -Force
                    #remove the linux folder structure
                    Remove-Item -Path $removepath -Recurse -Force
                    #remove the tar file
                    Remove-Item -Path $desttar -Force
                    $break = "True"            
                }
            }  
            if($break -eq "True")
            {
                break;
            }     
        } 
    }
    catch{
        $ErrorMessage = $_.Exception.Message
        $ErrorMessage
        Write-Error "Exiting Script.." 
        Exit
    }
}

#script starts here
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

        Expand-Tar "$tarfile" "$dest"
        $tar= (Get-ChildItem -Path "$dest").Name
        $desttar = $dest + "\" + $tar
        Expand-Tar $desttar "$dest"
        CleanHierarchy
        #remove the tar.gz
        #Remove-Item -Path $sourcefile.Name -Recurse -Force
    }
    else
    {
        Write-Warning "`t The destination path is already present. Looks the data is extracted. Exiting.."
        Start-Sleep 2
        Exit
    }
}






