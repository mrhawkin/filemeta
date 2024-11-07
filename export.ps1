# Define the directory path and output CSV file path
$directoryPath = "C:\path\to\your\files"
$outputCsvPath = "C:\path\to\output\metadata.csv"

# Export metadata to CSV with relative paths and owner information
Get-ChildItem -Path $directoryPath -Recurse | ForEach-Object {
    # Get the owner of the file
    $owner = (Get-Acl -Path $_.FullName).Owner

    # Select the metadata properties you want to export
    [PSCustomObject]@{
        RelativePath   = $_.FullName.Substring($directoryPath.Length + 1) # relative path from base directory
        Name           = $_.Name
        Extension      = $_.Extension
        CreationTime   = $_.CreationTime
        LastWriteTime  = $_.LastWriteTime
        LastAccessTime = $_.LastAccessTime
        Length         = $_.Length
        Owner          = $owner
    }
} | Export-Csv -Path $outputCsvPath -NoTypeInformation -Encoding UTF8

Write-Output "Metadata has been exported to $outputCsvPath"
