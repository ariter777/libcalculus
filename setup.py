#!/usr/bin/env python3
from setuptools import setup, Extension
from Cython.Build import cythonize
import sys
import numpy as np
sys.path.append("./include")

if sys.platform == "linux":
    import os
    os.environ["CC"] = os.environ.get("CC", "g++")
    os.environ["CC"] = os.environ.get("CXX", "g++")
    os.environ["LDSHARED"] = os.environ.get("LDSHARED", "g++ -shared")
    COMPILER_ARGS = ["-DNPY_NO_DEPRECATED_API", "-std=c++2a", "-O3", "-lstdc++", "-fopenmp", "-static-libstdc++", "-static-libgcc"]
    LIBRARY_DIRS = []
    LINKER_ARGS = ["-fopenmp", "-lstdc++", "-static-libstdc++", "-static-libgcc"]
elif sys.platform == "win32":
    COMPILER_ARGS = ["/std:c++20", "/DNPY_NO_DEPRECATED_API", "/O2", "/MT"]
    LIBRARY_DIRS = [r"C:\Program Files (x86)\Windows Kits\10\Lib\10.0.18362.0\um\x64"]
    LINKER_ARGS = []


with open("README.md", "r") as rfd:
    long_description = rfd.read()

setup(name="libcalculus",
version="0.2.4.3",
description="Real/Complex analysis library for Python 3.",
long_description=long_description,
long_description_content_type="text/markdown",
url="https://pypi.org/project/libcalculus",
author="Ariel Terkeltoub",
author_email="ariter777@gmail.com",
keywords=["analysis", "real", "complex", "integral", "derivative"],
install_requires=[
    "numpy>=1.21",
],
classifiers=[
    "Development Status :: 4 - Beta",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: BSD License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.7",
    "Programming Language :: Python :: 3.8",
],
license_files=["LICENSE.txt"],
project_urls = {"Documentation": "https://libcalculus.readthedocs.io/en/latest/",
                "Source Code": "https://gitlab.com/ariter777/libcalculus"},
ext_modules=cythonize(Extension("libcalculus", ["src/libcalculus.pyx"],
                                      extra_compile_args=COMPILER_ARGS, extra_link_args=LINKER_ARGS, library_dirs=LIBRARY_DIRS, include_dirs=[np.get_include()]),
                                      language_level=3, nthreads=4, annotate=True, compiler_directives={"embedsignature": True}))
