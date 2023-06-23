#!/bin/sh

# Pull the gitleaks docker image
docker pull zricethezav/gitleaks

# Run the pre-commit install inside a docker container
docker run --rm -v "$(pwd)":/src -w /src python:3.10.12 bash -c "pip install pre-commit && pre-commit install"
