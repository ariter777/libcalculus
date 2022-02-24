# distutils: language = c++
from Definitions cimport *
from PyCFunction cimport *

cdef extern from "CCalculus.cpp":
  pass

cdef extern from "CCalculus.h" namespace "libcalculus":
  size_t factorial(size_t n)
  COMPLEX Integrate(CFunction[COMPLEX, COMPLEX] f, CFunction[REAL, COMPLEX] contour,
                              REAL start, REAL end, REAL tol)

def integrate(ComplexFunction f, Contour contour, start=None, end=None, const REAL tol=1e-3):
  """"Integrate f along a contour."""
  return Integrate(f.cfunction, contour.cfunction, start if start is not None else contour.start, end if end is not None else contour.end, tol)

def derivative(ComplexFunction f, COMPLEX z0, const size_t order=1, const REAL radius=1e-3, const REAL tol=1e-3):
  """Calculate the derivative of f at z0, given that f does not have any singularities inside
  a sphere of the given radius around z0."""
  cdef Contour contour = Contour.Sphere(z0, radius)
  cdef ComplexFunction integrand = f / ((ComplexFunction.Identity() - z0) ** (order + 1))
  return complex(factorial(order) / (2j * M_PI)) * Integrate(integrand.cfunction, contour.cfunction, contour.start, contour.end, tol)

def residue(ComplexFunction f, const COMPLEX z0, const REAL radius=1e-3, const REAL tol=1e-3):
  """Calculate the residue of f around z0, given that f does not have any further singularities inside
  a sphere of the given radius around z0."""
  cdef Contour contour = Contour.Sphere(z0, radius)
  return Integrate(f.cfunction, contour.cfunction, contour.start, contour.end, tol) / complex(2j * M_PI)
