#!/usr/bin/env python3
from setuptools import setup
with open("../README.md", "r") as rfd:
    long_description = rfd.read()

setup(
    name="libcalculus",
    version="0.1.6",
    description="Real/Complex analysis library for Python 3.",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://gitlab.com/ariter777/libcalculus",
    author="Ariel Terkeltoub",
    author_email="ariter777@gmail.com",
    packages=[""],
    package_dir={"": "."},
    package_data={"": ["../../../libcalculus.cpython-38-x86_64-linux-gnu.so", "../../../libcalculus.cp37-win_amd64.pyd"]},
    keywords=["analysis", "real", "complex", "integral", "derivative"],
    install_requires=[
        "numpy",
    ],
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
    ]
)
