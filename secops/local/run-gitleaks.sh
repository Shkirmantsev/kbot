#!/bin/sh
COMMIT_HASH=$1
docker run --rm -v $(pwd):/path zricethezav/gitleaks:v8.17.0 detect -v --redact --source="/path" --log-opts="-1 --pretty=format:\"%H\""