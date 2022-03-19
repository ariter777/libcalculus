# distutils: language = c++
from Definitions cimport *
import os
cimport openmp

cdef class _Globals:
  cdef size_t NUM_THREADS

  def __cinit__(_Globals self):
    self.NUM_THREADS = int(os.environ.get("OMP_NUM_THREADS", 1))

cdef _Globals Globals = _Globals()

def threads(const size_t n=0):
  """Get or set the number of threads available for the library to use."""
  if n == 0:
    return Globals.NUM_THREADS
  else:
    Globals.NUM_THREADS = n
    openmp.omp_set_num_threads(n)
    return n

include "CCalculus.pyx"

include "RealComparison.pyx"
include "ComplexComparison.pyx"

include "ComplexFunction.pyx"
include "Contour.pyx"
include "RealFunction.pyx"
