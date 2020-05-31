Function Sync(){
    1..5| foreach {
     Write-Host "Executing Sync "$_
     # Twilio API endpoint and POST params
    $url = "https://jsonplaceholder.typicode.com/posts/"+$_
    $params = @{ To = "+15558675309"; From = $number; Body = "Hello from PowerShell" }


    Invoke-WebRequest $url -Method Get | ConvertFrom-Json | Select body
    #Write-Host $response
     }
 }
 
 Function ASync(){

    1..5| ForEach-Object -ThrottleLimit 2 -Parallel  {
     Write-Host "Executing Async "$_
     # Twilio API endpoint and POST params
    $url = "https://jsonplaceholder.typicode.com/posts/"+$_
    $params = @{ To = "+15558675309"; From = $number; Body = "Hello from PowerShell" }

     $response=Invoke-WebRequest $url -Method Get | ConvertFrom-Json | Select body
    # Write-Host $response
 }
}
 #Async
Measure-Command {Async}
Measure-Command {sync}