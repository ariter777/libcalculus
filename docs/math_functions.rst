Mathematical Functions
======================
.. toctree::
  :caption: Contents:

Remarks
-------
The entries in the table below are the mathematical functions provided in the library. Each of them is a readymade instance of a :code:`libcalculus.Function`, which are callable for evaluation but can also be used in methods such as :code:`libcalculus.integrate`, :code:`libcalculus.residue` etc., as is documented in :ref:`Analysis Methods <analysis>`.

.. list-table::
   :header-rows: 1

   * - Name
     - Mathematical Notation
     - Notes
   * - :code:`abs`
     - :math:`z\mapsto\left|z\right|`
     - Absolute value

   * - :code:`arccos`
     - :math:`z\mapsto\text{arccos}\left(z\right)`
     - Inverse cosine

   * - :code:`arccot`
     - :math:`z\mapsto\text{arccot}\left(z\right)`
     - Inverse cotangent

   * - :code:`arccsc`
     - :math:`z\mapsto\text{arccsc}\left(z\right)`
     - Inverse cosecant

   * - :code:`arcosh`
     - :math:`z\mapsto\text{arcosh}\left(z\right)`
     - Inverse hyperbolic cosine

   * - :code:`arcoth`
     - :math:`z\mapsto\text{arcoth}\left(z\right)`
     - Inverse hyperbolic cotangent

   * - :code:`arcsch`
     - :math:`z\mapsto\text{arcsch}\left(z\right)`
     - Inverse hyperbolic cosecant

   * - :code:`arcsec`
     - :math:`z\mapsto\text{arcsec}\left(z\right)`
     - Inverse secant

   * - :code:`arcsin`
     - :math:`z\mapsto\text{arcsin}\left(z\right)`
     - Inverse sine

   * - :code:`arctan`
     - :math:`z\mapsto\text{arctan}\left(z\right)`
     - Inverse tangent

   * - :code:`arsech`
     - :math:`z\mapsto\text{arsech}\left(z\right)`
     - Inverse hyperbolic secant

   * - :code:`arsinh`
     - :math:`z\mapsto\text{arsinh}\left(z\right)`
     - Inverse hyperbolic sine

   * - :code:`artanh`
     - :math:`z\mapsto\text{artanh}\left(z\right)`
     - Inverse hyperbolic tangent

   * - :code:`conj`
     - :math:`z\mapsto\bar{z}`
     - Complex conjugate

   * - :code:`constant(c)`
     - :math:`z\mapsto c`
     - Constant function

   * - :code:`cos`
     - :math:`z\mapsto\text{cos}\left(z\right)`
     - Cosine

   * - :code:`cosh`
     - :math:`z\mapsto\text{cosh}\left(z\right)`
     - Hyperbolic cosine

   * - :code:`cot`
     - :math:`z\mapsto\text{cot}\left(z\right)`
     - Cotangent

   * - :code:`coth`
     - :math:`z\mapsto\text{coth}\left(z\right)`
     - Hyperbolic cotangent

   * - :code:`csc`
     - :math:`z\mapsto\text{csc}\left(z\right)`
     - Cosecant

   * - :code:`csch`
     - :math:`z\mapsto\text{csch}\left(z\right)`
     - Hyperbolic cosecant

   * - :code:`e`
     - :math:`z\mapsto e`
     - Euler's number

   * - :code:`exp`
     - :math:`z\mapsto e^z`
     - Exponential function

   * - :code:`identity`
     - :math:`z\mapsto z`
     - Identity function

   * - :code:`imag`
     - :math:`z\mapsto\text{Im}\left(z\right)`
     - Imaginary part

   * - :code:`line(z1, z2)`
     - :math:`t\mapsto\left(1-t\right)z_1+tz_2`
     - Contour representing a line with :math:`t\in\left[0,1\right]`

   * - :code:`pi`
     - :math:`z\mapsto \pi`
     - Constant π

   * - :code:`piecewise(comp_, then_, else_)`
     - :math:`z\mapsto \begin{cases} \text{then_}\left(z \right ) & ; \;\text{comp_}\left(z \right )=\mathbb{T} \\ \text{else_}\left(z \right ) & ; \;\text{comp_}\left(z \right )=\mathbb{F} \end{cases}`
     - Constant π

   * - :code:`real`
     - :math:`z\mapsto\text{Re}\left(z\right)`
     - Real part

   * - :code:`sec`
     - :math:`z\mapsto\text{sec}\left(z\right)`
     - Secant

   * - :code:`sech`
     - :math:`z\mapsto\text{sech}\left(z\right)`
     - Hyperbolic secant

   * - :code:`sin`
     - :math:`z\mapsto\text{sin}\left(z\right)`
     - Sine

   * - :code:`sinh`
     - :math:`z\mapsto\text{sinh}\left(z\right)`
     - Hyperbolic sine

   * - :code:`sphere(center=0, radius=1)`
     - :math:`t\mapsto \text{center}+\text{radius}\cdot e^{2\pi it}`
     - Contour representing a circle with :math:`t\in\left[0,1\right]`

   * - :code:`tan`
     - :math:`z\mapsto\text{tan}\left(z\right)`
     - Tangent

   * - :code:`tanh`
     - :math:`z\mapsto\text{tanh}\left(z\right)`
     - Hyperbolic tangent
