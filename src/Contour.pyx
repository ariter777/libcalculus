# distutils: language = c++
from cython.parallel import prange

cdef class Contour:
  cdef CFunction[REAL, COMPLEX] cfunction

  @cython.nonecheck(False)
  @cython.boundscheck(False)
  @cython.wraparound(False)
  cdef np.ndarray[REAL] _call_array(Contour self, np.ndarray[const REAL] t):
    """Evaluate the function on an np.ndarray."""
    cdef COMPLEX[::1] result = np.empty(t.size, dtype=complex)
    cdef size_t i, n = t.size
    if Globals.NUM_THREADS > 1:
      # Use threading instead of SIMD.
      for i in prange(n, nogil=True, num_threads=Globals.NUM_THREADS):
        result[i] = self.cfunction(t[i])
    else:
        # Use SIMD
        self.cfunction._call_array(&t[0], &result[0], n)
    return np.asarray(result)

  def copy(Contour self):
    """Create a copy of the object."""
    cdef Contour result = Contour()
    result.cfunction = CFunction[REAL, COMPLEX](self.cfunction)
    return result

  def __call__(Contour self, t):
    """Evaluate the function at a point or on an np.ndarray of points."""
    if isinstance(t, (int, float, complex)):
      return self.cfunction(t)
    elif isinstance(t, np.ndarray) and t.dtype == np.double:
      return self._call_array(t.ravel()).reshape(t.shape)
    elif isinstance(t, np.ndarray) and np.issubdtype(t.dtype, np.number):
      return self._call_array(t.ravel().astype(np.double, copy=False)).reshape(t.shape)
    else:
      raise NotImplementedError(type(t))

  def latex(Contour self, str varname = "t"):
    """Generate LaTeX markup for the function."""
    return self.cfunction.latex(varname.encode()).decode()

  def _compose_real(Contour self, RealFunction rhs):
    """Compose the contour with a RealFunction, producing another Contour."""
    cdef Contour F = Contour()
    F.cfunction = self.cfunction.compose[REAL](rhs.cfunction)
    return F

  def __neg__(Contour self):
    """The additive inverse of the function."""
    cdef Contour F = Contour()
    F.cfunction = -self.cfunction
    return F

  def __iadd__(Contour self, rhs):
    """Add the function in-place with a constant or another Contour."""
    if isinstance(rhs, Contour):
      self.cfunction.iadd((<Contour>rhs).cfunction)
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction.iadd(<COMPLEX>rhs)
    else:
      raise NotImplementedError(type(self), type(rhs))
    return self

  def __isub__(Contour self, rhs):
    """Subtract a constant or another Contour from the function, in-place."""
    if isinstance(rhs, Contour):
      self.cfunction.isub((<Contour>rhs).cfunction)
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction.isub(<COMPLEX>rhs)
    else:
      raise NotImplementedError(type(self), type(rhs))
    return self

  def __imul__(Contour self, rhs):
    """Multiply the function in-place with a constant or another Contour."""
    if isinstance(rhs, Contour):
      self.cfunction.imul((<Contour>rhs).cfunction)
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction.imul(<COMPLEX>rhs)
    else:
      raise NotImplementedError(type(self), type(rhs))
    return self

  def __itruediv__(Contour self, rhs):
    """Divide the function in-place by a constant or another Contour."""
    if isinstance(rhs, Contour):
      self.cfunction.idiv((<Contour>rhs).cfunction)
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction.idiv(<COMPLEX>rhs)
    else:
      raise NotImplementedError(type(self), type(rhs))
    return self

  def __ipow__(Contour self, rhs):
    """Raise the function in-place to the power of a constant or another Contour."""
    if isinstance(rhs, Contour):
      self.cfunction.ipow((<Contour>rhs).cfunction)
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction.ipow(<COMPLEX>rhs)
    else:
      raise NotImplementedError(type(self), type(rhs))
    return self

  def __add__(lhs, rhs):
    """Add the function with a constant or another Contour."""
    cdef Contour result
    if isinstance(lhs, Contour) and isinstance(rhs, (Contour, int, float, complex)):
      result = Contour()
      result.cfunction = (<Contour>lhs).cfunction
      result += rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      result = Contour()
      result.cfunction = (<Contour>rhs).cfunction
      result += lhs
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __sub__(lhs, rhs):
    """Subtract a constant or another Contour from the function."""
    cdef Contour result
    if isinstance(lhs, Contour) and isinstance(rhs, (Contour, int, float, complex)):
      result = Contour()
      result.cfunction = (<Contour>lhs).cfunction
      result -= rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      result = Contour()
      result.cfunction = rsubC(<COMPLEX>lhs, (<Contour>rhs).cfunction)
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __mul__(lhs, rhs):
    """Multiply the function with a constant or another Contour."""
    cdef Contour result
    if isinstance(lhs, Contour) and isinstance(rhs, (Contour, int, float, complex)):
      result = Contour()
      result.cfunction = (<Contour>lhs).cfunction
      result *= rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      result = Contour()
      result.cfunction = (<Contour>rhs).cfunction
      result *= lhs
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __truediv__(lhs, rhs):
    """Divide the function by a constant or another Contour."""
    cdef Contour result
    if isinstance(lhs, Contour) and isinstance(rhs, (Contour, int, float, complex)):
      result = Contour()
      result.cfunction = (<Contour>lhs).cfunction
      result /= rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      result = Contour()
      result.cfunction = rdivC(<COMPLEX>lhs, (<Contour>rhs).cfunction)
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __pow__(lhs, rhs, mod):
    """Raise the function to the power of a constant or another Contour."""
    cdef Contour result
    if isinstance(lhs, Contour) and isinstance(rhs, Contour):
      result = Contour()
      result.cfunction = (<Contour>lhs).cfunction.pow((<Contour>rhs).cfunction)
    elif isinstance(lhs, Contour) and isinstance(rhs, (int, float, complex)):
      result = Contour()
      result.cfunction = (<Contour>lhs).cfunction.pow(<COMPLEX>rhs)
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      result = Contour()
      result.cfunction = (<Contour>rhs).cfunction.lpow(<COMPLEX>lhs)
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __matmul__(lhs, rhs):
    """Compose the contour with a RealFunction, producing another Contour."""
    if isinstance(lhs, Contour) and isinstance(rhs, RealFunction):
      return lhs._compose_real(rhs)
    else:
      raise NotImplementedError(type(lhs), type(rhs))

  def index(Contour self, const COMPLEX z0, const REAL start=0., const REAL end=1.):
    """Computes the index of z0 with respect to the contour."""
    assert np.allclose(self(start), self(end)), "Index defined only for closed contour."
    cdef REAL result = np.real(integrate(1. / (ComplexFunction.Identity() - z0), self, start, end) / (2j * M_PI))
    if not np.isfinite(result):
      return result # NaN; probably z0 is on the contour itself.
    else:
      return int(np.rint(result))

  def __eq__(lhs, rhs):
    """Return a RealComparison that evaluates to True wherever the Contour equals another Contour or a constant."""
    cdef RealComparison result = RealComparison()
    if isinstance(lhs, Contour) and isinstance(rhs, Contour):
      result.ccomparison = (<Contour>lhs).cfunction == (<Contour>rhs).cfunction
      return result
    elif isinstance(lhs, Contour) and isinstance(rhs, (int, float, complex)):
      result.ccomparison = (<Contour>lhs).cfunction == CFunction[REAL, COMPLEX].Constant(<COMPLEX>rhs)
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      result.ccomparison = CFunction[REAL, COMPLEX].Constant(<COMPLEX>lhs) == (<Contour>rhs).cfunction
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __ne__(lhs, rhs):
    """Return a RealComparison that evaluates to True wherever the Contour isn't equal to another Contour or a constant."""
    cdef RealComparison result = RealComparison()
    if isinstance(lhs, Contour) and isinstance(rhs, Contour):
      result.ccomparison = (<Contour>lhs).cfunction != (<Contour>rhs).cfunction
      return result
    elif isinstance(lhs, Contour) and isinstance(rhs, (int, float, complex)):
      result.ccomparison = (<Contour>lhs).cfunction != CFunction[REAL, COMPLEX].Constant(<COMPLEX>rhs)
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      result.ccomparison = CFunction[REAL, COMPLEX].Constant(<COMPLEX>lhs) != (<Contour>rhs).cfunction
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  @staticmethod
  def Constant(const COMPLEX c):
    """Constant function."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Constant(c)
    return F

  @staticmethod
  def Abs():
    """Absolute value."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Abs()
    return F

  @staticmethod
  def Identity():
    """Identity function."""
    return Contour()

  @staticmethod
  def Exp():
    """Exponent."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Exp()
    return F

  @staticmethod
  def Sin():
    """Sine."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Sin()
    return F

  @staticmethod
  def Cos():
    """Cosine."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Cos()
    return F

  @staticmethod
  def Tan():
    """Tangent."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Tan()
    return F

  @staticmethod
  def Sec():
    """Secant."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Sec()
    return F

  @staticmethod
  def Csc():
    """Cosecant."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Csc()
    return F

  @staticmethod
  def Cot():
    """Cotangent."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Cot()
    return F

  @staticmethod
  def Sinh():
    """Hyperbolic sine."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Sinh()
    return F

  @staticmethod
  def Cosh():
    """Hyperbolic cosine."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Cosh()
    return F

  @staticmethod
  def Tanh():
    """Hyperbolic tangent."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Tanh()
    return F

  @staticmethod
  def Sech():
    """Hyperbolic secant."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Sech()
    return F

  @staticmethod
  def Csch():
    """Hyperbolic cosecant."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Csch()
    return F

  @staticmethod
  def Coth():
    """Hyperbolic cotangent."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Coth()
    return F

  @staticmethod
  def Arcsin():
    """Inverse sine."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Arcsin()
    return F

  @staticmethod
  def Arccos():
    """Inverse cosine."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Arccos()
    return F

  @staticmethod
  def Arctan():
    """Inverse tangent"""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Arctan()
    return F

  @staticmethod
  def Arccsc():
    """Inverse cosecant."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Arccsc()
    return F

  @staticmethod
  def Arcsec():
    """Inverse secant."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Arcsec()
    return F

  @staticmethod
  def Arccot():
    """Inverse cotangent"""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Arccot()
    return F

  @staticmethod
  def Arsinh():
    """Inverse sine."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Arsinh()
    return F

  @staticmethod
  def Arcosh():
    """Inverse hyperbolic cosine."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Arcosh()
    return F

  @staticmethod
  def Artanh():
    """Inverse hyperbolic tangent"""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Artanh()
    return F

  @staticmethod
  def Arcsch():
    """Inverse hyperbolic cosecant."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Arcsch()
    return F

  @staticmethod
  def Arsech():
    """Inverse hyperbolic secant."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Arsech()
    return F

  @staticmethod
  def Arcoth():
    """Inverse hyperbolic cotangent"""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Arcoth()
    return F

  @staticmethod
  def Pi():
    """Constant function equal to pi; useful for the LaTeX output."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Pi()
    return F

  @staticmethod
  def E():
    """Constant function equal to e; useful for the LaTeX output."""
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].E()
    return F

  @staticmethod
  def If(RealComparison comp_ not None, Contour then_ not None, Contour else_ not None=Contour.Constant(0), ):
    """A function that evaluates to a certain function when a RealComparison is True, and otherwise evaluates to another function."""
    F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].If(comp_.ccomparison, then_.cfunction, else_.cfunction)
    return F

  @staticmethod
  def Line(const complex z1, const complex z2):
    """A contour that represents a line running from z1 to z2, with t running from 0 to 1."""
    return (1 - Contour.Identity()) * z1 + Contour.Identity() * z2

  @staticmethod
  def Sphere(const COMPLEX center=0., const REAL radius=1., const cbool ccw=False):
    """A contour that represents a circle around a center with a given a radius, with t running from 0 to 1, possibly running counterclockwise."""
    return center + (-1. if ccw else 1.) * radius * (ComplexFunction.Exp() @ (2j * M_PI * Contour.Identity()))
