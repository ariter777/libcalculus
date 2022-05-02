Miscellaneous
=============
.. toctree::
  :caption: Contents:

Threading
---------
.. autofunction:: libcalculus.threads

Summary
~~~~~~~
Use this method to get or set the number of threads available for the library to use (mainly for array calculations).

In general, if you grant the library more threads, array calculations will keep speeding up; this of course works only up to the number of threads your CPU actually has.
Note that threading isn't necessarily the right way to go, especially for small arrays; feel free to change the number of threads as you perform different operations.


Examples
~~~~~~~~
.. code-block:: bash

  $ python -m timeit -s 'import libcalculus, numpy as np; arr = np.random.rand(1000, 1000); libcalculus.threads(1)' 'libcalculus.csch(arr)'
  20 loops, best of 5: 19.6 msec per loop

  $ python -m timeit -s 'import libcalculus, numpy as np; arr = np.random.rand(1000, 1000); libcalculus.threads(6)' 'libcalculus.csch(arr)'
  20 loops, best of 5: 10 msec per loop
