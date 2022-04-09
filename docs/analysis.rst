Analysis Methods
================
.. toctree::
  :caption: Contents:

.. _analysis:

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
This method for the calculation of residues of complex functions.

Examples
~~~~~~~~
>>> libcalculus.residue(libcalculus.csc @ (2 * libcalculus.identity), 0)
(0.4999999799202389-0.0001227184605667448j)
>>> libcalculus.residue(libcalculus.csc @ (2 * libcalculus.identity), 0, tol=1e-6)
(0.5000000000000554-1.2271846309555398e-07j)

- | In the first example, we compute once again :math:`\underset{z=0}{\text{Res}}\left(\text{csc}(2z) \right )`; this returns approximately :math:`\frac{1}{2}` as expected.
- | In the second example we again achieve better accuracy by specifying a desired error tolerance.
