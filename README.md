# Parallel-processing-with-powershell
Speedup your long running PS scripts with parallel processing

Introduction
------------

Before we jump on to the Parallel Processing concept in powershell, Let’s understand What is Powershell and Parallel (Asynchronous) processing? PowerShell is a Windows command-line shell designed especially for system administrators. While it may look similar to the Command Prompt app in Windows, It is a scalable way for corporate IT managers to automate business-critical tasks on every Windows PC across a wide area network.

##### What is Synchronous?

Each next task will start, once a task started before it gets completed.

##### What is Asynchronous?

All task start execution independently at a same time, without waiting for any other task.
![](synchronous-asynchronous-javascript.png)

Description
-----------

When you think about PowerShell script, you're probably thinking of synchronous execution. This means that PowerShell executes code, one line at a time. It starts executing one command, waits for it to complete, and then starts the next one.

Synchronous execution is fine for scripts In which execution of the next line depends on the execution of a line before it.When you are working with the script that can take many minutes or an hour, You can instead choose to execute code asynchronously with any of the below PS concepts.  

### Jobs (PowerShell 3.0)

Job is a piece of code that is executed in the background, creates n multiple background processes to execute n no. of jobs , each job creates a separate powershell instance to complete execution. (You can find out no. of instances created while running jobs , inside task manager)

![](2020-05-30_11h58_54.png)

##### Different cmdlets to work with PS Jobs

Start-Job : Create and execute job
```ps
1..5 | % {Start-Job  { "Hello" }  }
```
![](2020-05-30_14h09_53.png)

Get-Job : Get all jobs that are started with Start-Job cmd

Wait-Job : Wait for all jobs to complete
```ps
Get-Job | Wait-Job 
```
![](2020-05-30_14h13_26.png)

Receive-Job : To print output of job to console
```ps
Get-Job | Receive-Job
```
![](2020-05-30_14h14_58.png)
Remove-Job : To delete all jobs that were created with Start-Job command
\*Jobs created must be removed with this command
```ps
Get-Job | Remove-Job
```
### ThreadJob (PowerShell 6.0)

This is a thread based job. This is a lighter weight solution compared to Jobs. Unlike traditional PS Jobs which spawn a whole new host process for each running job, PS ThreadJobs run in multiple threads on the same process which vastly increases performance by lowering overhead.

There are a few drawbacks to using a ThreadJob over a background job. If a background job hangs, only that process hangs. All other jobs keep chugging away. If you have a job that hangs with ThreadJob the entire queue is affected

```ps
Measure-Command {1..5 | % {Start-Job {Start-Sleep 1}} | Wait-Job} | Select-Object TotalSeconds
Measure-Command {1..5 | % {Start-ThreadJob {Start-Sleep 1}} | Wait-Job} | Select-Object TotalSeconds

TotalSeconds
------------
   5.7665849
   1.5735008
```
Syntax is quite similar to PSJobs , Job string is replaced with ThreadJob. One parameter is there to set no of jobs you want to start concurrently (i.e. throttle limit , default value is 5)

### Parallel foreach (PowerShell 7.0)

Each iteration of ForEach-Object that is passed in via the Parallel scriptblock input, will run in it’s own thread.This is faster than both the methods.you can run all script in parallel for each piped input object.

 If your script is crunching a lot of data over a significant period of time and if the machine you are running on has multiple cores that can host the script block threads. In this case the -ThrottleLimit parameter should be set approximately to the number of available cores. If you are running on a VM with a single core, then it makes little sense to run high compute script blocks in parallel since the system must serialize them anyway to run on the single core

Scripts that do a lot of file operations, or perform operations on external machines can benefit by running in parallel. Since the running script cannot use all of the machine cores, it makes sense to set the -ThrottleLimit parameter to something greater than the number of cores. If one script execution waits many minutes to complete, you may want to allow tens or hundreds of scripts to run in parallel..

```ps
1..5 | ForEach-Object -Parallel { "Hello $_"; sleep 1; } -ThrottleLimit 5 
Hello 1 
Hello 3 
Hello 2 
Hello 4 
Hello 5
```

Parallel processing is an ideal solution when you want to run the jobs that are independent of each other.

#### Performance test

```ps
#% -> ForEach-Object
Measure-Command {1..5 | % {Start-Sleep 1} } | Select-Object TotalSeconds
#Job
Measure-Command {1..5 | % {Start-Job {Start-Sleep 1}} | Wait-Job} | Select-Object TotalSeconds
#Thread Job
Measure-Command {1..5 | % {Start-ThreadJob -ThrottleLimit 5 {Start-Sleep 1}} | Wait-Job} | Select-Object TotalSeconds
#ForEach-Object Parallel
Measure-Command {1..5 | ForEach-Object -Parallel {Start-Sleep 1} -ThrottleLimit 5} | Select-Object TotalSeconds
```

![](2020-05-31_18h19_13.png)

% represents forech

-   Regular foreach command took almost 5 sec  to run sequentially, each iteration took one second to complete the execution
-   With PS Job it took 7 secs (2s Overhead of starting jobs assigning runspace etc.)
-   With PS ThreadJob it took 1 sec, all executed asynchronously and executed within 1 sec (background job created and we will need to remove it manually)
-   Parallel execution of foreach also completed within a second as runs based on throttle limit which should be set as per the CPU cores.

Scripts attached in repositories are (Executed in VS Code, because it includes concepts of PS 5+ version)
1.  Folder Copy (with Thread Job vs traditional way)
2.  API call with foreach parallel

Referenes:

[https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/parallel-processing-in-powershell](https://www.google.com/url?q=https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/parallel-processing-in-powershell&sa=D&ust=1590933961824000)

[https://mcpmag.com/articles/2018/04/18/background-jobs-in-powershell.aspx](https://www.google.com/url?q=https://mcpmag.com/articles/2018/04/18/background-jobs-in-powershell.aspx&sa=D&ust=1590933961824000)

[https://devblogs.microsoft.com/powershell/powershell-foreach-object-parallel-feature/](https://www.google.com/url?q=https://devblogs.microsoft.com/powershell/powershell-foreach-object-parallel-feature/&sa=D&ust=1590933961824000)

[https://petri.com/comparing-threadjob-to-psjobs-in-powershell-7-on-linux](https://www.google.com/url?q=https://petri.com/comparing-threadjob-to-psjobs-in-powershell-7-on-linux&sa=D&ust=1590933961825000)

