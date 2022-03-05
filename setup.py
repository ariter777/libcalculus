#!/usr/bin/env python3
from setuptools import setup, Extension
from Cython.Build import cythonize
import sys
import numpy as np
import os
os.environ["CC"] = os.environ.get("CC", "g++-11")
os.environ["CC"] = os.environ.get("CXX", "g++-11")
os.environ["LDSHARED"] = os.environ.get("LDSHARED", "g++-11 -shared")
sys.path.append("./include")

if sys.platform == "linux":
    COMPILER_ARGS = ["-DNPY_NO_DEPRECATED_API", "-std=c++20", "-O3", "-march=native", "-lstdc++",
                     "-msse", "-msse2", "-mavx", "-mavx2", "-mfpmath=sse", "-fopenmp"]
    LIBRARY_DIRS = []
    LINKER_ARGS = ["-fopenmp", "-lstdc++"]
elif sys.platform == "win32":
    COMPILER_ARGS = ["/std:c++20", "/DNPY_NO_DEPRECATED_API", "/O2", "/arch:AVX", "/arch:AVX2"]
    LIBRARY_DIRS = [r"C:\Program Files (x86)\Windows Kits\10\Lib\10.0.18362.0\um\x64"]
    LINKER_ARGS = []

setup(ext_modules=cythonize(Extension("libcalculus", ["src/libcalculus.pyx"],
                                      extra_compile_args=COMPILER_ARGS, extra_link_args=LINKER_ARGS, library_dirs=LIBRARY_DIRS, include_dirs=[np.get_include()]),
                                      language_level=3, nthreads=4, annotate=True))
