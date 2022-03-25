# libcalculus: A comprehensive real and complex analysis library for Python

[![pipeline status](https://gitlab.com/ariter777/libcalculus/badges/master/pipeline.svg)](https://gitlab.com/ariter777/libcalculus/commits/master)

libcalculus is fully written in C++ and Cython for bindings to Python; all numeric calculations take place in C++ and take full advantage of SIMD vectorization and OpenMP threading wherever available.

## Features

- Functional programming approach to analysis in Python
- Numeric integration and differentiation of real and complex functions
- Full integration with NumPy: functions support array inputs
- LaTeX support: every function object has a `.latex()` that produces its LaTeX markup

## Technology
libcalculus is written in C\+\+20 and bound to Python via Cython; operations between functions are performed using C++ lambdas, and all calculations happen at the C++ level, with Python only interfacing methods and results.

## Installation
libcalculus can be installed from pip:
```
pip install libcalculus
```

## Examples
Here is a snippet demonstrating some of the library's features:
```python
>>> import libcalculus, numpy as np
>>> f = libcalculus.identity ** 2 * (libcalculus.sin @ (3 / libcalculus.identity)) # represents z^2 * sin(3/z)
>>> f(1 + 2j)
(1.9161297498044316+7.826928799856612j)
>>> libcalculus.residue(f, 0, tol=1e-4) # residue of f around z=0, with an error tolerance of 1e-4
(-4.499999999971643+1.3805827092608378e-05j)
>>> print(f.latex("t"))
{t}^{2}\sin\left( \frac{3}{t}\right)
>>> contour = libcalculus.exp @ (1j * libcalculus.identity) # represents the contour e^(i*t)
>>> libcalculus.integrate(f, contour, 1, 2) # integrate along the contour between t=1 and t=2
(-0.0607129128779003-8.877187778245547j)
>>> libcalculus.threads(4) # Enable threading
>>> arr = np.array([[1, 2j, 3], [4 + 1j, 5 + 2j, 7 + 3j]])
>>> f(arr)
array([[1.41120008e-01+0.j        , 1.04304611e-15+8.51711782j,
        7.57323886e+00+0.j        ],
       [1.09624856e+01+3.24567376j, 1.42295657e+01+6.29864507j,
        2.04585023e+01+9.22847707j]])
```

## License
Copyright (c) 2022, Ariel Terkeltoub
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above
       copyright notice, this list of conditions and the following
       disclaimer in the documentation and/or other materials provided
       with the distribution.

    * Neither the name of the libcalculus developers nor the names of any
       contributors may be used to endorse or promote products derived
       from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE
