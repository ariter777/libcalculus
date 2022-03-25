# distutils: language = c++
from Definitions cimport *
import numpy as np

cdef class Function:
  """A class that represents a generic function (complex, real, etc.), deducing types only when used."""
  cdef RealFunction realfunction
  cdef Contour contour
  cdef ComplexFunction complexfunction

  def __cinit__(Function self, RealFunction realfunction=None, Contour contour=None, ComplexFunction complexfunction=None):
    self.realfunction = realfunction.copy() if realfunction is not None else None
    self.contour = contour.copy() if contour is not None else None
    self.complexfunction = complexfunction.copy() if complexfunction is not None else None

  def __call__(Function self, x):
    """Evaluate the function at a point or on an np.ndarray of points."""
    if _isrealscalar(x):
      return self.realfunction.cfunction(<REAL>x) if self.realfunction is not None else \
             self.contour.cfunction(<REAL>x) if self.contour is not None else \
             self.complexfunction.cfunction(<COMPLEX>x)
    elif _isrealarray(x):
      return self.realfunction._call_array(x.ravel().astype(np.double, copy=False)) if self.realfunction is not None else \
             self.contour._call_array(x.ravel().astype(np.double, copy=False)) if self.contour is not None else \
             self.complexfunction._call_array(x.ravel().astype(complex, copy=False))
    elif _iscomplexscalar(x):
      return self.complexfunction.cfunction(<COMPLEX>x)
    elif _iscomplexarray(x):
      return self.complexfunction._call_array(x.ravel().astype(complex, copy=False)).reshape(x.shape)
    else:
      raise NotImplementedError(f"Input of type {type(x)} not supported.")

  def latex(Function self, str varname="x"):
    """Generate LaTeX markup for the function."""
    return self.complexfunction.cfunction.latex(varname.encode()).decode()

  def __neg__(Function self):
    """The additive inverse of the function."""
    return Function(-self.realfunction if self.realfunction is not None else None,
                    -self.contour if self.contour is not None else None,
                    -self.complexfunction if self.complexfunction is not None else None)

  def  __iadd__(Function self, rhs):
    """Add the function in-place with a constant or another function."""
    if isinstance(rhs, Function):
      if self.realfunction is not None and (<Function>rhs).realfunction is not None: self.realfunction += (<Function>rhs).realfunction
      if self.contour is not None and (<Function>rhs).contour is not None: self.contour += (<Function>rhs).contour
      if self.complexfunction is not None and (<Function>rhs).complexfunction is not None: self.complexfunction += (<Function>rhs).complexfunction
    elif _isrealscalar(rhs):
      if self.realfunction is not None: self.realfunction += <REAL>rhs
      if self.contour is not None: self.contour += <COMPLEX>rhs
      if self.complexfunction is not None: self.complexfunction += <COMPLEX>rhs
    elif _iscomplexscalar(rhs):
      self.realfunction = None
      if self.contour is not None: self.contour += <COMPLEX>rhs
      if self.complexfunction is not None: self.complexfunction += <COMPLEX>rhs
    else:
      raise NotImplementedError(f"Operands of type {type(self), type(rhs)} not supported")
    return self

  def  __isub__(Function self, rhs):
    """Subtract a constant or another function from the function, in-place."""
    if isinstance(rhs, Function):
      if self.realfunction is not None and (<Function>rhs).realfunction is not None: self.realfunction -= (<Function>rhs).realfunction
      if self.contour is not None and (<Function>rhs).contour is not None: self.contour -= (<Function>rhs).contour
      if self.complexfunction is not None and (<Function>rhs).complexfunction is not None: self.complexfunction -= (<Function>rhs).complexfunction
    elif _isrealscalar(rhs):
      if self.realfunction is not None: self.realfunction -= <REAL>rhs
      if self.contour is not None: self.contour -= <COMPLEX>rhs
      if self.complexfunction is not None: self.complexfunction -= <COMPLEX>rhs
    elif _iscomplexscalar(rhs):
      self.realfunction = None
      if self.contour is not None: self.contour -= <COMPLEX>rhs
      if self.complexfunction is not None: self.complexfunction -= <COMPLEX>rhs
    else:
      raise NotImplementedError(f"Operands of type {type(self), type(rhs)} not supported")
    return self

  def  __imul__(Function self, rhs):
    """Multiply the function in-place with a constant or another function."""
    if isinstance(rhs, Function):
      if self.realfunction is not None and (<Function>rhs).realfunction is not None: self.realfunction *= (<Function>rhs).realfunction
      if self.contour is not None and (<Function>rhs).contour is not None: self.contour *= (<Function>rhs).contour
      if self.complexfunction is not None and (<Function>rhs).complexfunction is not None: self.complexfunction *= (<Function>rhs).complexfunction
    elif _isrealscalar(rhs):
      if self.realfunction is not None: self.realfunction *= <REAL>rhs
      if self.contour is not None: self.contour *= <COMPLEX>rhs
      if self.complexfunction is not None: self.complexfunction *= <COMPLEX>rhs
    elif _iscomplexscalar(rhs):
      self.realfunction = None
      if self.contour is not None: self.contour *= <COMPLEX>rhs
      if self.complexfunction is not None: self.complexfunction *= <COMPLEX>rhs
    else:
      raise NotImplementedError(f"Operands of type {type(self), type(rhs)} not supported")
    return self

  def  __itruediv__(Function self, rhs):
    """Divide the function in-place by a constant or another function."""
    if isinstance(rhs, Function):
      if self.realfunction is not None and (<Function>rhs).realfunction is not None: self.realfunction /= (<Function>rhs).realfunction
      if self.contour is not None and (<Function>rhs).contour is not None: self.contour /= (<Function>rhs).contour
      if self.complexfunction is not None and (<Function>rhs).complexfunction is not None: self.complexfunction /= (<Function>rhs).complexfunction
    elif _isrealscalar(rhs):
      if self.realfunction is not None: self.realfunction /= <REAL>rhs
      if self.contour is not None: self.contour /= <COMPLEX>rhs
      if self.complexfunction is not None: self.complexfunction /= <COMPLEX>rhs
    elif _iscomplexscalar(rhs):
      self.realfunction = None
      if self.contour is not None: self.contour /= <COMPLEX>rhs
      if self.complexfunction is not None: self.complexfunction /= <COMPLEX>rhs
    else:
      raise NotImplementedError(f"Operands of type {type(self), type(rhs)} not supported")
    return self

  def  __ipow__(Function self, rhs):
    """Raise the function in-place to the power of a constant or another function."""
    if isinstance(rhs, Function):
      self.realfunction = None # negative or fractional powers cause NaNs in RealFunction
      if self.contour is not None and (<Function>rhs).contour is not None: self.contour **= (<Function>rhs).contour
      if self.complexfunction is not None and (<Function>rhs).complexfunction is not None: self.complexfunction **= (<Function>rhs).complexfunction
    elif _isrealscalar(rhs):
      if self.realfunction is not None and rhs >= 0 and float(rhs).is_integer(): # negative or fractional powers cause NaNs in RealFunction
        self.realfunction **= <REAL>rhs
      else:
        self.realfunction = None
      if self.contour is not None: self.contour **= <COMPLEX>rhs
      if self.complexfunction is not None: self.complexfunction **= <COMPLEX>rhs
    elif _iscomplexscalar(rhs):
      self.realfunction = None
      if self.contour is not None: self.contour **= <COMPLEX>rhs
      if self.complexfunction is not None: self.complexfunction **= <COMPLEX>rhs
    else:
      raise NotImplementedError(f"Operands of type {type(self), type(rhs)} not supported")
    return self

  def __add__(lhs, rhs):
    """Add the function with a constant or another function."""
    cdef Function result
    if isinstance(lhs, Function):
      result = Function((<Function>lhs).realfunction, (<Function>lhs).contour, (<Function>lhs).complexfunction)
      result += rhs
    elif isinstance(rhs, Function):
      result = Function((<Function>rhs).realfunction, (<Function>rhs).contour, (<Function>rhs).complexfunction)
      result += lhs
    return result

  def __sub__(lhs, rhs):
    """Subtract a constant or another function from the function."""
    cdef Function result
    if isinstance(lhs, Function):
      result = Function((<Function>lhs).realfunction, (<Function>lhs).contour, (<Function>lhs).complexfunction)
      result -= rhs
    elif isinstance(rhs, Function):
      result = Function((<Function>rhs).realfunction, (<Function>rhs).contour, (<Function>rhs).complexfunction)
      result -= lhs
    return result

  def __mul__(lhs, rhs):
    """Multiply the function with a constant or another function."""
    cdef Function result
    if isinstance(lhs, Function):
      result = Function((<Function>lhs).realfunction, (<Function>lhs).contour, (<Function>lhs).complexfunction)
      result *= rhs
    elif isinstance(rhs, Function):
      result = Function((<Function>rhs).realfunction, (<Function>rhs).contour, (<Function>rhs).complexfunction)
      result *= lhs
    return result

  def __truediv__(lhs, rhs):
    """Divide the function by a constant or another function."""
    cdef Function result
    if isinstance(lhs, Function):
      result = Function((<Function>lhs).realfunction, (<Function>lhs).contour, (<Function>lhs).complexfunction)
      result /= rhs
    elif isinstance(rhs, Function):
      result = Function((<Function>rhs).realfunction, (<Function>rhs).contour, (<Function>rhs).complexfunction)
      result /= lhs
    return result


  def __pow__(lhs, rhs, mod):
    """Raise the function to the power of a constant or another function."""
    cdef Function result
    if isinstance(lhs, Function):
      result = Function((<Function>lhs).realfunction, (<Function>lhs).contour, (<Function>lhs).complexfunction)
      result **= rhs
    elif isinstance(rhs, Function):
      result = Function((<Function>rhs).realfunction, (<Function>rhs).contour, (<Function>rhs).complexfunction)
      result **= lhs
    return result

  def __matmul__(Function lhs not None, Function rhs not None):
    """Compose the function with another function."""
    cdef RealFunction realfunction = lhs.realfunction @ rhs.realfunction if lhs.realfunction is not None and rhs.realfunction is not None else None
    cdef Contour contour = lhs.complexfunction @ rhs.contour if lhs.complexfunction is not None and rhs.contour is not None else None
    cdef ComplexFunction complexfunction = lhs.complexfunction @ rhs.complexfunction if lhs.complexfunction is not None and rhs.complexfunction is not None else None
    return Function(realfunction, contour, complexfunction)

  def __gt__(lhs, rhs):
    """Return a Comparison that evaluates to True wherever the function is greater than another function or a constant."""
    cdef RealComparison realcomparison
    if isinstance(lhs, Function) and isinstance(rhs, Function):
      realcomparison = ((<Function>lhs).realfunction > (<Function>rhs).realfunction).copy() if lhs.realfunction is not None and rhs.realfunction is not None else None
    elif isinstance(lhs, Function) and _isrealscalar(rhs):
      realcomparison = ((<Function>lhs).realfunction > <REAL>rhs).copy() if lhs.realfunction is not None else None
    elif _isrealscalar(lhs) and isinstance(rhs, Function):
      realcomparison = (<REAL>lhs > (<Function>rhs).realfunction).copy()
    else:
      raise NotImplementedError(f"Operand types {type(lhs), type(rhs)} not supported.")
    return Comparison(realcomparison, None)

  def __lt__(lhs, rhs):
    """Return a Comparison that evaluates to True wherever the function is smallar than another function or a constant."""
    cdef RealComparison realcomparison
    if isinstance(lhs, Function) and isinstance(rhs, Function):
      realcomparison = ((<Function>lhs).realfunction < (<Function>rhs).realfunction).copy() if lhs.realfunction is not None and rhs.realfunction is not None else None
    elif isinstance(lhs, Function) and _isrealscalar(rhs):
      realcomparison = ((<Function>lhs).realfunction < <REAL>rhs).copy() if lhs.realfunction is not None else None
    elif _isrealscalar(lhs) and isinstance(rhs, Function):
      realcomparison = (<REAL>lhs < (<Function>rhs).realfunction).copy() if rhs.realfunction is not None else None
    else:
      raise NotImplementedError(f"Operand types {type(lhs), type(rhs)} not supported.")
    return Comparison(realcomparison, None)

  def __eq__(lhs, rhs):
    """Return a Comparison that evaluates to True wherever the function equals another function or a constant."""
    cdef RealComparison realcomparison
    cdef ComplexComparison complexcomparison
    if isinstance(lhs, Function) and isinstance(rhs, Function):
      realcomparison = ((<Function>lhs).realfunction == (<Function>rhs).realfunction).copy() if lhs.realfunction is not None and rhs.realfunction is not None else None
      complexcomparison = ((<Function>lhs).complexfunction == (<Function>rhs).complexfunction).copy() if lhs.complexfunction is not None and rhs.complexfunction is not None else None
    elif isinstance(lhs, Function) and _isrealscalar(rhs):
      realcomparison = ((<Function>lhs).realfunction == <REAL>rhs).copy() if lhs.realfunction is not None else None
      complexcomparison = ((<Function>lhs).complexfunction == <COMPLEX>rhs).copy() if lhs.complexfunction is not None else None
    elif isinstance(lhs, Function) and _iscomplexscalar(rhs):
      realcomparison = None
      complexcomparison = ((<Function>lhs).complexfunction == <COMPLEX>rhs).copy() if lhs.complexfunction is not None else None
    elif _isrealscalar(lhs) and isinstance(rhs, Function):
      realcomparison = (<REAL>lhs == (<Function>rhs).realfunction).copy() if rhs.realfunction is not None else None
      complexcomparison = (<COMPLEX>lhs == (<Function>rhs).complxfunction).copy() if rhs.complexfunction is not None else None
    elif  _iscomplexscalar(lhs) and isinstance(rhs, Function):
      realcomparison = None
      complexcomparison = (<COMPLEX>lhs == (<Function>rhs).complexfunction).copy() if rhs.complexfunction is not None else None
    else:
      raise NotImplementedError(f"Operand types {type(lhs), type(rhs)} not supported.")
    return Comparison(realcomparison, complexcomparison)

  def __ge__(lhs, rhs):
    """Return a Comparison that evaluates to True wherever the function is greater than or equal to another function or a constant."""
    cdef RealComparison realcomparison
    if isinstance(lhs, Function) and isinstance(rhs, Function):
      realcomparison = ((<Function>lhs).realfunction >= (<Function>rhs).realfunction).copy() if lhs.realfunction is not None and rhs.realfunction is not None else None
    elif isinstance(lhs, Function) and _isrealscalar(rhs):
      realcomparison = ((<Function>lhs).realfunction >= <REAL>rhs).copy() if lhs.realfunction is not None else None
    elif _isrealscalar(lhs) and isinstance(rhs, Function):
      realcomparison = (<REAL>lhs >= (<Function>rhs).realfunction).copy()
    else:
      raise NotImplementedError(f"Operand types {type(lhs), type(rhs)} not supported.")
    return Comparison(realcomparison, None)

  def __le__(lhs, rhs):
    """Return a Comparison that evaluates to True wherever the function is smallar than or equal to another function or a constant."""
    cdef RealComparison realcomparison
    if isinstance(lhs, Function) and isinstance(rhs, Function):
      realcomparison = ((<Function>lhs).realfunction <= (<Function>rhs).realfunction).copy() if lhs.realfunction is not None and rhs.realfunction is not None else None
    elif isinstance(lhs, Function) and _isrealscalar(rhs):
      realcomparison = ((<Function>lhs).realfunction <= <REAL>rhs).copy() if lhs.realfunction is not None else None
    elif _isrealscalar(lhs) and isinstance(rhs, Function):
      realcomparison = (<REAL>lhs <= (<Function>rhs).realfunction).copy() if rhs.realfunction is not None else None
    else:
      raise NotImplementedError(f"Operand types {type(lhs), type(rhs)} not supported.")
    return Comparison(realcomparison, None)

  def __ne__(lhs, rhs):
    """Return a Comparison that evaluates to True wherever the function does not equal another function or a constant."""
    cdef RealComparison realcomparison
    cdef ComplexComparison complexcomparison
    if isinstance(lhs, Function) and isinstance(rhs, Function):
      realcomparison = ((<Function>lhs).realfunction != (<Function>rhs).realfunction).copy() if lhs.realfunction is not None and rhs.realfunction is not None else None
      complexcomparison = ((<Function>lhs).complexfunction != (<Function>rhs).complexfunction).copy() if lhs.complexfunction is not None and rhs.complexfunction is not None else None
    elif isinstance(lhs, Function) and _isrealscalar(rhs):
      realcomparison = ((<Function>lhs).realfunction != <REAL>rhs).copy() if lhs.realfunction is not None else None
      complexcomparison = ((<Function>lhs).complexfunction != <COMPLEX>rhs).copy() if lhs.complexfunction is not None else None
    elif isinstance(lhs, Function) and _iscomplexscalar(rhs):
      realcomparison = None
      complexcomparison = ((<Function>lhs).complexfunction != <COMPLEX>rhs).copy() if lhs.complexfunction is not None else None
    elif _isrealscalar(lhs) and isinstance(rhs, Function):
      realcomparison = (<REAL>lhs != (<Function>rhs).realfunction).copy() if rhs.realfunction is not None else None
      complexcomparison = (<COMPLEX>lhs != (<Function>rhs).complxfunction).copy() if rhs.complexfunction is not None else None
    elif  _iscomplexscalar(lhs) and isinstance(rhs, Function):
      realcomparison = None
      complexcomparison = (<COMPLEX>lhs != (<Function>rhs).complexfunction).copy() if rhs.complexfunction is not None else None
    else:
      raise NotImplementedError(f"Operand types {type(lhs), type(rhs)} not supported.")
    return Comparison(realcomparison, complexcomparison)
