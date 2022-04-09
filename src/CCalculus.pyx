# distutils: language = c++
from Definitions cimport *
from CFunction cimport *

cdef extern from "CCalculus.cpp":
  pass

cdef extern from "CCalculus.h" namespace "libcalculus":
  CFunction[Dom, Ran] Derivative[Dom, Ran](CFunction[Dom, Ran] f, const REAL tol, const REAL radius) except +
  Ran Integrate[Dom, Ran, ContDom](CFunction[Dom, Ran] f, CFunction[ContDom, Dom] contour,
                                   const ContDom start, const ContDom end, const REAL tol) except +

def integrate(f, contour, const REAL start=0., const REAL end=1., const REAL tol=1e-3):
  """Integrate f between two real numbers or along a contour."""
  if isinstance(f, ComplexFunction) and isinstance(contour, Contour) and start is not None and end is not None:
    return Integrate[COMPLEX, COMPLEX, REAL]((<ComplexFunction>f).cfunction, (<Contour>contour).cfunction,
                                             start, end, tol)
  elif isinstance(f, Function) and (<Function>f).complexfunction is not None and isinstance(contour, Contour) and start is not None and end is not None:
      return Integrate[COMPLEX, COMPLEX, REAL]((<Function>f).complexfunction.cfunction, (<Contour>contour).cfunction,
                                               start, end, tol)
  elif isinstance(f, ComplexFunction) and isinstance(contour, Function) and (<Function>contour).contour is not None and start is not None and end is not None:
      return Integrate[COMPLEX, COMPLEX, REAL]((<ComplexFunction>f).cfunction, (<Function>contour).contour.cfunction,
                                               start, end, tol)
  elif isinstance(f, Function) and (<Function>f).complexfunction is not None and isinstance(contour, Function) and (<Function>f).contour is not None \
     and start is not None and end is not None:
      return Integrate[COMPLEX, COMPLEX, REAL]((<Function>f).complexfunction.cfunction, (<Function>contour).contour.cfunction,
                                               start, end, tol)
  elif isinstance(f, RealFunction) and isinstance(contour, np.ndarray) and np.issubdtype(contour.dtype, np.number) and contour.shape == (2,):
      return Integrate[REAL, REAL, REAL]((<RealFunction>f).cfunction, (<RealFunction>RealFunction.Identity()).cfunction, contour[0], contour[1], tol)
  elif isinstance(f, RealFunction) and hasattr(contour, "__iter__") and len(contour) == 2 and np.issubdtype(type(contour[0]), np.number) and np.issubdtype(type(contour[1]), np.number):
    return Integrate[REAL, REAL, REAL]((<RealFunction>f).cfunction, (<RealFunction>RealFunction.Identity()).cfunction, contour[0], contour[1], tol)
  elif isinstance(f, Function) and hasattr(contour, "__iter__") and len(contour) == 2 and np.issubdtype(type(contour[0]), np.number) and np.issubdtype(type(contour[1]), np.number):
      return Integrate[REAL, REAL, REAL]((<Function>f).realfunction.cfunction, (<RealFunction>RealFunction.Identity()).cfunction, contour[0], contour[1], tol)
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
      contour_result = Contour()
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
  return integrate(f, contour, 0., 1., tol) / complex(2j * M_PI)



def index(const COMPLEX z0, Function contour not None, const REAL start=0., const REAL end=1.):
  if contour.contour is None:
    raise ValueError("The contour passed is malformed.")
  return contour.contour.index(z0, start, end)

def zeros(Function f not None, Function contour not None, const REAL start=0., const REAL end=1.):
  """Calculates the number of zeros the functions has inside a closed contour, assuming it is holomorphic."""
  if f.complexfunction is None or contour.contour is None:
    raise ValueError("The function or contour passed are malformed.")
  else:
    return f.complexfunction.zeros(contour.contour, start, end)
