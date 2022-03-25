# distutils: language = c++
from cython.parallel import prange

cdef class RealFunction:
  cdef CFunction[REAL, REAL] cfunction

  @cython.nonecheck(False)
  @cython.boundscheck(False)
  @cython.wraparound(False)
  cdef np.ndarray[REAL] _call_array(RealFunction self, np.ndarray[const REAL] t):
    """Evaluate the function on an np.ndarray."""
    cdef REAL[::1] result = np.empty(t.size, dtype=np.double)
    cdef size_t i, n = t.size
    if Globals.NUM_THREADS > 1:
      # Use threading instead of SIMD.
      for i in prange(n, nogil=True, num_threads=Globals.NUM_THREADS):
        result[i] = self.cfunction(t[i])
    else:
      # Use SIMD
      self.cfunction._call_array(&t[0], &result[0], n)
    return np.asarray(result)

  def copy(RealFunction self):
    """Create a copy of the object."""
    cdef RealFunction result = RealFunction()
    result.cfunction = CFunction[REAL, REAL](self.cfunction)
    return result

  def __call__(RealFunction self, t):
    """Evaluate the function at a point or on an np.ndarray of points."""
    if isinstance(t, (int, float, complex)):
      return self.cfunction(t)
    elif isinstance(t, np.ndarray) and t.dtype == np.double:
      return self._call_array(t.ravel()).reshape(t.shape)
    elif isinstance(t, np.ndarray) and np.issubdtype(t.dtype, np.number):
      return self._call_array(t.ravel().astype(np.double, copy=False)).reshape(t.shape)
    else:
      raise NotImplementedError(type(t))

  def latex(RealFunction self, str varname="t"):
    """Generate LaTeX markup for the function."""
    return self.cfunction.latex(varname.encode()).decode()

  def _compose(RealFunction self, RealFunction rhs):
    """Compose the function with another RealFunction."""
    cdef RealFunction F = RealFunction()
    F.cfunction = self.cfunction.compose[REAL](rhs.cfunction)
    return F

  def __neg__(RealFunction self):
    """The additive inverse of the function."""
    cdef RealFunction F = RealFunction()
    F.cfunction = -self.cfunction
    return F

  def __iadd__(RealFunction self, rhs):
    """Add the function in-place with a constant or another RealFunction."""
    if isinstance(rhs, RealFunction):
      self.cfunction += (<RealFunction>rhs).cfunction
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction += <REAL>rhs
    else:
      raise NotImplementedError(type(self), type(rhs))
    return self

  def __isub__(RealFunction self, rhs):
    """Subtract a constant or another RealFunction from the function, in-place."""
    if isinstance(rhs, RealFunction):
      self.cfunction -= (<RealFunction>rhs).cfunction
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction -= <REAL>rhs
    else:
      raise NotImplementedError(type(self), type(rhs))
    return self

  def __imul__(RealFunction self, rhs):
    """Multiply the function in-place with a constant or another RealFunction."""
    if isinstance(rhs, RealFunction):
      self.cfunction *= (<RealFunction>rhs).cfunction
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction *= <REAL>rhs
    else:
      raise NotImplementedError(type(self), type(rhs))
    return self

  def __itruediv__(RealFunction self, rhs):
    """Divide the function in-place by a constant or another RealFunction."""
    if isinstance(rhs, RealFunction):
      self.cfunction /= (<RealFunction>rhs).cfunction
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction /= <REAL>rhs
    else:
      raise NotImplementedError(type(self), type(rhs))
    return self

  def __ipow__(RealFunction self, rhs):
    """Raise the function in-place to the power of a constant or another RealFunction."""
    if isinstance(rhs, RealFunction):
      self.cfunction.ipow((<RealFunction>rhs).cfunction)
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction.ipow(<REAL>rhs)
    else:
      raise NotImplementedError(type(self), type(rhs))
    return self

  def __add__(lhs, rhs):
    """Add the function with a constant or another RealFunction."""
    cdef RealFunction result
    if isinstance(lhs, RealFunction) and isinstance(rhs, (RealFunction, int, float, complex)):
      result = RealFunction()
      result.cfunction = (<RealFunction>lhs).cfunction
      result += rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, RealFunction):
      result = RealFunction()
      result.cfunction = (<RealFunction>rhs).cfunction
      result += lhs
    else:
      raise NotImplementedError
    return result

  def __sub__(lhs, rhs):
    """Subtract a constant or another RealFunction from the function."""
    cdef RealFunction result
    if isinstance(lhs, RealFunction) and isinstance(rhs, (RealFunction, int, float, complex)):
      result = RealFunction()
      result.cfunction = (<RealFunction>lhs).cfunction
      result -= rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, RealFunction):
      result = RealFunction()
      result.cfunction = rsubR(<REAL>lhs, (<RealFunction>rhs).cfunction)
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __mul__(lhs, rhs):
    """Multiply the function with a constant or another RealFunction."""
    cdef RealFunction result
    if isinstance(lhs, RealFunction) and isinstance(rhs, (RealFunction, int, float, complex)):
      result = RealFunction()
      result.cfunction = (<RealFunction>lhs).cfunction
      result *= rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, RealFunction):
      result = RealFunction()
      result.cfunction = (<RealFunction>rhs).cfunction
      result *= lhs
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __truediv__(lhs, rhs):
    """Divide the function by a constant or another RealFunction."""
    cdef RealFunction result
    if isinstance(lhs, RealFunction) and isinstance(rhs, (RealFunction, int, float, complex)):
      result = RealFunction()
      result.cfunction = (<RealFunction>lhs).cfunction
      result /= rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, RealFunction):
      result = RealFunction()
      result.cfunction = rdivR(<REAL>lhs, (<RealFunction>rhs).cfunction)
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __pow__(lhs, rhs, mod):
    """Raise the function to the power of a constant or another RealFunction."""
    cdef RealFunction result
    if isinstance(lhs, RealFunction) and isinstance(rhs, RealFunction):
      result = RealFunction()
      result.cfunction = (<RealFunction>lhs).cfunction.pow((<RealFunction>rhs).cfunction)
    elif isinstance(lhs, RealFunction) and isinstance(rhs, (int, float, complex)):
      result = RealFunction()
      result.cfunction = (<RealFunction>lhs).cfunction.pow(<REAL>rhs)
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, RealFunction):
      result = RealFunction()
      result.cfunction = (<RealFunction>rhs).cfunction.lpow(<REAL>lhs)
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __matmul__(lhs, rhs):
    """Compose the function with another RealFunction or Contour."""
    if isinstance(lhs, RealFunction) and isinstance(rhs, RealFunction):
      return lhs._compose(rhs)
    else:
      raise NotImplementedError(type(lhs), type(rhs))

  def __gt__(lhs, rhs):
    """Return a RealComparison that evaluates to True wherever is greater than another RealFunction or a constant."""
    cdef RealComparison result = RealComparison()
    if isinstance(lhs, RealFunction) and isinstance(rhs, RealFunction):
      result.ccomparison = (<RealFunction>lhs).cfunction > (<RealFunction>rhs).cfunction
      return result
    elif isinstance(lhs, RealFunction) and isinstance(rhs, (int, float)):
      result.ccomparison = (<RealFunction>lhs).cfunction > CFunction[REAL, REAL].Constant(<REAL>rhs)
    elif isinstance(lhs, (int, float)) and isinstance(rhs, RealFunction):
      result.ccomparison = CFunction[REAL, REAL].Constant(<REAL>lhs) > (<RealFunction>rhs).cfunction
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __lt__(lhs, rhs):
    """Return a RealComparison that evaluates to True wherever is less than another RealFunction or a constant."""
    cdef RealComparison result = RealComparison()
    if isinstance(lhs, RealFunction) and isinstance(rhs, RealFunction):
      result.ccomparison = (<RealFunction>lhs).cfunction < (<RealFunction>rhs).cfunction
      return result
    elif isinstance(lhs, RealFunction) and isinstance(rhs, (int, float)):
      result.ccomparison = (<RealFunction>lhs).cfunction < CFunction[REAL, REAL].Constant(<REAL>rhs)
    elif isinstance(lhs, (int, float)) and isinstance(rhs, RealFunction):
      result.ccomparison = CFunction[REAL, REAL].Constant(<REAL>lhs) < (<RealFunction>rhs).cfunction
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __eq__(lhs, rhs):
    """Return a RealComparison that evaluates to True wherever equals another RealFunction or a constant."""
    cdef RealComparison result = RealComparison()
    if isinstance(lhs, RealFunction) and isinstance(rhs, RealFunction):
      result.ccomparison = (<RealFunction>lhs).cfunction == (<RealFunction>rhs).cfunction
      return result
    elif isinstance(lhs, RealFunction) and isinstance(rhs, (int, float)):
      result.ccomparison = (<RealFunction>lhs).cfunction == CFunction[REAL, REAL].Constant(<REAL>rhs)
    elif isinstance(lhs, (int, float)) and isinstance(rhs, RealFunction):
      result.ccomparison = CFunction[REAL, REAL].Constant(<REAL>lhs) == (<RealFunction>rhs).cfunction
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __ge__(lhs, rhs):
    """Return a RealComparison that evaluates to True wherever is greater than or equal to another RealFunction or a constant."""
    cdef RealComparison result = RealComparison()
    if isinstance(lhs, RealFunction) and isinstance(rhs, RealFunction):
      result.ccomparison = (<RealFunction>lhs).cfunction >= (<RealFunction>rhs).cfunction
      return result
    elif isinstance(lhs, RealFunction) and isinstance(rhs, (int, float)):
      result.ccomparison = (<RealFunction>lhs).cfunction >= CFunction[REAL, REAL].Constant(<REAL>rhs)
    elif isinstance(lhs, (int, float)) and isinstance(rhs, RealFunction):
      result.ccomparison = CFunction[REAL, REAL].Constant(<REAL>lhs) >= (<RealFunction>rhs).cfunction
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __le__(lhs, rhs):
    """Return a RealComparison that evaluates to True wherever is less than or equal to another RealFunction or a constant."""
    cdef RealComparison result = RealComparison()
    if isinstance(lhs, RealFunction) and isinstance(rhs, RealFunction):
      result.ccomparison = (<RealFunction>lhs).cfunction <= (<RealFunction>rhs).cfunction
      return result
    elif isinstance(lhs, RealFunction) and isinstance(rhs, (int, float)):
      result.ccomparison = (<RealFunction>lhs).cfunction <= CFunction[REAL, REAL].Constant(<REAL>rhs)
    elif isinstance(lhs, (int, float)) and isinstance(rhs, RealFunction):
      result.ccomparison = CFunction[REAL, REAL].Constant(<REAL>lhs) <= (<RealFunction>rhs).cfunction
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __ne__(lhs, rhs):
    """Return a RealComparison that evaluates to True wherever is not equal to another RealFunction or a constant."""
    cdef RealComparison result = RealComparison()
    if isinstance(lhs, RealFunction) and isinstance(rhs, RealFunction):
      result.ccomparison = (<RealFunction>lhs).cfunction != (<RealFunction>rhs).cfunction
      return result
    elif isinstance(lhs, RealFunction) and isinstance(rhs, (int, float)):
      result.ccomparison = (<RealFunction>lhs).cfunction != CFunction[REAL, REAL].Constant(<REAL>rhs)
    elif isinstance(lhs, (int, float)) and isinstance(rhs, RealFunction):
      result.ccomparison = CFunction[REAL, REAL].Constant(<REAL>lhs) != (<RealFunction>rhs).cfunction
    else:
      raise NotImplementedError
    return result

  @staticmethod
  def Constant(const REAL c):
    """Constant function."""
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Constant(c)
    return F

  @staticmethod
  def Abs():
    """Absolute value."""
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Abs()
    return F

  @staticmethod
  def Identity():
    """Identity function."""
    return RealFunction()

  @staticmethod
  def Exp():
    """Exponent."""
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Exp()
    return F

  @staticmethod
  def Sin():
    """Sine."""
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Sin()
    return F

  @staticmethod
  def Cos():
    """Cosine."""
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Cos()
    return F

  @staticmethod
  def Tan():
    """Tangent."""
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Tan()
    return F

  @staticmethod
  def Sec():
    """Secant."""
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Sec()
    return F

  @staticmethod
  def Csc():
    """Cosecant."""
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Csc()
    return F

  @staticmethod
  def Cot():
    """Cotangent."""
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Cot()
    return F

  @staticmethod
  def Sinh():
    """Hyperbolic sine."""
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Sinh()
    return F

  @staticmethod
  def Cosh():
    """Hyperbolic cosine."""
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Cosh()
    return F

  @staticmethod
  def Tanh():
    """Hyperbolic tangent."""
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Tanh()
    return F

  @staticmethod
  def Sech():
    """Hyperbolic secant."""
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Sech()
    return F

  @staticmethod
  def Csch():
    """Hyperbolic cosecant."""
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Csch()
    return F

  @staticmethod
  def Coth():
    """Hyperbolic cotangent."""
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Coth()
    return F

  @staticmethod
  def Pi():
    """Constant function equal to pi; useful for the LaTeX output."""
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Pi()
    return F

  @staticmethod
  def E():
    """Constant function equal to e; useful for the LaTeX output."""
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].E()
    return F

  @staticmethod
  def If(RealComparison comp_, RealFunction then_, RealFunction else_=RealFunction.Constant(0)):
    """A function that evaluates to a certain function when a RealComparison is True, and otherwise evaluates to another function."""
    F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].If(comp_.ccomparison, then_.cfunction, else_.cfunction)
    return F
