# Define the directory path and output CSV file path
$directoryPath = "Z:\support\haagen"
$outputCsvPath = "C:\temp\output.csv"

# Function to get the owner of a file or folder
function Get-Owner {
    param ([string]$Path)

    try {
        $acl = Get-Acl -Path $Path
        $owner = $acl.Owner

        # Remove the "O:" prefix if present
        if ($owner -match "^O:") {
            $owner = $owner.Substring(2)
        }

        # Check if the owner is a SID and resolve it to a username
        if ($owner -match "^S-\d-") {
            $sid = New-Object System.Security.Principal.SecurityIdentifier($owner)
            $owner = $sid.Translate([System.Security.Principal.NTAccount]).Value
        }

        # Extract only the username portion (if it's in DOMAIN\username format)
        if ($owner -match "\\") {
            $owner = $owner.Split("\")[-1]
        }

        return $owner
    } catch {
        # Return empty string if any error occurs
        return ""
    }
}

# Main script to export metadata
$items = Get-ChildItem -Path $directoryPath -Recurse | ForEach-Object {
    $relativePath = $_.FullName.Substring($directoryPath.Length + 1) # Relative path from base directory
    $name = if ($_.PSIsContainer) { "" } else { $_.Name }           # Name is blank for folders
    $owner = Get-Owner -Path $_.FullName                            # Get the owner using the function

    # Remove the leading dot from the extension
    $extension = if ($_.Extension.StartsWith(".")) { $_.Extension.Substring(1) } else { $_.Extension }

    # Determine if the item is a folder or a file
    $itemType = if ($_.PSIsContainer) { "Folder" } else { "File" }

    # Select the metadata properties you want to export
    [PSCustomObject]@{
        RelativePath   = if ($_.PSIsContainer) { $relativePath } else { (Split-Path -Path $relativePath) }
        Name           = $name
        Extension      = $extension
        ItemType       = $itemType
        CreationTime   = $_.CreationTime
        LastWriteTime  = $_.LastWriteTime
        LastAccessTime = $_.LastAccessTime
        Bytes          = if ($_.PSIsContainer) { "" } else { $_.Length } # Length is blank for folders
        Owner          = $owner
    }
}

# Sort the items
$sortedItems = $items | Sort-Object -Property RelativePath, Name

# Export to CSV
$sortedItems | Select-Object -Property RelativePath, Name, Extension, ItemType, CreationTime, LastWriteTime, LastAccessTime, Bytes, Owner | Export-Csv -Path $outputCsvPath -NoTypeInformation -Encoding UTF8

Write-Output "Metadata has been exported to $outputCsvPath"