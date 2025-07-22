#!/bin/bash

set -euo pipefail

# Folder where the runner temp files are stored
RUNNER_TEMP=${RUNNER_TEMP:-""}

if [[ -z "$RUNNER_TEMP" ]]; then
    echo "::warning RUNNER_TEMP environment variable is not set. Skipping evidence creation."
    exit 0
fi

ATTESTATION_PATHS_FILE="$RUNNER_TEMP/created_attestation_paths.txt"

# Check if attestation paths file exists
if [[ ! -f "$ATTESTATION_PATHS_FILE" ]]; then
    echo "::info No attestation paths file found. Skipping evidence creation. Searched for: $ATTESTATION_PATHS_FILE."
    exit 0
fi

echo "::info Reading attestation paths file: $ATTESTATION_PATHS_FILE"
mapfile -t FILE_PATHS < "$ATTESTATION_PATHS_FILE"

# If no file paths are found, skip evidence creation
if [[ ${#FILE_PATHS[@]} -eq 0 ]]; then
    echo "::info No sigstore bundle files found in attestation paths file."
    exit 0
fi

echo "::info Found ${#FILE_PATHS[@]} sigstore bundle file(s) to process."

for FILE_PATH in "${FILE_PATHS[@]}"; do
    # Trim whitespaces
    FILE_PATH=$(echo "$FILE_PATH" | xargs)
    
    if [[ -z "$FILE_PATH" ]]; then
        continue
    fi

    echo "::info Creating evidence for: $FILE_PATH"
    OUTPUT=$(jf evd create --sigstore-bundle "$FILE_PATH" 2>&1)

    if [ $? -eq 0 ]; then
        echo "::info Evidence created successfully for $FILE_PATH: $OUTPUT"
    else
        echo "::warning Failed to create evidence for $FILE_PATH: $OUTPUT"
    fi
done