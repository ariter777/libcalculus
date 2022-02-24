#!/usr/bin/env bash
set -e
shopt -s extglob

function clean {
  echo $'\e[92mCleaning.\e[0m'
  rm -vrf src/libcalculus.cpp build annotations 2>&1 | sed 's/^/    /g'
  echo
}

function linux_setup {
  echo $'\e[92mBuilding.\e[0m'
  { python setup.py build_ext --inplace
  mkdir -p annotations
  find src/ include/ -type f -name '*.html' | xargs -i -r mv {} annotations/ && echo "Annotations saved in annotations/"
  echo "Successfully compiled $(wc -l src/!(libcalculus.cpp) include/* | tail -1 | sed -re 's/^\s*([0-9]+)\s+total\s*$/\1/g') lines."
  echo ; } 2>&1 | sed 's/^/    /g' &> /dev/stderr
}

function run_tests {
  echo $'\e[92mTesting.\e[0m'
  python test.py
  echo
}

if [[ $# == 0 ]]; then # default build - linux
  linux_setup
else
  while [[ $# > 0 ]]; do
    case $1 in
      'clean') clean ;;
      'linux') linux_setup ;;
      'test') run_tests ;;
      *) echo "Unknown parameter: \"$1\""; exit 1 ;;
    esac
    shift
  done &> /dev/stderr
fi
