# distutils: language = c++
from libcpp.complex cimport complex as complex_t
from libcpp.string cimport string
cimport libc.math

cdef double e = libc.math.e
cdef double pi = libc.math.pi

ctypedef complex_t[double] dtype

cdef extern from "CFunction.cpp":
  pass

cdef extern from "CFunction.h" namespace "libcalculus":
  cdef cppclass CFunction:
    CFunction() except +
    CFunction(CFunction cf) except +
    dtype operator()(dtype z) except +
    CFunction compose(CFunction rhs)
    string latex(string varname) except +

    CFunction operator+(CFunction rhs)
    CFunction operator-(CFunction rhs)
    CFunction operator*(CFunction rhs)
    CFunction operator/(CFunction rhs)
    CFunction pow(CFunction rhs)
    CFunction reciprocal()

    CFunction mulconst(dtype a)
    CFunction addconst(dtype a)
    CFunction powconst(dtype a)
    CFunction lpowconst(dtype a)

    @staticmethod
    CFunction Exp()
    @staticmethod
    CFunction Sin()
    @staticmethod
    CFunction Cos()
    @staticmethod
    CFunction Tan()
    @staticmethod
    CFunction Sec()
    @staticmethod
    CFunction Csc()
    @staticmethod
    CFunction Cot()

  cdef CFunction identity

cdef class Function:
  cdef CFunction cfunction

  def __cinit__(self):
    pass

  def __call__(self, dtype z):
    return self.cfunction(z)

  def latex(self, str varname = "z"):
    return self.cfunction.latex(varname.encode()).decode()

  def _add(self, Function rhs):
    F = Function()
    F.cfunction = CFunction(self.cfunction) + rhs.cfunction
    return F

  def _sub(self, Function rhs):
    F = Function()
    F.cfunction = CFunction(self.cfunction) - rhs.cfunction
    return F

  def _mul(self, Function rhs):
    F = Function()
    F.cfunction = CFunction(self.cfunction) * rhs.cfunction
    return F

  def _div(self, Function rhs):
    F = Function()
    F.cfunction = CFunction(self.cfunction) / rhs.cfunction
    return F

  def _pow(self, Function rhs):
    F = Function()
    F.cfunction = CFunction(self.cfunction).pow(rhs.cfunction)
    return F

  def _compose(self, Function rhs):
    F = Function()
    F.cfunction = CFunction(self.cfunction).compose(rhs.cfunction)
    return F

  def _addconst(self, dtype a):
    F = Function()
    F.cfunction = CFunction(self.cfunction).addconst(a)
    return F

  def _subconst(self, dtype a):
    F = Function()
    F.cfunction = CFunction(self.cfunction).addconst(0 - a)
    return F

  def _lsubconst(self, dtype a):
    F = Function()
    F.cfunction = CFunction(self.cfunction).mulconst(complex(-1)).addconst(a)
    return F

  def _mulconst(self, dtype a):
    F = Function()
    F.cfunction = CFunction(self.cfunction).mulconst(a)
    return F

  def _divconst(self, dtype a):
    F = Function()
    F.cfunction = CFunction(self.cfunction).mulconst(1 / a)
    return F

  def _ldivconst(self, dtype a):
    F = Function()
    F.cfunction = CFunction(self.cfunction).reciprocal().mulconst(a)
    return F

  def _powconst(self, dtype a):
    F = Function()
    F.cfunction = CFunction(self.cfunction).powconst(a)
    return F

  def _lpowconst(self, dtype a):
    F = Function()
    F.cfunction = CFunction(self.cfunction).lpowconst(a)
    return F

  def __add__(lhs, rhs):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, Function):
      return rhs._addconst(lhs)
    elif isinstance(lhs, Function) and isinstance(rhs, (int, float, complex)):
      return lhs._addconst(rhs)
    elif isinstance(lhs, Function) and isinstance(rhs, Function):
      return lhs._add(rhs)
    else:
      raise NotImplementedError

  def __sub__(lhs, rhs):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, Function):
      return rhs._lsubconst(lhs)
    elif isinstance(lhs, Function) and isinstance(rhs, (int, float, complex)):
      return lhs._subconst(rhs)
    elif isinstance(lhs, Function) and isinstance(rhs, Function):
      return lhs._sub(rhs)
    else:
      raise NotImplementedError

  def __mul__(lhs, rhs):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, Function):
      return rhs._mulconst(lhs)
    elif isinstance(lhs, Function) and isinstance(rhs, (int, float, complex)):
      return lhs._mulconst(rhs)
    elif isinstance(lhs, Function) and isinstance(rhs, Function):
      return lhs._mul(rhs)
    else:
      raise NotImplementedError

  def __truediv__(lhs, rhs):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, Function):
      return rhs._ldivconst(lhs)
    elif isinstance(lhs, Function) and isinstance(rhs, (int, float, complex)):
      return lhs._divconst(rhs)
    elif isinstance(lhs, Function) and isinstance(rhs, Function):
      return lhs._div(rhs)
    else:
      raise NotImplementedError

  def __pow__(lhs, rhs, mod):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, Function):
      return rhs._lpowconst(lhs)
    elif isinstance(lhs, Function) and isinstance(rhs, (int, float, complex)):
      return lhs._powconst(rhs)
    elif isinstance(lhs, Function) and isinstance(rhs, Function):
      return lhs._pow(rhs)
    else:
      raise NotImplementedError

  def __matmul__(lhs, rhs):
    if isinstance(lhs, Function) and isinstance(rhs, Function):
      return lhs._compose(rhs)
    else:
      raise NotImplementedError

  @staticmethod
  def Identity():
    return Function()

  @staticmethod
  def Exp():
    F = Function()
    F.cfunction = CFunction.Exp()
    return F

  @staticmethod
  def Sin():
    F = Function()
    F.cfunction = CFunction.Sin()
    return F

  @staticmethod
  def Cos():
    F = Function()
    F.cfunction = CFunction.Cos()
    return F

  @staticmethod
  def Tan():
    F = Function()
    F.cfunction = CFunction.Tan()
    return F

  @staticmethod
  def Sec():
    F = Function()
    F.cfunction = CFunction.Sec()
    return F

  @staticmethod
  def Csc():
    F = Function()
    F.cfunction = CFunction.Csc()
    return F

  @staticmethod
  def Cot():
    F = Function()
    F.cfunction = CFunction.Cot()
    return F
