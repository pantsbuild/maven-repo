#!/usr/bin/env bash

BASE_URL=http://maven.twttr.com

function url() {
  local org=$1
  local name=$2
  local rev=$3

  echo ${BASE_URL}/${org//.//}/${name}/${rev}
}

function grab_directory() {
  local directory=$1

  wget \
    --quiet \
    --show-progress \
    --recursive \
    --no-parent \
    -e robots=off \
    --wait 1 \
    --no-host-directories \
    --reject "*.html*" \
      ${directory}
}

function grab_artifacts() {
  local org=$1
  local name=$2
  local rev=$3

  local directory=$(url ${org} ${name} ${rev})
  grab_directory ${directory}/
}

function calculate_commons_dependencies() {
  local org=$1
  local name=$2
  local rev=$3 

  local pom_url=$(url ${org} ${name} ${rev})/${name}-${rev}.pom
  wget --quiet --output-document=- ${pom_url} | xsltproc grab-commons.xsl -
}

declare -A visited

function visit() {
  local key="$1"

  visited[${key}]="true"
}

function have_visited() {
 local key="$1"

 echo ${visited[${key}]:=false}
}

function calculate_commons_closure() {
  local org=$1
  local name=$2
  local rev=$3

  local key="${org}|${name}|${rev}"
  if [[ "$(have_visited ${key})" == "false" ]]
  then
    visit "${key}"

    echo ${org} ${name} ${rev}

    calculate_commons_dependencies ${org} ${name} ${rev} | while read org name rev
    do
      calculate_commons_closure ${org} ${name} ${rev}
    done
  fi
}

if (( $# != 3 ))
then
  echo "Usage: $0 [org] [name] [rev]"
  echo
  echo "You must supply the org, name and rev of root of the artifact"
  echo "graph you want to download."
  exit 1
fi

calculate_commons_closure $1 $2 $3 | sort -u | while read org name rev
do
  grab_artifacts ${org} ${name} ${rev}
done
