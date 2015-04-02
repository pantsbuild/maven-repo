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

visited=()

function create_key() {
  echo "$@" | tr ' ' '|'
}

function have_visited() {
  local key=$(create_key "$@")
 
  for element in "${visited[@]}"
  do
    if [[ "${element}" == "${key}" ]]
    then
      return 0
    fi
  done
  return 1
}

function visit() {
  local key=$(create_key "$@")
  visited+=(${key})
}

function calculate_commons_closure() {
  local org=$1
  local name=$2
  local rev=$3
  
  if ! have_visited ${org} ${name} ${rev}
  then
    visit ${org} ${name} ${rev}

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
