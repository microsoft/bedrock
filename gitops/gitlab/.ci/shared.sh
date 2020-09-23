#!/bin/bash

declare -a ENVIRONMENTS=("dev" "integration" "prod")

function generate_manifests()
{
  fab install
  for i in "${ENVIRONMENTS[@]}"
  do
    fab generate $i
  done
}
