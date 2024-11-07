# Define the base directory and input CSV file path
$directoryPath = "C:\path\to\your\files"  # Set to the new directory if files have moved
$inputCsvPath = "C:\path\to\output\metadata.csv"

# Import metadata from CSV and apply to files
Import-Csv -Path $inputCsvPath | ForEach-Object {
    # Construct the full file path based on the relative path
    $filePath = Join-Path -Path $directoryPath -ChildPath $_.RelativePath

    # Check if the file exists before applying metadata
    if (Test-Path -Path $filePath) {
        # Get the file item
        $file = Get-Item -Path $filePath

        # Restore modifiable metadata properties (timestamps)
        $file.CreationTime = [datetime]$_.CreationTime
        $file.LastWriteTime = [datetime]$_.LastWriteTime
        $file.LastAccessTime = [datetime]$_.LastAccessTime

        # Restore the Owner property
        $acl = Get-Acl -Path $filePath
        $acl.SetOwner([System.Security.Principal.NTAccount]$_.Owner)
        Set-Acl -Path $filePath -AclObject $acl

        Write-Output "Metadata restored for file: $filePath"
    } else {
        Write-Output "File not found: $filePath"
    }
}

Write-Output "Metadata restoration completed."
