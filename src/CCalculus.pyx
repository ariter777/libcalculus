# distutils: language = c++
from Definitions cimport *
from CFunction cimport *

cdef extern from "CCalculus.cpp":
  pass

cdef extern from "CCalculus.h" namespace "libcalculus":
  size_t factorial(const size_t n)
  Ran Integrate[Dom, Ran, ContDom](CFunction[Dom, Ran] f, CFunction[ContDom, Dom] contour,
                                   const ContDom start, const ContDom end, const REAL tol)

def integrate(f, contour, start=None, end=None, const REAL tol=1e-3):
  """"Integrate f along a contour."""
  if isinstance(f, ComplexFunction) and isinstance(contour, Contour):
    return Integrate[COMPLEX, COMPLEX, REAL]((<ComplexFunction>f).cfunction, (<Contour>contour).cfunction,
                                             start if start is not None else contour.start, end if end is not None else contour.end, tol)
  elif isinstance(f, RealFunction) and isinstance(contour, np.ndarray) and np.issubdtype(contour.dtype, np.number) and contour.shape == (2,):
      return Integrate[REAL, REAL, REAL]((<RealFunction>f).cfunction, (<RealFunction>RealFunction.Identity()).cfunction, contour[0], contour[1], tol)

def derivative(ComplexFunction f, COMPLEX z0, const size_t order=1, const REAL radius=1e-3, const REAL tol=1e-3):
  """Calculate the derivative of f at z0, given that f does not have any singularities inside
  a sphere of the given radius around z0."""
  cdef Contour contour = Contour.Sphere(z0, radius)
  cdef ComplexFunction integrand = f / ((ComplexFunction.Identity() - z0) ** (order + 1))
  return complex(factorial(order) / (2j * M_PI)) * Integrate[COMPLEX, COMPLEX, REAL](integrand.cfunction, contour.cfunction, contour.start, contour.end, tol)

def residue(ComplexFunction f, const COMPLEX z0, const REAL radius=1e-3, const REAL tol=1e-3):
  """Calculate the residue of f around z0, given that f does not have any further singularities inside
  a sphere of the given radius around z0."""
  cdef Contour contour = Contour.Sphere(z0, radius)
  return Integrate[COMPLEX, COMPLEX, REAL](f.cfunction, contour.cfunction, contour.start, contour.end, tol) / complex(2j * M_PI)
