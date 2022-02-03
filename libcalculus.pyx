# distutils: language = c++
from libcpp.complex cimport complex as complex_t
from libcpp.functional cimport function

cdef extern from "CFunction.cpp":
  pass

cdef extern from "CFunction.h" namespace "libcalculus":
  cdef cppclass CFunction:
    CFunction() except +
    CFunction(CFunction cf) except +
    complex_t[double] operator()(complex_t[double] z) except +

    CFunction operator+(CFunction rhs)
    CFunction operator-(CFunction rhs)
    CFunction operator*(CFunction rhs)
    CFunction operator/(CFunction rhs)
    CFunction reciprocal()

    CFunction mulconst(complex_t[double] a)
    CFunction addconst(complex_t[double] a)

  cdef CFunction identity

cdef class Function:
  cdef CFunction cfunction

  def __cinit__(self):
    pass

  def __call__(self, complex_t[double] z):
    return self.cfunction(z)

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

  def _addconst(self, complex_t[double] a):
    F = Function()
    F.cfunction = CFunction(self.cfunction).addconst(a)
    return F

  def _subconst(self, complex_t[double] a):
    F = Function()
    F.cfunction = CFunction(self.cfunction).addconst(0 - a)
    return F

  def _lsubconst(self, complex_t[double] a):
    F = Function()
    F.cfunction = CFunction(self.cfunction).mulconst(complex(-1)).addconst(a)
    return F

  def _mulconst(self, complex_t[double] a):
    F = Function()
    F.cfunction = CFunction(self.cfunction).mulconst(a)
    return F

  def _divconst(self, complex_t[double] a):
    F = Function()
    F.cfunction = CFunction(self.cfunction).mulconst(1 / a)
    return F

  def _ldivconst(self, complex_t[double] a):
    F = Function()
    F.cfunction = CFunction(self.cfunction).reciprocal().mulconst(a)
    return F

  @staticmethod
  def Identity():
    return Function()

  def __add__(lhs, rhs):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, Function):
      return rhs._addconst(lhs)
    elif isinstance(lhs, Function) and isinstance(rhs, (int, float, complex)):
      return lhs._addconst(rhs)
    elif isinstance(lhs, Function) and isinstance(rhs, Function):
      return lhs._add(rhs)

  def __sub__(lhs, rhs):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, Function):
      return rhs._lsubconst(lhs)
    elif isinstance(lhs, Function) and isinstance(rhs, (int, float, complex)):
      return lhs._subconst(rhs)
    elif isinstance(lhs, Function) and isinstance(rhs, Function):
      return lhs._sub(rhs)

  def __mul__(lhs, rhs):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, Function):
      return rhs._mulconst(lhs)
    elif isinstance(lhs, Function) and isinstance(rhs, (int, float, complex)):
      return lhs._mulconst(rhs)
    elif isinstance(lhs, Function) and isinstance(rhs, Function):
      return lhs._mul(rhs)

  def __truediv__(lhs, rhs):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, Function):
      return rhs._ldivconst(lhs)
    elif isinstance(lhs, Function) and isinstance(rhs, (int, float, complex)):
      return lhs._divconst(rhs)
    elif isinstance(lhs, Function) and isinstance(rhs, Function):
      return lhs._div(rhs)
