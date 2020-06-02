#!/bin/bash

set -ex

function build {
  version=${1:-latest}

  rm -rf build/

   ./gradlew --no-daemon -PenableCrossCompilerPlugin=true orca-web:installDist -x test

  docker build -t nimak/spinnaker-orca:$version -f Dockerfile.slim .
}

function push {
  version=${1:-latest}
  docker push nimak/spinnaker-orca:$version
}

function delete {
  kubectl delete pod -nspinnaker $(kubectl get pods -n spinnaker | grep orca | awk '{print $1}')
}

case "$1" in
  build )
    build $2
    ;;

  push )
    push $2
    ;;

  delete )
    delete
    ;;

  run )
    docker stop orca || true
    docker run -p 8083:8083 --rm --name orca -d nimak/spinnaker-orca:latest
    ;;

  * )
    build
    push
    delete
esac
