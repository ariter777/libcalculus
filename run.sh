#!/usr/bin/env bash
set -e
python setup.py build_ext --inplace
mkdir -p annotations
find . -maxdepth 1 -type f -name '*.html' -quit | read && mv *.html annotations
echo "Successfully compiled $(wc -l $(git ls-files *.{h,cpp,py,pyx}) | tail -1 | sed -re 's/^\s*([0-9]+)\s+total\s*$/\1/g') lines."
python test.py
