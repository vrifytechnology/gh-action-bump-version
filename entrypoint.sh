#!/bin/sh

set -e

if [ -n "$NPM_AUTH_TOKEN" ]; then
  # Respect NPM_CONFIG_USERCONFIG if it is provided, default to $HOME/.npmrc
  NPM_CONFIG_USERCONFIG="${NPM_CONFIG_USERCONFIG-"$HOME/.npmrc"}"
  NPM_REGISTRY_URL="${NPM_REGISTRY_URL-https://registry.npmjs.org}"

  # Allow registry.npmjs.org to be overridden with an environment variable
  printf "//%s/:_authToken=%s\\nregistry=%s" "$NPM_REGISTRY_URL" "$NPM_AUTH_TOKEN" "$NPM_REGISTRY_URL" > "$NPM_CONFIG_USERCONFIG"
  chmod 0600 "$NPM_CONFIG_USERCONFIG"
fi

sh -c "git checkout master"

remote_repo="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

sh -c 'git config user.name "Automated Publisher"'
sh -c 'git config user.email "publish-to-github-action@users.noreply.github.com"'
sh -c 'git remote rm origin'
sh -c 'git remote add origin "${remote_repo}"'

if [ "$GITHUB_REPOSITORY" = "mikeal/merge-release" ]
then
  echo "node merge-release-run.js"
  sh -c "node merge-release-run.js $*"
else
  echo "npx merge-release"
  sh -c "npx merge-release $*"
fi
