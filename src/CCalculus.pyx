# distutils: language = c++
from Definitions cimport *
from CFunction cimport *

cdef extern from "CCalculus.cpp":
  pass

cdef extern from "CCalculus.h" namespace "libcalculus":
  CFunction[Dom, Ran] Derivative[Dom, Ran](CFunction[Dom, Ran] f, const REAL tol, const REAL radius) except +
  Ran Integrate[Dom, Ran, ContDom](CFunction[Dom, Ran] f, CFunction[ContDom, Dom] contour,
                                   const ContDom start, const ContDom end, const REAL tol) except +

def integrate(f, contour, start=None, end=None, const REAL tol=1e-3):
  """Integrate f along a contour."""
  if isinstance(f, ComplexFunction) and isinstance(contour, Contour):
    return Integrate[COMPLEX, COMPLEX, REAL]((<ComplexFunction>f).cfunction, (<Contour>contour).cfunction,
                                             start if start is not None else contour.start, end if end is not None else contour.end, tol)
  elif isinstance(f, Function) and (<Function>f).complexfunction is not None and isinstance(contour, Contour):
      return Integrate[COMPLEX, COMPLEX, REAL]((<Function>f).complexfunction.cfunction, (<Contour>contour).cfunction,
                                               start if start is not None else 0., end if end is not None else 1., tol)
  elif isinstance(f, ComplexFunction) and isinstance(contour, Function) and (<Function>contour).contour is not None:
      return Integrate[COMPLEX, COMPLEX, REAL]((<ComplexFunction>f).cfunction, (<Function>contour).contour.cfunction,
                                               start if start is not None else 0., end if end is not None else 1., tol)
  elif isinstance(f, Function) and (<Function>f).complexfunction is not None and isinstance(contour, Function) and (<Function>f).contour is not None:
      return Integrate[COMPLEX, COMPLEX, REAL]((<Function>f).complexfunction.cfunction, (<Function>contour).contour.cfunction,
                                               start if start is not None else 0., end if end is not None else 1., tol)
  elif isinstance(f, RealFunction) and isinstance(contour, np.ndarray) and np.issubdtype(contour.dtype, np.number) and contour.shape == (2,):
      return Integrate[REAL, REAL, REAL]((<RealFunction>f).cfunction, (<Function>identity).realfunction.cfunction, contour[0], contour[1], tol)
  elif isinstance(f, Function) and (<Function>f).realfunction is not None and isinstance(contour, np.ndarray) and np.issubdtype(contour.dtype, np.number) and contour.shape == (2,):
      return Integrate[REAL, REAL, REAL]((<Function>f).realfunction.cfunction, (<Function>identity).realfunction.cfunction, contour[0], contour[1], tol)
  else:
    raise NotImplementedError

def derivative(f, const size_t order=1, const REAL tol=1e-3, const REAL radius=1.):
  """Returns a function object representing f's derivative."""
  cdef ComplexFunction complex_result
  cdef RealFunction real_result
  cdef Contour contour_result
  if order == 1:
    if isinstance(f, Function):
      return Function(derivative((<Function>f).realfunction, 1, tol, radius) if (<Function>f).realfunction is not None else None,
                      derivative((<Function>f).contour, 1, tol, radius) if (<Function>f).contour is not None else None,
                      derivative((<Function>f).complexfunction, 1, tol, radius) if (<Function>f).complexfunction is not None else None)
    elif isinstance(f, ComplexFunction):
      complex_result = ComplexFunction()
      complex_result.cfunction = Derivative((<ComplexFunction>f).cfunction, tol, radius)
      return complex_result
    elif isinstance(f, RealFunction):
      real_result = RealFunction()
      real_result.cfunction = Derivative((<RealFunction>f).cfunction, tol, radius)
      return real_result
    elif isinstance(f, Contour):
      contour_result = Contour(f.start, f.end)
      contour_result.cfunction = Derivative((<Contour>f).cfunction, tol, radius)
      return contour_result
    else:
      raise NotImplementedError
  else:
    return derivative(derivative(f, order - 1, tol, radius), 1, tol, radius)

def residue(f, z0, const REAL radius=1., const REAL tol=1e-3):
  """Calculate the residue of f around z0, given that f does not have any further singularities inside
  a sphere of the given radius around z0."""
  cdef Contour contour
  if _isrealscalar(z0) or _iscomplexscalar(z0):
    contour = Contour.Sphere(z0, radius)
  elif isinstance(z0, Function): # Just assume it is a constant function
    contour = Contour.Sphere(z0(0.), radius)
  else:
    raise NotImplementedError(f"Point of residue calculation should be a number or a constant function, not {type(z0)}.")
  return integrate(f, contour, contour.start, contour.end, tol) / complex(2j * M_PI)
