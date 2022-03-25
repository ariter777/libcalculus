# distutils: language = c++
from Definitions cimport *
from CFunction cimport *
import numpy as np

cdef class CFunctionInterface:
  """A class that represents a generic function (complex, real, etc.), deducing types only when used."""
  cdef RealFunction realfunction
  cdef Contour contour
  cdef ComplexFunction complexfunction

  def __cinit__(CFunctionInterface self, RealFunction realfunction=None, Contour contour=None, ComplexFunction complexfunction=None):
    self.realfunction = realfunction
    self.contour = contour
    self.complexfunction = complexfunction

  def __call__(CFunctionInterface self, x):
    """Evaluate the function at a point or on an np.ndarray of points."""
    if _isrealscalar(x):
      return self.realfunction.cfunction(<REAL>x) if self.realfunction is not None else self.contour.cfunction(<REAL>x)
    elif _isrealarray(x):
      return self.complexfunction._call_array(x.ravel().astype(np.double, copy=False)).reshape(x.shape)
    elif _iscomplexscalar(x):
      return self.complexfunction.cfunction(<COMPLEX>x)
    elif _iscomplexarray(x):
      return self.complexfunction._call_array(x.ravel().astype(complex, copy=False)).reshape(x.shape)
    else:
      raise NotImplementedError(f"Input of type {type(x)} not supported.")

  def latex(CFunctionInterface self, str varname="x"):
    """Generate LaTeX markup for the function."""
    return self.complexfunction.cfunction.latex(varname.encode()).decode()

  def __neg__(CFunctionInterface self):
    """The additive inverse of the function."""
    return CFunctionInterface(-self.realfunction if self.realfunction is not None else None,
                              -self.contour if self.contour is not None else None,
                              -self.complexfunction if self.complexfunction is not None else None)

  def  __iadd__(CFunctionInterface self, rhs):
    """Add the function in-place with a constant or another function."""
    if isinstance(rhs, CFunctionInterface):
      if self.realfunction is not None and (<CFunctionInterface>rhs).realfunction is not None: self.realfunction += (<CFunctionInterface>rhs).realfunction
      if self.contour is not None and (<CFunctionInterface>rhs).contour is not None: self.contour += (<CFunctionInterface>rhs).contour
      if self.complexfunction is not None and (<CFunctionInterface>rhs).complexfunction is not None: self.complexfunction += (<CFunctionInterface>rhs).complexfunction
