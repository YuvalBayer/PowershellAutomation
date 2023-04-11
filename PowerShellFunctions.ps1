<#
.SYNOPSIS
    Sort all files according to their size
.DESCRIPTION
    The function 
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>
function Get-FilesByLength {
    [CmdletBinding()] # endow the function with advanced features assosiated with cmdlet
    param (
        [Parameter(Position = 0)]
        [string]
        $Path = (Get-Location),

        [Parameter(Position = 1)]
        [int]
        $Head = 10
    )

    [string]$WD = Get-Location # get working directory path as string

    # complete the path with its full form in case of relative path
    if ($Path[0] -eq ".") {
        $Path =  $WD + $Path.Substring(1)
    }

    # get all items of the path
    try {
        $Items = Get-ChildItem -Path $Path -Recurse -ErrorAction Stop
    }
    catch {
        throw 'Path does not exist'
    }

    # verify valid value of head
    if ($Head -gt $Items.Length) {
        $Head = $Items.Length
    }

    if ($Head -lt 1) {
        $Head = 0
    }

    # sort all items by size
    $ItemsSorted = $Items | Sort-Object Length -Descending


    # create table
    $Table = New-Object System.Data.Datatable

    # add columns
    [void]$Table.Columns.Add("File relative path")
    [void]$Table.Columns.Add("Size [MB]")

    $total_size = 0

    Foreach($item in $ItemsSorted)
    {
    $rel_path = $item.Fullname.ToString().Substring($WD.Length + 1)
    $size = ($item.Length / 1e6) # [KB] -> [MB]
    [void]$Table.Rows.Add($rel_path, $size)

    $total_size += $size
    }
    $total_files = $Table.Rows.Count

    [void]$Table.Rows.Add('', "$total_size total")

    $Table | Select-Object -First $Head
    Write-Output "`nTotal size: $total_size MB"
    Write-Output "Total files: $total_files"
}

function Start-DriveSession {
    [string]$WD = Get-Location # get working directory path as string

    try {
        $git_status = git status -s
    }
    catch {
        throw 'This current directory project must be initialized with git'
    }

    if ($git_status.Length -ne 0) {
        throw 'Commit directory changes'
    }

    Write-Output 'Starting session'

    # set destination to be pushed
    $Destination = 'G:\My Drive\' + $WD.split('\')[-1]

    # create new directory in drive if does not exist
    if (-not (Test-Path $Destination)) {
        mkdir $Destination
    }

    # update existing directory in drive using Windows Robust Copy
    # /e = all files (including empty subdirectories)
    # /mt = multithreading (8)
    # /eta = present progress as ETA
    # /xf excluding files starting with .
    # /xd excluding directories starting with .

    $excludeDot = ".*"
    robocopy $WD $Destination /e /mt /eta /xf $excludeDot /xd $excludeDot

    Write-Output 'Drive session is ready'
    Start https://drive.google.com/drive/u/1/my-drive

    Write-Output 'Confirm end of session by:'
    $open = Read-Host "(1) Open drive directory [OPEN]"
    while ($open -ne 'OPEN') {
        $open = Read-Host "(1) Open drive directory [OPEN]"
    }
    start $Destination

    $confirm = Read-Host "(2) Confirm changes [CONFIRM]"
    while ($confirm -ne 'CONFIRM') {
        $confirm = Read-Host "(2) Confirm changes [CONFIRM]"
    }

    robocopy $Destination $WD /e /mt /eta
    Write-Output 'Session ended successfully'
}




