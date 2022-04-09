Comparisons
===========
.. toctree::
  :caption: Contents:

Usage
-----
When using a comparison operator (``>``, ``<``, ``==``, ``>=``, ``<=``, ``!=``) with a ``libcalculus.Function`` object, a ``libcalculus.Comparison`` object is returned.
This object is callable, and represents a boolean function - it takes in a value, and returns ``True`` if the condition is satisfied at that point (and ``False`` if not).

>>> (libcalculus.exp > 3)(1)
False
>>> (libcalculus.exp > 3)(2)
True
>>> (libcalculus.exp > libcalculus.cos)(0)
False

This is especially useful for constructing piecewise functions; for example, to create the function :math:`x\mapsto\begin{cases} e^x & ;\,x>3 \\\text{sin}\left(x \right ) & ;\,\text{else} \end{cases}` use:

>>> f = libcalculus.piecewise(libcalculus.identity > 3, libcalculus.exp, libcalculus.sin)
>>> f(3), f(5)
(0.1411200080598672, 148.4131591025766)
>>> f(3j)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "src/Function.pyx", line 36, in libcalculus.Function.__call__
    raise ValueError(f"This function cannot accept input of type {type(x)}.")
ValueError: This function cannot accept input of type <class 'complex'>.

Naturally, complex functions can only accommodate the comparison operators ``==``, ``!=`` - so complex piecewise functions based on them are supported. For example, to create the function :math:`z\mapsto\begin{cases} e^z & ;\,z=3i \\\text{sin}\left(z \right ) & ;\,\text{else} \end{cases}` use:

>>> g = libcalculus.piecewise(libcalculus.identity == 3j, libcalculus.exp, libcalculus.sin)
>>> g(3.1j)
11.07645103952404j
>>> g(3j)
(-0.9899924966004454+0.1411200080598672j)


Operations
----------
Comparisons support basic logical operations; given two ``libcalculus.Comparison`` objects ``p`` and ``q``:

.. list-table::
   :header-rows: 1
   :class: tight-table

   * - Syntax
     - Mathematical Notation
     - Notes

   * - ``~p``
     - :math:`z\mapsto \neg p\left(z\right)`
     - Logical NOT

   * - ``p | q``
     - :math:`z\mapsto p\left(z\right) \vee q\left(z\right)`
     - Logical OR

   * - ``p & q``
     - :math:`z\mapsto p\left(z\right) \wedge q\left(z\right)`
     - Logical AND

The corresponding in-place operations are supported as well.
