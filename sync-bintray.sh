#!/usr/bin/env bash

API_HOST=api.bintray.com

ORG=pantsbuild
REPOSITORY=maven
PACKAGE=repo
VERSION=0.0.1

URL=https://${API_HOST}/content/${ORG}/${REPOSITORY}/${PACKAGE}/${VERSION}

function check_netrc {
  [[ -f ~/.netrc && -n "$(grep -E "^\s*machine\s+${API_HOST}\s*$" ~/.netrc)" ]]
}

if ! check_netrc
then
  echo "In order to publish bintray binaries you need an account"
  echo "with membership in the ${ORG} org [1]."
  echo
  echo "This account will need to be added to a ~/.netrc entry as follows:"
  echo 
  echo "machine ${API_HOST}"
  echo "  login <bintray username>"
  echo "  password <bintray api key [2]>"
  echo
  echo "[1] https://bintray.com/${ORG}"
  echo "[2] https://bintray.com/docs/interacting/interacting_apikeys.html"
  exit 1
fi

echo "Uploading artifacts to https://dl.bintray.com/${ORG}/${REPOSITORY}/${PACKAGE}"
echo
echo "Press CTRL-C at any time to discard the uploaded artifacts; otherwise,"
echo "the artifacts will be finalized and published en-masse just before the"
echo "script completes."
echo

archive=$(mktemp -t "repo.XXXXXX.zip") && \
git archive HEAD -o ${archive} && \
trap "rm -f ${archive}" EXIT && \
(
  echo "The following zip will be uploaded:"
  echo "=="
  zipinfo -1 ${archive}
) | less -EF && \
curl \
  --fail \
  --netrc \
  --upload-file ${archive} \
  -o /dev/null \
  --progress-bar \
  -# \
  "${URL}/$(basename ${archive})?override=1&explode=1&publish=1"

