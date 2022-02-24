#!/usr/bin/env bash
set -e

{ if [[ $@ > 1 && $1 == 'clean' ]]; then
  echo $'\e[92mCleaning.\e[0m'
  rm -vrf src/libcalculus.cpp build annotations 2>&1 | sed 's/^/    /g'
  echo
fi ; } &> /dev/stderr


echo $'\e[92mBuilding.\e[0m'

{ python setup.py build_ext --inplace
mkdir -p annotations
find src/ include/ -type f -name '*.html' | xargs -i -r mv {} annotations/ && echo "Annotations saved in annotations/"
echo "Successfully compiled $(wc -l src/* include/* | tail -1 | sed -re 's/^\s*([0-9]+)\s+total\s*$/\1/g') lines."
echo ; } 2>&1 | sed 's/^/    /g' &> /dev/stderr


echo $'\e[92mTesting.\e[0m'
python test.py
