#!/usr/bin/env bash
python setup.py build_ext --inplace && python test.py 2000 20
