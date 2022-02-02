#!/usr/bin/env python
from setuptools import setup
from Cython.Build import cythonize

setup(ext_modules=cythonize("libcalculus.pyx", language_level=3))

import shutil
shutil.rmtree("build")
