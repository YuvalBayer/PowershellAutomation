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

function Push-Dir {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Position = 0, Mandatory=$true)]
        [string]
        $source_dir,

        [Parameter(Position = 1, Mandatory=$true)]
        [string]
        $dest_dir
    )

    $made_changes = $false

    # get all items except those who belong to .git folder
    $items = Get-ChildItem $source_dir -Recurse | Where-Object{$_.FullName -notlike '*.git*'}
    foreach ($source_item in $items) {
        # create full path destination
        $full_path_source = $source_item.FullName.ToString()
        $rel_path_source = $full_path_source.Substring($source_dir.Length + 1)
        $full_path_dest = $dest_dir + '\' + $rel_path_source

        # create if does not exist in destination
        if (-not (Test-Path $full_path_dest)) {
            $made_changes = $true

            Write-Host "---------------------------------------------------------"
            Write-Host "Creating"
            Write-Host $full_path_dest
            Write-Host "---------------------------------------------------------"
            Copy-Item -Path $full_path_source -Destination $full_path_dest
        }

        # update if exist in destination
        elseif ((Get-FileHash $full_path_source).hash -ne (Get-FileHash $full_path_dest).hash) {       
            $made_changes = $true
            
            # overide destination if source and destination files are not identical
            Copy-Item -Path $full_path_source -Destination $full_path_dest -Force
            Write-Host "---------------------------------------------------------"
            Write-Host "Pushing"
            Write-Host $full_path_source
            Write-Host "into"
            Write-Host $full_path_dest
            Write-Host "---------------------------------------------------------"
        }
    }
    return $made_changes
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
        Write-Output 'Creating new drive directory...'
        Copy-Item -Path '.' -Destination 'G:\My Drive\' -Recurse
    }

    # update existing directory in drive
    else {
        $made_changes = Push-Dir -source_dir $WD -dest_dir $Destination
    }

    Write-Output 'Drive session is ready'
    Start https://drive.google.com/drive/u/1/my-drive

    $confirm = ''
    while (($confirm -ne 'CONFIRM') -and ($confirm -ne 'NO CHANGES')) {
        $confirm = Read-Host "Confirm end of session by: `nChanges are expected [CONFIRM]`nNothing has changed [NO CHANGES]`n:"
    }

    if ($confirm -eq 'NO CHANGES') {
        Write-Output 'Session ended successfully'
    }

    else {
        Write-Output 'Pulling changes into local machine'
        $made_changes = $false
        $c = 0
        while (($made_changes -eq $false) -and ($c -lt 30)) {
            Start-Sleep -Seconds 3
            $c += 3
            $made_changes = Push-Dir -source_dir $Destination -dest_dir $WD
        }
        
        if ($made_changes -eq $false) {
            Write-Output 'No changes were pulled to local machine - check internet connection'
        }
        else {
            Write-Output 'Session ended successfully'
        }
    }
}




