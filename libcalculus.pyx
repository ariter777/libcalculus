# distutils: language = c++
from libcpp.complex cimport complex

cdef extern from "CFunction.cpp":
  pass

cdef extern from "CFunction.h" namespace "libcalculus":
  cdef cppclass CFunction:
    CFunction() except +
    complex[double] operator()(complex[double] z) except +

cdef class Function:
  cdef CFunction cfunction

  def __cinit__(self):
    pass

  def __call__(self, complex[double] z):
    return self.cfunction(z)
