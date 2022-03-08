# libcalculus: A comprehensive real and complex analysis library for Python

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
>>> z = libcalculus.ComplexFunction.Identity() # Shorten syntax
>>> f = z ** 2 * (libcalculus.ComplexFunction.Sin() @ (3 / z)) # represents z^2 + sin(3/z)
>>> f(1 + 2j)
(1.9161297498044316+7.826928799856612j)
>>> libcalculus.residue(f, 0, tol=1e-4) # residue of f around z=0, with an error tolerance of 1e-4
(-4.499999999971643+1.3805827092608378e-05j)
>>> print(f.latex())
{z}^{2}\sin\left( \frac{3}{z}\right)
>>> contour = libcalculus.Contour.Cosh() + libcalculus.ComplexFunction.Exp() @ (1j * libcalculus.Contour.Identity()) # represents the contour cosh(t) + e^(i*t)
>>> libcalculus.integrate(f, contour, 1, 2) # integrate along the contour between t=1 and t=2
(8.225229199586169+4.308468258475392j)
>>> libcalculus.threads(4) # Enable threading when working with arrays
>>> arr = np.array([[1, 2j, 3], [4 + 1j, 5 + 2j, 7 + 3j]])
>>> f(arr)
array([[1.41120008e-01+0.j        , 1.04304611e-15+8.51711782j,
        7.57323886e+00+0.j        ],
       [1.09624856e+01+3.24567376j, 1.42295657e+01+6.29864507j,
        2.04585023e+01+9.22847707j]])
```

## License
Copyright 2022 Ariel Terkeltoub

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
