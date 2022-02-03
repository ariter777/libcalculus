#!/usr/bin/env python
from setuptools import setup, Extension
from Cython.Build import cythonize


setup(ext_modules=cythonize(Extension("libcalculus", ["libcalculus.pyx"]), language_level=3))

import shutil
shutil.rmtree("build")
