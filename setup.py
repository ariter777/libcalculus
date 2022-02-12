#!/usr/bin/env python3
from setuptools import setup, Extension
from Cython.Build import cythonize


setup(ext_modules=cythonize(Extension("libcalculus", ["libcalculus.pyx"], extra_compile_args=["-O3", "-march=native"]), language_level=3, nthreads=4))

import shutil
shutil.rmtree("build")
