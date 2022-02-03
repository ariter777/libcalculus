# distutils: language = c++
from libcpp.complex cimport complex as complex_t
from libcpp.string cimport string
from PyCFunction cimport *

cdef extern from "CCalculus.cpp":
  pass

cdef extern from "CCalculus.h" namespace "libcalculus":
  complex_t[double] Integrate(CFunction[complex_t[double], complex_t[double]] f, CFunction[double, complex_t[double]] contour,
                              double tol)

def integrate(ComplexFunction f, Contour contour, double tol = 1e-6):
  return Integrate(f.cfunction, contour.cfunction, tol)
