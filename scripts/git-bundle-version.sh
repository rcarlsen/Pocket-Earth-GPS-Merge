#!/bin/sh

# create a bundle version using git commit information
# assumes that this script is run as part of an Xcode build and has access to
# Xcode specific ENV VARS.

# this script auto-generates a swift file called "Version.swift"

# assumes that we are running in a git repo:
GIT_COMMIT_COUNT="`git rev-list HEAD --count`"
GIT_VERSION_STRING="`git log -n1 --date=short --pretty='%cd %h'` (${GIT_COMMIT_COUNT})"
#echo $GIT_VERSION_STRING

cat <<EOF > "${SRCROOT:-.}/Version.swift"
// Auto-generated file. Do not modify.

struct Version {
  static let buildVersionString = "${GIT_VERSION_STRING}"
  static let buildVersion = ${GIT_COMMIT_COUNT:-0}
}

EOF

