#!/bin/bash

set -e

if [ -z "${WIKI_PERSONAL_ACCESS_TOKEN}" ]; then
  if [ -z "${GITHUB_PERSONAL_ACCESS_TOKEN}" ] ; then
    echo "WIKI_PERSONAL_ACCESS_TOKEN not set"
    exit 1
  fi
  WIKI_PERSONAL_ACCESS_TOKEN="${GITHUB_PERSONAL_ACCESS_TOKEN}"
fi
if [ -z "${GITHUB_SERVER_URL}" ]; then
  GITHUB_SERVER_URL=https://github.com
fi
if [ -z "$GITHUB_REPOSITORY" ]; then
  GITHUB_REPOSITORY="xis10z/Code-LWFIT"
fi

echo
echo "# Cloning github wiki"
git clone "https://${WIKI_PERSONAL_ACCESS_TOKEN}@${GITHUB_SERVER_URL#https://}/$GITHUB_REPOSITORY.wiki.git"
wiki_dir="`basename $GITHUB_REPOSITORY.wiki`"

echo
echo "# Sync'ing with qyber wiki"
cd "$wiki_dir"
git remote add qyber https://qyber.black/mrs/code-lwfit.wiki.git
git config --global user.email "frank@langbein.org"
git config --global user.name "Frank C Langbein (via github actions)"
git config pull.rebase false
git fetch qyber master
git merge --no-edit qyber/master
cd ..

echo
echo "# Update home"
cd "$wiki_dir"
if ! diff -q home.md Home.md; then
  echo "## Home wikis are different"
  cp home.md Home.md
  git add Home.md
  git commit -m "Automatically copied home.md to Home.md"
fi
cd ..

echo
echo "# Update wiki"
cd "$wiki_dir"
git push
