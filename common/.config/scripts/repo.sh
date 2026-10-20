#!/bin/bash

GITHUB_USERNAME="${GITHUB_USERNAME:-}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
REPO_NAME="$1"
REPO_DIR="$2"
REPO_PRIVATE="TRUE"
REPO_SECRET=""

# Check if username and token is set in .bashrc || .bash_profile || .zshrc
if [ -z "$GITHUB_USERNAME" ] || [ -z "$GITHUB_TOKEN" ]; then
  echo "Please set USERNAME and TOKEN in environment variables."
  echo "For example, add the following lines to your ~/.bashrc, ~/.bash_profile, or ~/zshrc"
  echo "export GITHUB_USERNAME='username_here'"
  echo "export GITHUB_TOKEN='token_here'"
  exit 1;
fi

# Check if the repo name was provided
if [ -z "$REPO_NAME" ]; then
  echo "Usage: $0 <repo-name>"
  exit 1
fi

# Add key to ssh-agent
ssh-add ~/.ssh/id_ed25519/github

# Check that jq, curl and git are installed
command -v jq >/dev/null 2>&1 || { echo >&2 "Requires jq to be installed, aborting."; exit 1;}
command -v curl >/dev/null 2>&1 || { echo >&2 "Requires curl to be installed, aborting."; exit 1;}
command -v git >/dev/null 2>&1 || { echo >&2 "Requires git to be installed, aborting."; exit 1;}
command -v pwd >/dev/null 2>&1 || { echo >&2 "Requires pwd to be installed, aborting."; exit 1;}

#Ask for public/private repo
while true; do
  read -p "Private repo? (y/n) " private 
  case $private in
    [yY] ) REPO_PRIVATE="true";
      break;;
    [nN] ) REPO_PRIVATE="false";
      break;;
  esac
done

echo "Sending curl"

# Create GitHub repository
RESPONSE=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" -d "{\"name\":\"$REPO_NAME\", \"private\": $REPO_PRIVATE}" https://api.github.com/user/repos)
REPO_URL=$(echo "$RESPONSE" | jq -r .ssh_url)

# Verify its created
if [ "$REPO_URL" == "null" ]; then
  echo "Failed to create GitHub repository."
  echo "$RESPONSE"
  exit 1
else
  echo "Repository created successfully: $REPO_URL"
fi

# What authentication to use locally
while true; do
  read -p "Use SSH authentication? (y/n) " ssh
  case $ssh in
    [yY] ) REPO_URL=$(echo "$RESPONSE" | jq -r .ssh_url)
      REPO_SECRET=$REPO_URL
      break;;
    [nN] ) REPO_URL=$(echo "$RESPONSE" | jq -r .html_url) 
      # Insert the token into the URL
      REPO_SECRET="${REPO_URL:0:8}$GITHUB_USERNAME:$GITHUB_TOKEN@${REPO_URL:8}"
      break;;
  esac
done

# If no dir provided use where its run from
if [ -z "$REPO_DIR" ]; then
  REPO_DIR=$(pwd)
fi

# Create project directory
mkdir "$REPO_DIR/$REPO_NAME" 
cd "$REPO_DIR/$REPO_NAME" || exit

# Initialize git and create basic files
git init
git checkout -b main
echo "# $REPO_NAME" > README.md
echo -e ".git/\n.cache/\nout/\ncompile_commands.json" > .gitignore

# Add and commit changes
git add .
git commit -m "First commit"

# Add remote and push to GitHub
git remote add origin "$REPO_SECRET"
git push -u origin main

echo "Repository created at $REPO_URL"
