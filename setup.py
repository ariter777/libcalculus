#!/usr/bin/env python3
from setuptools import setup, Extension
from Cython.Build import cythonize
import sys
sys.path.append("./include")

setup(ext_modules=cythonize(Extension("libcalculus", ["src/libcalculus.pyx"],
                                      extra_compile_args=["-DNPY_NO_DEPRECATED_API", "-std=c++17", "-O3", "-march=native",
                                                          "-msse", "-msse2", "-mavx", "-mavx2", "-mfpmath=sse"]),
                                      language_level=3, nthreads=4, annotate=True))
