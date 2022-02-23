#!/usr/bin/env bash
set -e
rm -f libcalculus.cpp
python setup.py build_ext --inplace
mkdir -p annotations
mv *.html annotations
echo "Successfully compiled $(wc -l $(git ls-files *.{h,cpp,py,pyx}) | tail -1 | sed -re 's/^\s*([0-9]+)\s+total\s*$/\1/g') lines."
python test.py
