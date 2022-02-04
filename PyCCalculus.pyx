# distutils: language = c++
from libcpp.complex cimport complex as complex_t
from libcpp.string cimport string
from PyCFunction cimport *

cdef extern from "CCalculus.cpp":
  pass

cdef extern from "CCalculus.h" namespace "libcalculus":
  complex_t[double] Integrate(CFunction[complex_t[double], complex_t[double]] f, CFunction[double, complex_t[double]] contour,
                              double start, double end, double tol)

def integrate(ComplexFunction f, Contour contour, start=None, end=None, double tol=1e-3):
  """"Integrate f along a contour."""
  return Integrate(f.cfunction, contour.cfunction, start if start is not None else contour.start, end if end is not None else contour.end, tol)

def residue(ComplexFunction f, complex_t[double] z0, double radius=1e-3, tol=None):
  """Calculate the residue of f around z0, given that f does not have any further singularities inside
  a sphere of the given radius around z0."""
  cdef Contour contour = Contour.Sphere(z0, radius)
  return Integrate(f.cfunction, contour.cfunction, contour.start, contour.end, tol if tol is not None else radius * 1e-2) / complex(2j * M_PI)
