# distutils: language = c++
from CFunction cimport *
from cython.parallel import prange

cdef class ComplexFunction:
  cdef CFunction[COMPLEX, COMPLEX] cfunction

  @cython.nonecheck(False)
  @cython.boundscheck(False)
  @cython.wraparound(False)
  cdef np.ndarray[COMPLEX] _call_array(ComplexFunction self, np.ndarray[const COMPLEX] z):
    """Evaluate the function on an np.ndarray."""
    cdef COMPLEX[::1] result = np.empty(z.size, dtype=complex)
    cdef size_t i, n = z.size
    if Globals.NUM_THREADS > 1:
      # Use threading instead of SIMD.
      for i in prange(n, nogil=True, num_threads=Globals.NUM_THREADS):
        result[i] = self.cfunction(z[i])
    else:
        # Use SIMD
        self.cfunction._call_array(&z[0], &result[0], n)
    return np.asarray(result)

  def copy(ComplexFunction self):
    """Create a copy of the object."""
    cdef ComplexFunction result = ComplexFunction()
    result.cfunction = CFunction[COMPLEX, COMPLEX](self.cfunction)
    return result

  def __call__(ComplexFunction self, z):
    """Evaluate the function at a point or on an np.ndarray of points."""
    if isinstance(z, (int, float, complex)):
      return self.cfunction(z)
    elif isinstance(z, np.ndarray) and z.dtype == complex:
      return self._call_array(z.ravel()).reshape(z.shape)
    elif isinstance(z, np.ndarray) and np.issubdtype(z.dtype, np.number):
      return self._call_array(z.ravel().astype(complex, copy=False)).reshape(z.shape)
    else:
      raise NotImplementedError(type(z))

  def latex(ComplexFunction self, str varname="z"):
    """Generate LaTeX markup for the function."""
    return self.cfunction.latex(varname.encode()).decode()

  def _compose(ComplexFunction self, ComplexFunction rhs):
    """Compose the function with another ComplexFunction."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = self.cfunction.compose[COMPLEX](rhs.cfunction)
    return F

  def _compose_contour(ComplexFunction self, Contour rhs):
    """Compose the function with a contour, producing another contour."""
    cdef Contour F = Contour((<Contour>rhs)._start, (<Contour>rhs)._end)
    F.cfunction = self.cfunction.compose[REAL](rhs.cfunction)
    return F

  def __neg__(ComplexFunction self):
    """The additive inverse of the function."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = -self.cfunction
    return F

  def __iadd__(ComplexFunction self, rhs):
    """Add the function in-place with a constant or another ComplexFunction."""
    if isinstance(rhs, ComplexFunction):
      self.cfunction += (<ComplexFunction>rhs).cfunction
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction += <COMPLEX>rhs
    else:
      raise NotImplementedError(type(self), type(rhs))
    return self

  def __isub__(ComplexFunction self, rhs):
    """Subtract a constant or another ComplexFunction from the function, in-place."""
    if isinstance(rhs, ComplexFunction):
      self.cfunction -= (<ComplexFunction>rhs).cfunction
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction -= <COMPLEX>rhs
    else:
      raise NotImplementedError(type(self), type(rhs))
    return self

  def __imul__(ComplexFunction self, rhs):
    """Multiply the function in-place with a constant or another ComplexFunction."""
    if isinstance(rhs, ComplexFunction):
      self.cfunction *= (<ComplexFunction>rhs).cfunction
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction *= <COMPLEX>rhs
    else:
      raise NotImplementedError(type(self), type(rhs))
    return self

  def __itruediv__(ComplexFunction self, rhs):
    """Divide the function in-place by a constant or another ComplexFunction."""
    if isinstance(rhs, ComplexFunction):
      self.cfunction /= (<ComplexFunction>rhs).cfunction
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction /= <COMPLEX>rhs
    else:
      raise NotImplementedError(type(self), type(rhs))
    return self

  def __ipow__(ComplexFunction self, rhs):
    """Raise the function in-place to the power of a constant or another ComplexFunction."""
    if isinstance(rhs, ComplexFunction):
      self.cfunction.ipow((<ComplexFunction>rhs).cfunction)
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction.ipow(<COMPLEX>rhs)
    else:
      raise NotImplementedError(type(self), type(rhs))
    return self

  def __add__(lhs, rhs):
    """Add the function with a constant or another ComplexFunction."""
    cdef ComplexFunction result = ComplexFunction()
    if isinstance(lhs, ComplexFunction) and isinstance(rhs, (ComplexFunction, int, float, complex)):
      result.cfunction = (<ComplexFunction>lhs).cfunction
      result += rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, ComplexFunction):
      result.cfunction = (<ComplexFunction>rhs).cfunction
      result += lhs
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __sub__(lhs, rhs):
    """Subtract a constant or another ComplexFunction from the function."""
    cdef ComplexFunction result = ComplexFunction()
    if isinstance(lhs, ComplexFunction) and isinstance(rhs, (ComplexFunction, int, float, complex)):
      result.cfunction = (<ComplexFunction>lhs).cfunction
      result -= rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, ComplexFunction):
      result.cfunction = csubC(<COMPLEX>lhs, (<ComplexFunction>rhs).cfunction) # FIX!!
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __mul__(lhs, rhs):
    """Multiply the function with a constant or another ComplexFunction."""
    cdef ComplexFunction result = ComplexFunction()
    if isinstance(lhs, ComplexFunction) and isinstance(rhs, (ComplexFunction, int, float, complex)):
      result.cfunction = (<ComplexFunction>lhs).cfunction
      result *= rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, ComplexFunction):
      result.cfunction = (<ComplexFunction>rhs).cfunction
      result *= lhs
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __truediv__(lhs, rhs):
    """Divide the function by a constant or another ComplexFunction."""
    cdef ComplexFunction result = ComplexFunction()
    if isinstance(lhs, ComplexFunction) and isinstance(rhs, (ComplexFunction, int, float, complex)):
      result.cfunction = (<ComplexFunction>lhs).cfunction
      result /= rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, ComplexFunction):
      result.cfunction = cdivC(<COMPLEX>lhs, (<ComplexFunction>rhs).cfunction)
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __pow__(lhs, rhs, mod):
    """Raise the function to the power of a constant or another ComplexFunction."""
    cdef ComplexFunction result = ComplexFunction()
    if isinstance(lhs, ComplexFunction) and isinstance(rhs, ComplexFunction):
      result.cfunction = (<ComplexFunction>lhs).cfunction.pow((<ComplexFunction>rhs).cfunction)
    elif isinstance(lhs, ComplexFunction) and isinstance(rhs, (int, float, complex)):
      result.cfunction = (<ComplexFunction>lhs).cfunction.pow(<COMPLEX>rhs)
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, ComplexFunction):
      result.cfunction = (<ComplexFunction>rhs).cfunction.lpow(<COMPLEX>lhs)
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __matmul__(lhs, rhs):
    """Compose the function with another ComplexFunction or Contour."""
    if isinstance(lhs, ComplexFunction) and isinstance(rhs, ComplexFunction):
      return lhs._compose(rhs)
    if isinstance(lhs, ComplexFunction) and isinstance(rhs, Contour):
      return lhs._compose_contour(rhs)
    else:
      raise NotImplementedError(type(lhs), type(rhs))

  def __eq__(lhs, rhs):
    """Return a ComplexComparison that evaluates to True wherever equals another ComplexFunction or a constant."""
    cdef ComplexComparison result = ComplexComparison()
    if isinstance(lhs, ComplexFunction) and isinstance(rhs, ComplexFunction):
      result.ccomparison = (<ComplexFunction>lhs).cfunction == (<ComplexFunction>rhs).cfunction
      return result
    elif isinstance(lhs, ComplexFunction) and isinstance(rhs, (int, float, complex)):
      result.ccomparison = (<ComplexFunction>lhs).cfunction == CFunction[COMPLEX, COMPLEX].Constant(<COMPLEX>rhs)
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, ComplexFunction):
      result.ccomparison = CFunction[COMPLEX, COMPLEX].Constant(<COMPLEX>lhs) == (<ComplexFunction>rhs).cfunction
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __ne__(lhs, rhs):
    """Return a ComplexComparison that evaluates to True wherever does not equal another ComplexFunction or a constant."""
    cdef ComplexComparison result = ComplexComparison()
    if isinstance(lhs, ComplexFunction) and isinstance(rhs, ComplexFunction):
      result.ccomparison = (<ComplexFunction>lhs).cfunction != (<ComplexFunction>rhs).cfunction
      return result
    elif isinstance(lhs, ComplexFunction) and isinstance(rhs, (int, float, complex)):
      result.ccomparison = (<ComplexFunction>lhs).cfunction != CFunction[COMPLEX, COMPLEX].Constant(<COMPLEX>rhs)
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, ComplexFunction):
      result.ccomparison = CFunction[COMPLEX, COMPLEX].Constant(<COMPLEX>lhs) != (<ComplexFunction>rhs).cfunction
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def zeros(ComplexFunction self, Contour contour):
    """Calculates the number of zeros the functions has inside a closed contour, assuming it is holomorphic."""
    assert np.allclose(contour(contour.start), contour(contour.end)), "Number of zeros defined only for closed contour."
    return (self @ contour)[0.]

  @staticmethod
  def Constant(const COMPLEX c):
    """Constant function."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Constant(c)
    return F

  @staticmethod
  def Re():
    """Real part."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Re()
    return F

  @staticmethod
  def Im():
    """Imaginary part."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Im()
    return F

  @staticmethod
  def Conj():
    """Complex conjugate."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Conj()
    return F

  @staticmethod
  def Abs():
    """Absolute value."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Abs()
    return F

  @staticmethod
  def Identity():
    """Identity function."""
    return ComplexFunction()

  @staticmethod
  def Exp():
    """Exponent."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Exp()
    return F

  @staticmethod
  def Sin():
    """Sine."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Sin()
    return F

  @staticmethod
  def Cos():
    """Cosine."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Cos()
    return F

  @staticmethod
  def Tan():
    """Tangent."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Tan()
    return F

  @staticmethod
  def Sec():
    """Secant."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Sec()
    return F

  @staticmethod
  def Csc():
    """Cosecant."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Csc()
    return F

  @staticmethod
  def Cot():
    """Cotangent."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Cot()
    return F

  @staticmethod
  def Sinh():
    """Hyperbolic sine."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Sinh()
    return F

  @staticmethod
  def Cosh():
    """Hyperbolic cosine."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Cosh()
    return F

  @staticmethod
  def Tanh():
    """Hyperbolic tangent."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Tanh()
    return F

  @staticmethod
  def Sech():
    """Hyperbolic secant."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Sech()
    return F

  @staticmethod
  def Csch():
    """Hyperbolic cosecant."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Csch()
    return F

  @staticmethod
  def Coth():
    """Hyperbolic cotangent."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Coth()
    return F

  @staticmethod
  def Pi():
    """Constant function equal to pi; useful for the LaTeX output."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Pi()
    return F

  @staticmethod
  def E():
    """Constant function equal to e; useful for the LaTeX output."""
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].E()
    return F

  @staticmethod
  def If(ComplexComparison comp_, ComplexFunction then_, ComplexFunction else_=ComplexFunction.Constant(0)):
    """A function that evaluates to a certain function when a ComplexComparison is True, and otherwise evaluates to another function."""
    F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].If(comp_.ccomparison, then_.cfunction, else_.cfunction)
    return F
