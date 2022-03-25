# distutils: language = c++
from cython.parallel import prange

cdef class Contour:
  cdef CFunction[REAL, COMPLEX] cfunction
  cdef REAL _start, _end

  def __cinit__(Contour self, const REAL start=0., const REAL end=1.):
    self._start = start
    self._end = end

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

  @property
  def start(Contour self):
    return self._start

  @start.setter
  def start(Contour self, const REAL value):
    self._start = value

  @property
  def end(Contour self):
    return self._end

  @end.setter
  def end(Contour self, const REAL value):
    self._end = value

  def latex(Contour self, str varname = "t"):
    """Generate LaTeX markup for the function."""
    return self.cfunction.latex(varname.encode()).decode()

  def _compose_real(Contour self, RealFunction rhs):
    """Compose the contour with a RealFunction, producing another Contour."""
    cdef Contour F = Contour(self._start, self._end)
    F.cfunction = self.cfunction.compose[REAL](rhs.cfunction)
    return F

  def __neg__(Contour self):
    """The additive inverse of the function."""
    cdef Contour F = Contour(self._start, self._end)
    F.cfunction = -self.cfunction
    return F

  def __invert__(Contour self):
    """Reverse the contour (run from end to start)."""
    cdef Contour F = Contour(self._end, self._start)
    F.cfunction = self.cfunction
    return F

  def __iadd__(Contour self, rhs):
    """Add the function in-place with a constant or another ComplexFunction."""
    if isinstance(rhs, Contour):
      self.cfunction += (<Contour>rhs).cfunction
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction += <COMPLEX>rhs
    else:
      raise NotImplementedError(type(self), type(rhs))
    return self

  def __isub__(Contour self, rhs):
    """Subtract a constant or another ComplexFunction from the function, in-place."""
    if isinstance(rhs, Contour):
      self.cfunction -= (<Contour>rhs).cfunction
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction -= <COMPLEX>rhs
    else:
      raise NotImplementedError(type(self), type(rhs))
    return self

  def __imul__(Contour self, rhs):
    """Multiply the function in-place with a constant or another ComplexFunction."""
    if isinstance(rhs, Contour):
      self.cfunction *= (<Contour>rhs).cfunction
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction *= <COMPLEX>rhs
    else:
      raise NotImplementedError(type(self), type(rhs))
    return self

  def __itruediv__(Contour self, rhs):
    """Divide the function in-place by a constant or another ComplexFunction."""
    if isinstance(rhs, Contour):
      self.cfunction /= (<Contour>rhs).cfunction
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction /= <COMPLEX>rhs
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
    """Add the function with a constant or another ComplexFunction."""
    cdef Contour result
    if isinstance(lhs, Contour) and isinstance(rhs, (Contour, int, float, complex)):
      result = Contour((<Contour>lhs)._start, (<Contour>lhs)._end)
      result.cfunction = (<Contour>lhs).cfunction
      result += rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      result = Contour((<Contour>rhs)._start, (<Contour>rhs)._end)
      result.cfunction = (<Contour>rhs).cfunction
      result += lhs
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __sub__(lhs, rhs):
    """Subtract a constant or another ComplexFunction from the function."""
    cdef Contour result
    if isinstance(lhs, Contour) and isinstance(rhs, (Contour, int, float, complex)):
      result = Contour((<Contour>lhs)._start, (<Contour>lhs)._end)
      result.cfunction = (<Contour>lhs).cfunction
      result -= rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      result = Contour((<Contour>rhs)._start, (<Contour>rhs)._end)
      result.cfunction = rsubC(<COMPLEX>lhs, (<Contour>rhs).cfunction)
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __mul__(lhs, rhs):
    """Multiply the function with a constant or another ComplexFunction."""
    cdef Contour result
    if isinstance(lhs, Contour) and isinstance(rhs, (Contour, int, float, complex)):
      result = Contour((<Contour>lhs)._start, (<Contour>lhs)._end)
      result.cfunction = (<Contour>lhs).cfunction
      result *= rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      result = Contour((<Contour>rhs)._start, (<Contour>rhs)._end)
      result.cfunction = (<Contour>rhs).cfunction
      result *= lhs
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __truediv__(lhs, rhs):
    """Divide the function by a constant or another ComplexFunction."""
    cdef Contour result
    if isinstance(lhs, Contour) and isinstance(rhs, (Contour, int, float, complex)):
      result = Contour((<Contour>lhs)._start, (<Contour>lhs)._end)
      result.cfunction = (<Contour>lhs).cfunction
      result /= rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      result = Contour((<Contour>rhs)._start, (<Contour>rhs)._end)
      result.cfunction = rdivC(<COMPLEX>lhs, (<Contour>rhs).cfunction)
    else:
      raise NotImplementedError(type(lhs), type(rhs))
    return result

  def __pow__(lhs, rhs, mod):
    """Raise the function to the power of a constant or another ComplexFunction."""
    cdef Contour result
    if isinstance(lhs, Contour) and isinstance(rhs, Contour):
      result = Contour((<Contour>lhs)._start, (<Contour>lhs)._end)
      result.cfunction = (<Contour>lhs).cfunction.pow((<Contour>rhs).cfunction)
    elif isinstance(lhs, Contour) and isinstance(rhs, (int, float, complex)):
      result = Contour((<Contour>lhs)._start, (<Contour>lhs)._end)
      result.cfunction = (<Contour>lhs).cfunction.pow(<COMPLEX>rhs)
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      result = Contour((<Contour>rhs)._start, (<Contour>rhs)._end)
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

  def __and__(Contour lhs, Contour rhs):
    """Scales both contours and concatenates them so that the resulting contour runs from 0 to 1, without loss of data."""
    return Contour.If((0. <= RealFunction.Identity()) & (RealFunction.Identity() < .5),
                      lhs @ (lhs.start + 2. * (lhs.end - lhs.start) * RealFunction.Identity()),
                      rhs @ (rhs.start + 2. * (rhs.end - rhs.start) * (RealFunction.Identity() - .5)))

  def __getitem__(Contour self, const complex z0):
    """Computes the index of z0 with respect to the contour."""
    assert np.allclose(self(self.start), self(self.end)), "Index defined only for closed contour."
    cdef REAL result = np.real(integrate(1. / (ComplexFunction.Identity() - z0), self, tol=.1) / (2j * M_PI))
    if not np.isfinite(result):
      return result # NaN; probably z0 is on the contour itself.
    else:
      return int(np.rint(result))

  def __eq__(lhs, rhs):
    """Return a RealComparison that evaluates to True wherever equals another Contour or a constant."""
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
    """Return a RealComparison that evaluates to True wherever isn't equal to another Contour or a constant."""
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
  def Abs(const REAL start=0., const REAL end=1.):
    """Absolute value."""
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Abs()
    return F

  @staticmethod
  def Identity(const REAL start=0., const REAL end=1.):
    """Identity function."""
    return Contour(start, end)

  @staticmethod
  def Exp(const REAL start=0., const REAL end=1.):
    """Exponent."""
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Exp()
    return F

  @staticmethod
  def Sin(const REAL start=0., const REAL end=1.):
    """Sine."""
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Sin()
    return F

  @staticmethod
  def Cos(const REAL start=0., const REAL end=1.):
    """Cosine."""
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Cos()
    return F

  @staticmethod
  def Tan(const REAL start=0., const REAL end=1.):
    """Tangent."""
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Tan()
    return F

  @staticmethod
  def Sec(const REAL start=0., const REAL end=1.):
    """Secant."""
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Sec()
    return F

  @staticmethod
  def Csc(const REAL start=0., const REAL end=1.):
    """Cosecant."""
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Csc()
    return F

  @staticmethod
  def Cot(const REAL start=0., const REAL end=1.):
    """Cotangent."""
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Cot()
    return F

  @staticmethod
  def Sinh(const REAL start=0., const REAL end=1.):
    """Hyperbolic sine."""
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Sinh()
    return F

  @staticmethod
  def Cosh(const REAL start=0., const REAL end=1.):
    """Hyperbolic cosine."""
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Cosh()
    return F

  @staticmethod
  def Tanh(const REAL start=0., const REAL end=1.):
    """Hyperbolic tangent."""
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Tanh()
    return F

  @staticmethod
  def Sech(const REAL start=0., const REAL end=1.):
    """Hyperbolic secant."""
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Sech()
    return F

  @staticmethod
  def Csch(const REAL start=0., const REAL end=1.):
    """Hyperbolic cosecant."""
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Csch()
    return F

  @staticmethod
  def Coth(const REAL start=0., const REAL end=1.):
    """Hyperbolic cotangent."""
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Coth()
    return F

  @staticmethod
  def Pi(const REAL start=0., const REAL end=1.):
    """Constant function equal to pi; useful for the LaTeX output."""
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Pi()
    return F

  @staticmethod
  def E(const REAL start=0., const REAL end=1.):
    """Constant function equal to e; useful for the LaTeX output."""
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].E()
    return F

  @staticmethod
  def If(RealComparison comp_, Contour then_, Contour else_=Contour.Constant(0), const REAL start=0., const REAL end=1.):
    """A function that evaluates to a certain function when a RealComparison is True, and otherwise evaluates to another function."""
    F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].If(comp_.ccomparison, then_.cfunction, else_.cfunction)
    return F

  @staticmethod
  def Line(const complex z1, const complex z2):
    """A contour that represents a line running from z1 to z2, with t running from 0 to 1."""
    return (1 - Contour.Identity()) * z1 + Contour.Identity() * z2

  @staticmethod
  def Sphere(const complex center=0., const REAL radius=1., const cbool ccw=False):
    """A contour that represents a circle around a center with a given a radius, with t running from 0 to 1, possibly running counterclockwise."""
    return center + (-1. if ccw else 1.) * radius * (ComplexFunction.Exp() @ (1j * Contour.Identity(0., 2. * M_PI)))
