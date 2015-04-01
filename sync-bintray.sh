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

# TODO(John Sirois): Use https://api.bintray.com/packages/pantsbuild/maven/repo/files
# which lists all files with sha1s like so to pack smaller archives:
# {
#        "created": "2015-04-01T20:45:57.548Z",
#        "name": "sync-bintray.sh",
#        "owner": "pantsbuild",
#        "package": "repo",
#        "path": "sync-bintray.sh",
#        "repo": "maven",
#        "sha1": "2b8ae9989f173d37780d6fecc9d9c1ed129b3ade",
#        "size": 1418,
#        "version": "0.0.1"
# }
# git ls-files | xargs openssl sha1 | sed -E "s|^SHA1\(([^)]+)\)= ([0-9a-f]+)$|\1 \2|"

# NB: Archives sent to bintray for exploding must not have directory entries inside, just the
# file entries.

archive_dir=$(mktemp -dt "repo.XXXXXX") && \
trap "rm -rf ${archive_dir}" EXIT && \
archive="${archive_dir}/repo.zip" && \
git ls-files | xargs zip -q --no-dir-entries ${archive} && \
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

