# distutils: language = c++
from libcpp.complex cimport complex as complex_t
from libcpp.string cimport string
from PyCFunction cimport *

cdef extern from "CCalculus.cpp":
  pass

cdef extern from "CCalculus.h" namespace "libcalculus":
  complex_t[double] Integrate(CFunction[complex_t[double], complex_t[double]] f, CFunction[double, complex_t[double]] contour,
                              double start, double end, double tol)

def integrate(ComplexFunction f, Contour contour, start = None, end = None, double tol = 1e-3):
  return Integrate(f.cfunction, contour.cfunction, start if start is not None else contour.start, end if end is not None else contour.end, tol)
