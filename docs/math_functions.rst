Mathematical Functions
======================
.. toctree::
  :caption: Contents:

Important Notes
---------------
The entries in the table below are the mathematical functions provided in the library. Each of them is a ready-made instance of a ``libcalculus.Function``, which are callable for evaluation but can also be used with methods such as ``libcalculus.integrate``, ``libcalculus.residue`` etc., as is documented in :ref:`Analysis Methods <analysis>`.

Evaluating such a function is very simple - :math:`\text{sinh}(3)` can be evaluated using ``libcalculus.sinh(3)``. Please note that the variable name in the following table is mostly :math:`z` - this **is not** to imply that those functions can only accept complex inputs; real inputs are accepted as well. Read the :ref:`Caveats <caveats>` section for more information.


Builtin Functions
-----------------
.. list-table::
   :header-rows: 1
   :class: tight-table

   * - Name
     - Mathematical Notation
     - Notes
   * - ``abs``
     - :math:`z\mapsto\left|z\right|`
     - Absolute value

   * - ``arccos``
     - :math:`z\mapsto\text{arccos}\left(z\right)`
     - Inverse cosine

   * - ``arccot``
     - :math:`z\mapsto\text{arccot}\left(z\right)`
     - Inverse cotangent

   * - ``arccsc``
     - :math:`z\mapsto\text{arccsc}\left(z\right)`
     - Inverse cosecant

   * - ``arcosh``
     - :math:`z\mapsto\text{arcosh}\left(z\right)`
     - Inverse hyperbolic cosine

   * - ``arcoth``
     - :math:`z\mapsto\text{arcoth}\left(z\right)`
     - Inverse hyperbolic cotangent

   * - ``arcsch``
     - :math:`z\mapsto\text{arcsch}\left(z\right)`
     - Inverse hyperbolic cosecant

   * - ``arcsec``
     - :math:`z\mapsto\text{arcsec}\left(z\right)`
     - Inverse secant

   * - ``arcsin``
     - :math:`z\mapsto\text{arcsin}\left(z\right)`
     - Inverse sine

   * - ``arctan``
     - :math:`z\mapsto\text{arctan}\left(z\right)`
     - Inverse tangent

   * - ``arg``
     - :math:`z\mapsto\text{arg}\left(z\right)`
     - Complex argument

   * - ``arsech``
     - :math:`z\mapsto\text{arsech}\left(z\right)`
     - Inverse hyperbolic secant

   * - ``arsinh``
     - :math:`z\mapsto\text{arsinh}\left(z\right)`
     - Inverse hyperbolic sine

   * - ``artanh``
     - :math:`z\mapsto\text{artanh}\left(z\right)`
     - Inverse hyperbolic tangent

   * - ``conj``
     - :math:`z\mapsto\bar{z}`
     - Complex conjugate

   * - ``constant(c)``
     - :math:`z\mapsto c`
     - Constant function

   * - ``cos``
     - :math:`z\mapsto\text{cos}\left(z\right)`
     - Cosine

   * - ``cosh``
     - :math:`z\mapsto\text{cosh}\left(z\right)`
     - Hyperbolic cosine

   * - ``cot``
     - :math:`z\mapsto\text{cot}\left(z\right)`
     - Cotangent

   * - ``coth``
     - :math:`z\mapsto\text{coth}\left(z\right)`
     - Hyperbolic cotangent

   * - ``csc``
     - :math:`z\mapsto\text{csc}\left(z\right)`
     - Cosecant

   * - ``csch``
     - :math:`z\mapsto\text{csch}\left(z\right)`
     - Hyperbolic cosecant

   * - ``e``
     - :math:`z\mapsto e`
     - Euler's number

   * - ``exp``
     - :math:`z\mapsto e^z`
     - Exponential function

   * - ``identity``
     - :math:`z\mapsto z`
     - Identity function

   * - ``imag``
     - :math:`z\mapsto\text{Im}\left(z\right)`
     - Imaginary part

   * - ``line(z1, z2)``
     - :math:`t\mapsto\left(1-t\right)z_1+tz_2`
     - Contour representing a line with :math:`t\in\left[0,1\right]`

   * - ``ln``
     - :math:`z\mapsto\text{ln}\left(z\right)`
     - Natural logarithm (principal branch)

   * - ``pi``
     - :math:`z\mapsto \pi`
     - Constant ??

   * - ``piecewise(comp_, then_, else_)``
     - :math:`z\mapsto \begin{cases} \text{then_}\left(z \right ) & ; \;\text{comp_}\left(z \right )=\mathbb{T} \\ \text{else_}\left(z \right ) & ; \;\text{comp_}\left(z \right )=\mathbb{F} \end{cases}`
     - If ``comp_`` returns ``True`` at ``z`` return ``then_(z)``, otherwise return ``else_(z)``.

   * - ``real``
     - :math:`z\mapsto\text{Re}\left(z\right)`
     - Real part

   * - ``sec``
     - :math:`z\mapsto\text{sec}\left(z\right)`
     - Secant

   * - ``sech``
     - :math:`z\mapsto\text{sech}\left(z\right)`
     - Hyperbolic secant

   * - ``sin``
     - :math:`z\mapsto\text{sin}\left(z\right)`
     - Sine

   * - ``sinh``
     - :math:`z\mapsto\text{sinh}\left(z\right)`
     - Hyperbolic sine

   * - ``sphere(center=0, radius=1)``
     - :math:`t\mapsto \text{center}+\text{radius}\cdot e^{2\pi it}`
     - Contour representing a circle with :math:`t\in\left[0,1\right]`

   * - ``tan``
     - :math:`z\mapsto\text{tan}\left(z\right)`
     - Tangent

   * - ``tanh``
     - :math:`z\mapsto\text{tanh}\left(z\right)`
     - Hyperbolic tangent


Operations
----------
Any standard mathematical operation can be applied to a ``libcalculus.Function`` object.
Given two ``libcalculus.Function`` objects ``f`` and ``g``:

.. list-table::
   :header-rows: 1
   :class: tight-table

   * - Syntax
     - Mathematical Notation
     - Notes

   * - ``-f``
     - :math:`z\mapsto -f\left(z\right)`
     - Function additive inverse

   * - ``f + g``
     - :math:`z\mapsto f\left(z\right)+g\left(z\right)`
     - Function addition

   * - ``f - g``
     - :math:`z\mapsto f\left(z\right)-g\left(z\right)`
     - Function subtraction

   * - ``f * g``
     - :math:`z\mapsto f\left(z\right)\cdot g\left(z\right)`
     - Function multiplication

   * - ``f / g``
     - :math:`z\mapsto \frac{f\left(z\right)}{g\left(z\right)}`
     - Function division

   * - ``f ** g``
     - :math:`z\mapsto \left(f\left(z\right)\right)^{g\left(z\right)}`
     - Function exponentiation

   * - ``f @ g``
     - :math:`z\mapsto f\left(g\left(z\right)\right)`
     - Function composition

The corresponding in-place operations are supported; operations with constants are supported where applicable as well:

>>> (2 * libcalculus.sin)(3)
0.2822400161197344
>>> (4 ** libcalculus.sin)(3)
(1.2160815815872013+0j)


Other Remarks
-------------
Try to use library builtins as much as possible - this comes in handy with mathematical constants for example::

  f = libcalculus.pi * libcalculus.sin
  g = np.pi * libcalculus.sin


In this instance, ``f.latex()`` will return ``"\\pi \\sin\\left(x\\right)"`` (corresponding to :math:`\pi \sin\left(x\right)`), while ``g.latex()`` will return ``"3.14159 \\sin\\left(x\\right)"`` (corresponding to :math:`3.14159 \sin\left(x\right)`).

.. _caveats:

Caveats
-------
The library employs a fundamental distinction between "purely complex-valued" functions and ones that might occasionally return a complex value: ``(1j * libcalculus.sin)(3)`` will call an underlying C++ function accepting a real input and returning a complex output; however, ``libcalculus.arcsin(3)`` **will actually return** ``np.nan``. To avoid this, cast to complex - ``libcalculus.arcsin(complex(3))`` will correctly return ``(1.5707963267948966+1.762747174039086j)``.
