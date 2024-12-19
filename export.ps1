# Define the directory path and output CSV file path
$directoryPath = "Z:\inputfolder"
$outputCsvPath = "output.csv"

# Export metadata to CSV with relative paths and owner information
Get-ChildItem -Path $directoryPath -Recurse | ForEach-Object {
    # Get the owner of the file
    $acl = Get-Acl -Path $_.FullName
    $owner = $acl.Owner

    # Remove the "O:" prefix if present
    if ($owner -match "^O:") {
        $owner = $owner.Substring(2) # Trim the first two characters ("O:")
    }

    # Check if the owner is now a SID and resolve it to a username
    if ($owner -match "^S-\d-") {
        try {
            $sid = New-Object System.Security.Principal.SecurityIdentifier($owner)
            $owner = $sid.Translate([System.Security.Principal.NTAccount]).Value
        } catch {
            # If translation fails, write empty string
            $owner = ""
        }
    }

    # Extract only the username portion (if it's in DOMAIN\username format)
    if ($owner -match "\\") {
        $owner = $owner.Split("\")[-1]
    }

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
