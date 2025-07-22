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

while IFS= read -r FILE_PATH || [[ -n "$FILE_PATH" ]]; do
    # Trim whitespaces
    FILE_PATH=$(echo "$FILE_PATH" | xargs)

    if [[ -z "$FILE_PATH" ]]; then
        continue
    fi

    echo "::info Creating evidence for: $FILE_PATH"
    OUTPUT=$(./jf evd create --sigstore-bundle $FILE_PATH 2>&1)

    if [ $? -eq 0 ]; then
        echo "::info Evidence created successfully for $FILE_PATH: $OUTPUT"
    else
        echo "::warning Failed to create evidence for $FILE_PATH: $OUTPUT"
    fi
done < "$ATTESTATION_PATHS_FILE"