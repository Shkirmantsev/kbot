#!/bin/sh

# Define the path to the pre-commit hook
HOOK_PATH=".git/hooks/pre-commit"

# Create/recreate the pre-commit hook file
cat << 'EOF' > $HOOK_PATH
#!/bin/sh

echo "Running pre-commit hook"

# Use git config to enable/disable the script. The "hooks.gitleaks" can be set with the command:
#   git config --bool hooks.gitleaks true
# To enable the hook, and:
#   git config --bool hooks.gitleaks false
# To disable it.

if [ "$(git config --bool hooks.gitleaks)" != "true" ]; then
  echo "Skipping gitleaks script"
  exit 0
fi

# Assign the script path to a variable
SCRIPT_PATH="./secops/local/run-gitleaks.sh"

# Get a list of all files staged for commit except deleted files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

# Get a list of all deleted files staged for commit
DELETED_FILES=$(git diff --cached --name-only --diff-filter=D)

# Make a temporary commit
if ! git commit --no-verify -m "Temporary commit for Gitleaks"; then
  echo "Failed to make temporary commit"
  exit 1
fi

# Get the commit hash
COMMIT_HASH=$(git rev-parse HEAD)

# Check if the script file exists and is executable
if [ ! -x "$SCRIPT_PATH" ]; then
    echo "The script $SCRIPT_PATH does not exist or is not executable"
    git reset HEAD~1
    exit 1
fi

# Run the gitleaks script with the commit hash
sh $SCRIPT_PATH $COMMIT_HASH

# Check the exit status of the script
if [ $? -ne 0 ]; then
    echo "The gitleaks check failed, commit aborted"
    # Undo the temporary commit
    git reset HEAD~1
    exit 1
fi

# Undo the temporary commit
git reset HEAD~1

# Re-stage the changes
echo "Gitleaks check passed, restaging changes"
for FILE in $STAGED_FILES; do git add $FILE; done
for FILE in $DELETED_FILES; do git add $FILE; done

echo "Making commit"

EOF

# Detect the operating system
OS="$(uname)"

# Make the pre-commit hook executable on Unix-like systems only
if [ "$OS" = "Linux" ] || [ "$OS" = "linux" ] || [ "$OS" = "Darwin" ] || [ "$OS" = "darwin" ] || [[ "$OS" =~ CYGWIN.* ]] || [[ "$OS" =~ MINGW.* ]]
then
    chmod +x $HOOK_PATH
fi
