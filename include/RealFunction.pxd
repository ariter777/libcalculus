# distutils: language = c++
from Definitions cimport *
from CFunction cimport *

cdef class RealFunction:
  cdef CFunction[REAL, REAL] cfunction
