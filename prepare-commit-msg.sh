#!/bin/bash
if [ -z "$BRANCHES_TO_SKIP" ]; then
  BRANCHES_TO_SKIP=(master develop staging)
fi

BRANCH_NAME=$(git symbolic-ref --short HEAD)
BRANCH_EXCLUDED=$(printf "%s\n" "${BRANCHES_TO_SKIP[@]}" | grep -c "^$BRANCH_NAME$")
TRIMMED=$(echo $BRANCH_NAME | sed 's/^\([A-Z]*-[0-9]*\).*$/\1/')

if [ "$BRANCH_NAME" != "" ] && ! [[ $BRANCH_EXCLUDED -eq 1 ]]; then
  cp $1 ${1}.bak
  cat << EOF > "${1}"

# <type>(<scope>): <description>
#
# Previous commits on this branch:
$(git cherry -v master | sed 's/^/# /')
#
# Type must be one of the following:
# - build: Changes that affect the build system or external dependencies
#   (example scopes: yarn, typescript)
# - ci: Changes to our CI configuration files and scripts (example scopes:
#   semantic-release, gitub-actions)
# - chore: Some other change to the developer experience of the project that
#   isn't strictly the build system or the CI configuration
# - docs: Documentation only changes
# - feat: A new feature
# - fix: A bug fix
# - perf: A code change that improves performance
# - refactor: A code change that neither fixes a bug nor adds a feature
# - style: Changes that do not affect the meaning of the code (white-space,
#   formatting, missing semi-colons, etc)
# - test: Adding missing tests or correcting existing tests

$TRIMMED

$(cat $1)
EOF
fi
