#!/usr/bin/env bash
set -e
python setup.py build_ext --inplace
mkdir -p annotations
find . -maxdepth 1 -type f -name '*.html' | read && mv *.html annotations && echo "Annotations saved in annotations/"
echo "Successfully compiled $(wc -l src/* include/* | tail -1 | sed -re 's/^\s*([0-9]+)\s+total\s*$/\1/g') lines."
python test.py
