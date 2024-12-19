# Define the directory path and input CSV file path
$directoryPath = "Z:\exportfolder"
$inputCsvPath = "metadata.csv"

# Read the metadata from the CSV file
$metadataList = Import-Csv -Path $inputCsvPath

# Iterate over each metadata entry
foreach ($metadata in $metadataList) {
    # Construct the full path of the file from the relative path
    $filePath = Join-Path -Path $directoryPath -ChildPath $metadata.RelativePath

    # Check if the file exists
    if (Test-Path -Path $filePath) {
        try {
            # Update file timestamps
            Set-ItemProperty -Path $filePath -Name CreationTime -Value ([datetime]$metadata.CreationTime)
            Set-ItemProperty -Path $filePath -Name LastWriteTime -Value ([datetime]$metadata.LastWriteTime)
            Set-ItemProperty -Path $filePath -Name LastAccessTime -Value ([datetime]$metadata.LastAccessTime)

            # Update ownership if possible
            $owner = $metadata.Owner
            if ($owner -and $owner -match "\\") {
                $acl = Get-Acl -Path $filePath
                $user = New-Object System.Security.Principal.NTAccount($owner)
                $acl.SetOwner($user)
                Set-Acl -Path $filePath -AclObject $acl
            }
        } catch {
            Write-Error "Failed to update metadata for $filePath: $_"
        }
    } else {
        Write-Host "File not found: $filePath" -ForegroundColor Yellow
    }
}

Write-Output "Metadata has been imported and applied to files in $directoryPath"
