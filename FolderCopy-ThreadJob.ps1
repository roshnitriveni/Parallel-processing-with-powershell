#Add files/folders to sourcefolder so that will be copied in dest folder
$origin=$PSScriptRoot
Write-Host $origin
function sync(){
$source = $origin +"\Source"  
$target = $origin +"\Dest\A"   
$target2 = $origin +"\Dest\B"   
Copy-Item -Path $source\* -Destination $target -Recurse   -Force
Copy-Item -Path $source\* -Destination $target2 -Recurse   -Force
}


function async(){
$source = $origin+"\Source"  
$target = $origin+"\Dest\A"   
$copyJob1 = Start-ThreadJob –ScriptBlock {  
   
    Copy-Item -Path $using:source\* -Destination $using:target -Recurse   -Force
}
#Code here will run async  
$target2 = $origin+ "\Dest\B"   
$copyJob2 = Start-ThreadJob –ScriptBlock {  
   
    Copy-Item -Path $using:source\* -Destination $using:target2 -Recurse   -Force
}
#Code here will run async  
Wait-Job $copyJob1  
Wait-Job $copyJob2  
}
Measure-Command{ sync}
Measure-Command{ async}
#Get-Job|Remove-Job