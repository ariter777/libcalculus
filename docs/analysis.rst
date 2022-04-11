.. _analysis:

Analysis Methods
================
.. toctree::
  :caption: Contents:

Differentiation
---------------
.. autofunction:: libcalculus.derivative

Summary
~~~~~~~
This method performs numerical differentiation of real and complex valued functions; it returns a ``libcalculus.Function`` object which can be evaluated at different points.


Examples
~~~~~~~~
>>> f = libcalculus.derivative(libcalculus.sin)
>>> f(0)
0.9998372475304346
>>> g = libcalculus.derivative(libcalculus.sin, tol=1e-6)
>>> g(0)
0.9999998410542882
>>> g.latex()
'\\frac{\\text{d}}{\\text{d}x}\\left(\\sin\\left(x\\right)\\right)'

Note how an error tolerance can be specified for either faster or more accurate calculation. Since the library supports only numerical differentiation (as opposed to symbolic), the LaTeX representation of a derivative is not simplified - i.e., ``libcalculus.derivative(libcalculus.sin).latex()`` returns :math:`\frac{\text{d}}{\text{d}x}\left(\sin\left(x\right)\right)`.

The ``radius`` argument can be used to specify how close to the points of evaluation the derivative should be calculated - this can be useful when dealing with discontinuities that are close together, for example.

You can pass an ``order`` argument to the method to calculate a higher-order derivative; naturally, the higher the order, the lower the tolerance must be to achieve accurate results.

Integration
-----------
.. autofunction:: libcalculus.integrate

Summary
~~~~~~~
This method allows for integration of a real function between two real numbers, or of a complex function along a contour.

Examples
~~~~~~~~
>>> libcalculus.integrate(libcalculus.cosh, [1, 2])
2.4516592142032176
>>> libcalculus.integrate(libcalculus.cosh, libcalculus.line(3j, 1+4j), 0, 1)
(-0.7676181957907201-1.3094950001872043j)
>>> libcalculus.integrate(libcalculus.cosh, libcalculus.line(3j, 1+4j), 0, 1, tol=1e-6)
(-0.7681622192294135-1.3089278504668056j)
>>> libcalculus.integrate(libcalculus.csc @ (2 * libcalculus.identity), libcalculus.sphere(0, 1), tol=1e-4)
(7.71062843771332e-05+3.141592652328148j)

- | In the first example, we compute :math:`\int_1^2 \text{cosh}\left(x\right)\text{d}x`.
- | In the second example, we compute :math:`\int_\gamma \text{cosh}\left(z\right)\text{d}z`, wherein :math:`\gamma:\,\left[0, 1\right]\to\mathbb{C}` represents a line between :math:`3i` and :math:`1 + 4i`. Note that the result isn't quite exactly :math:`\text{sinh}(1 + 4i) - \text{sinh}(3i)`.
- | In the third example, we compute the same line integral, but specify a desired error tolerance of :math:`10^{-6}`; this yields a more accurate result.
- | In the final example, we compute :math:`\oint_{\partial\mathbb{B}_1\left(0\right)}\text{csc}\left(2z\right)\text{d}z`. As expected, the result is approximately :math:`2\pi i \cdot\underset{z=0}{\text{Res}}\left(\text{csc}(2z) \right )=\pi i`.


Residues
--------
.. autofunction:: libcalculus.residue

Summary
~~~~~~~
This method is used for the calculation of residues of complex functions.

Examples
~~~~~~~~
>>> libcalculus.residue(libcalculus.csc @ (2 * libcalculus.identity), 0)
(0.4999999799202389-0.0001227184605667448j)
>>> libcalculus.residue(libcalculus.csc @ (2 * libcalculus.identity), 0, tol=1e-6)
(0.5000000000000554-1.2271846309555398e-07j)

- | In the first example, we compute once again :math:`\underset{z=0}{\text{Res}}\left(\text{csc}(2z) \right )`; this returns approximately :math:`\frac{1}{2}` as expected.
- | In the second example we again achieve better accuracy by specifying a desired error tolerance.


Contour Index
-------------
.. autofunction:: libcalculus.index

Summary
~~~~~~~
This method calculates the index of a point with respect to a contour.

Examples
~~~~~~~~
>>> libcalculus.index(.5j, libcalculus.sphere(0, 1), 0, 1)
1
>>> libcalculus.index(.5j, libcalculus.sphere(0, 1), 0, 2)
2
>>> libcalculus.index(.5j, libcalculus.sphere(0, 1), 0, 2.5)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "src/libcalculus.pyx", line 151, in libcalculus.index
  File "src/Contour.pyx", line 189, in libcalculus.Contour.index
    assert np.allclose(self(start), self(end)), "Index defined only for closed contour."
AssertionError: Index defined only for closed contour.

- | In the first example, we compute :math:`\text{ind}_{\partial\mathbb{B}_1\left(0\right)}\left(\frac{i}{2}\right)`.
- | In the second example we use the same contour, but run :math:`t\in\left[0, 2\right]` - in other words, concatenating the unit circle with itself, producing two revolutions and thus the result :math:`2`.
- | We cannot use a non-closed contour: in the third example we attempt to do so with two and a half revolutions (clockwise) around the unit circle.


Counting Zeros
--------------
.. autofunction:: libcalculus.zeros

Summary
~~~~~~~
This method counts the number of zeros a complex function has inside a closed contour. This is done using the well-known formula:
:math:`\text{N}_f\left(\Omega\right)=\oint_{\partial\Omega}\frac{f'\left(z\right)}{f\left(z\right)}\text{d}z=\text{ind}_{f\circ\partial\Omega}\left(0\right)`

Examples
~~~~~~~~
>>> libcalculus.zeros(libcalculus.sin, libcalculus.sphere(0, 6), 0, 1)
3
>>> libcalculus.zeros(libcalculus.sin, libcalculus.sphere(0, 6), 0, .5)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "src/libcalculus.pyx", line 158, in libcalculus.zeros
  File "src/ComplexFunction.pyx", line 215, in libcalculus.ComplexFunction.zeros
    assert np.allclose(contour(start), contour(end)), "Number of zeros defined only for closed contour."
AssertionError: Number of zeros defined only for closed contour.

- | In the first example, we count the number of zeros the sine function has inside the area enclosed by :math:`\partial\mathbb{B}_6\left(0\right)` - that is, a circle of radius :math:`6` centered at the origin.
  | We pass the function to examine, and the contour function with the start and end points (in this case, :math:`t\mapsto 6e^{2\pi it}` with :math:`t\in\left[0, 1\right]`).
- | We cannot use a non-closed contour: in the second example we attempt to do so with the upper half of :math:`\partial\mathbb{B}_6\left(0\right)`.
