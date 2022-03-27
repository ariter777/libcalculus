#!/usr/bin/env bash
set -e
shopt -s extglob

release=0

function clean {
  echo $'\e[92mCleaning.\e[0m'
  rm -vrf src/libcalculus.cpp src/*.html build dist/* annotations __pycache__ libcalculus.egg-info docs/{html,doctrees}
  echo
}

function build {
  echo $'\e[92mBuilding.\e[0m'
  if [[ $release == 1 ]] && command -v g++-9 &> /dev/null; then
      export CC='g++-9' CXX='g++-9' LDSHARED='g++-9 -shared'
  elif [[ $debug == 1 ]]; then
      export CXXFLAGS="$CXXFLAGS -Og -DNDEBUG"
  fi
  python3 setup.py build_ext --inplac
  mkdir -p annotations
  find src/ include/ -type f -name '*.html' | xargs -i -r mv {} annotations/ && echo "Annotations saved in annotations/"
  echo "Successfully compiled $(wc -l src/!(libcalculus.cpp) include/* | tail -1 | sed -re 's/^\s*([0-9]+)\s+total\s*$/\1/g') lines."
  cd docs
  make html
  cd - &> /dev/null
  echo;
}

function run_tests {
  echo $'\e[92mTesting.\e[0m'
  python3 test.py --ComplexFunction --RealFunction --Contour --Function
  echo
}

if [[ $# == 0 ]]; then # default action - build
  build
else
  while [[ $# > 0 ]]; do # switch case won't exit if a command fails, so an if must be used.
    if [[ $1 == '--release' ]]; then
      if [[ $debug == 1 ]]; then
        echo "Options `--debug` and `--release` cannot be combined."
        exit 1
      fi
      release=1
    elif [[ $1 == '--debug' ]]; then
      if [[ $release == 1 ]]; then
        echo "Options `--debug` and `--release` cannot be combined."
        exit 1
      fi
      debug=1
    elif [[ $1 == 'clean' ]]; then
      clean
    elif [[ $1 == 'build' ]]; then
      build
    elif [[ $1 == 'test' ]]; then
      run_tests
    else
      echo "Unknown parameter: \"$1\""; exit 1
    fi
    shift
  done &> /dev/stderr
fi
