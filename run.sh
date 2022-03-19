#!/usr/bin/env bash
set -e
shopt -s extglob

release=0

function clean {
  echo $'\e[92mCleaning.\e[0m'
  rm -vrf src/libcalculus.cpp build dist/* annotations docs/{html,doctrees} 2>&1 | sed 's/^/    /g'
  echo
}

function build {
  echo $'\e[92mBuilding.\e[0m'
  {
    if [[ $release == 1 ]] && command -v g++-9 &> /dev/null; then
        export CC='g++-9' CXX='g++-9' LDSHARED='g++-9 -shared'
    fi
    python3 setup.py build_ext --inplace
    mkdir -p annotations
    find src/ include/ -type f -name '*.html' | xargs -i -r mv {} annotations/ && echo "Annotations saved in annotations/"
    echo "Successfully compiled $(wc -l src/!(libcalculus.cpp) include/* | tail -1 | sed -re 's/^\s*([0-9]+)\s+total\s*$/\1/g') lines."
    cd docs
    make html
    cd - &> /dev/null
    echo ;
  } 2>&1 | sed 's/^/    /g' &> /dev/stderr
}

function run_tests {
  echo $'\e[92mTesting.\e[0m'
  python3 test.py --ComplexFunction --RealFunction --Contour
  echo
}

if [[ $# == 0 ]]; then # default action - build
  build
else
  while [[ $# > 0 ]]; do
    case $1 in
      '--release') release=1 ;;
      'clean') clean ;;
      'build') build ;;
      'test') run_tests ;;
      *) echo "Unknown parameter: \"$1\""; exit 1 ;;
    esac
    shift
  done &> /dev/stderr
fi
