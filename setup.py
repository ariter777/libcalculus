#!/usr/bin/env python3
from setuptools import setup, Extension
from Cython.Build import cythonize

setup(ext_modules=cythonize(Extension("libcalculus", ["libcalculus.pyx"], extra_compile_args=["-std=c++17", "-O3", "-march=native"]), language_level=3, nthreads=4, annotate=True))

import shutil
shutil.rmtree("build")
