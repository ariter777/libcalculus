# distutils: language = c++
from cython.parallel import prange

cdef class RealFunction:
  cdef CFunction[REAL, REAL] cfunction

  @cython.boundscheck(False)
  @cython.wraparound(False)
  cdef np.ndarray[REAL] _call_array(RealFunction self, np.ndarray[const REAL] t):
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

  def __call__(RealFunction self, t):
    if isinstance(t, (int, float, complex)):
      return self.cfunction(t)
    elif isinstance(t, np.ndarray) and t.dtype == np.double:
      return self._call_array(t.ravel()).reshape(t.shape)
    elif isinstance(t, np.ndarray) and np.issubdtype(t.dtype, np.number):
      return self._call_array(t.ravel().astype(np.double, copy=False)).reshape(t.shape)
    else:
      raise NotImplementedError(type(t))

  def latex(RealFunction self, str varname="t"):
    return self.cfunction.latex(varname.encode()).decode()

  def _compose(RealFunction self, RealFunction rhs):
    cdef RealFunction F = RealFunction()
    F.cfunction = self.cfunction.compose[REAL](rhs.cfunction)
    return F

  def __neg__(RealFunction self):
    cdef RealFunction F = RealFunction()
    F.cfunction = -self.cfunction
    return F

  def __iadd__(RealFunction self, rhs):
    if isinstance(rhs, RealFunction):
      self.cfunction += (<RealFunction>rhs).cfunction
      return self
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction += <REAL>rhs
      return self

  def __isub__(RealFunction self, rhs):
    if isinstance(rhs, RealFunction):
      self.cfunction -= (<RealFunction>rhs).cfunction
      return self
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction -= <REAL>rhs
      return self

  def __imul__(RealFunction self, rhs):
    if isinstance(rhs, RealFunction):
      self.cfunction *= (<RealFunction>rhs).cfunction
      return self
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction *= <REAL>rhs
      return self

  def __itruediv__(RealFunction self, rhs):
    if isinstance(rhs, RealFunction):
      self.cfunction /= (<RealFunction>rhs).cfunction
      return self
    elif isinstance(rhs, (int, float, complex)):
      self.cfunction /= <REAL>rhs
      return self

  def __add__(lhs, rhs):
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
    if isinstance(lhs, RealFunction) and isinstance(rhs, RealFunction):
      return lhs._compose(rhs)
    else:
      raise NotImplementedError(type(lhs), type(rhs))

  def __gt__(lhs, rhs):
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
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Constant(c)
    return F

  @staticmethod
  def Abs():
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Abs()
    return F

  @staticmethod
  def Identity(const REAL start=0., const REAL end=1.):
    return RealFunction()

  @staticmethod
  def Exp(const REAL start=0., const REAL end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Exp()
    return F

  @staticmethod
  def Sin(const REAL start=0., const REAL end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Sin()
    return F

  @staticmethod
  def Cos(const REAL start=0., const REAL end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Cos()
    return F

  @staticmethod
  def Tan(const REAL start=0., const REAL end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Tan()
    return F

  @staticmethod
  def Sec(const REAL start=0., const REAL end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Sec()
    return F

  @staticmethod
  def Csc(const REAL start=0., const REAL end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Csc()
    return F

  @staticmethod
  def Cot(const REAL start=0., const REAL end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Cot()
    return F

  @staticmethod
  def Sinh(const REAL start=0., const REAL end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Sinh()
    return F

  @staticmethod
  def Cosh(const REAL start=0., const REAL end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Cosh()
    return F

  @staticmethod
  def Tanh(const REAL start=0., const REAL end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Tanh()
    return F

  @staticmethod
  def Sech(const REAL start=0., const REAL end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Sech()
    return F

  @staticmethod
  def Csch(const REAL start=0., const REAL end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Csch()
    return F

  @staticmethod
  def Coth(const REAL start=0., const REAL end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Coth()
    return F

  @staticmethod
  def Pi(const REAL start=0., const REAL end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Pi()
    return F

  @staticmethod
  def E(const REAL start=0., const REAL end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].E()
    return F

  @staticmethod
  def If(RealComparison comp_, RealFunction then_, RealFunction else_=RealFunction.Constant(0)):
    F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].If(comp_.ccomparison, then_.cfunction, else_.cfunction)
    return F
