# distutils: language = c++
from libcpp.complex cimport complex as complex_t
from libcpp.functional cimport function

cdef extern from "CFunction.cpp":
  pass

cdef extern from "CFunction.h" namespace "libcalculus":
  cdef cppclass CFunction:
    function[complex_t[double](complex_t[double])] f

    CFunction() except +
    CFunction(CFunction &cf) except +
    complex_t[double] operator()(complex_t[double] z) except +

    void mulconst(complex_t[double] a)
    void addconst(complex_t[double] a)
    void subconst(complex_t[double] a)
    void lsubconst(complex_t[double] a)
    void divconst(complex_t[double] a) except +
    void ldivconst(complex_t[double] a) except +

  cdef CFunction identity

cdef class Function:
  cdef CFunction cfunction

  def __cinit__(self):
    pass

  def __call__(self, complex_t[double] z):
    return self.cfunction(z)

  def _addconst(self, complex_t[double] a):
    F = Function()
    F.cfunction = CFunction(self.cfunction)
    F.cfunction.addconst(a)
    return F

  def _subconst(self, complex_t[double] a):
    F = Function()
    F.cfunction = CFunction(self.cfunction)
    F.cfunction.subconst(a)
    return F

  def _lsubconst(self, complex_t[double] a):
    F = Function()
    F.cfunction = CFunction(self.cfunction)
    F.cfunction.lsubconst(a)
    return F

  def _mulconst(self, complex_t[double] a):
    F = Function()
    F.cfunction = CFunction(self.cfunction)
    F.cfunction.mulconst(a)
    return F

  def _divconst(self, complex_t[double] a):
    F = Function()
    F.cfunction = CFunction(self.cfunction)
    F.cfunction.divconst(a)
    return F

  def _ldivconst(self, complex_t[double] a):
    F = Function()
    F.cfunction = CFunction(self.cfunction)
    F.cfunction.ldivconst(a)
    return F

  @staticmethod
  def Identity():
    return Function()

  def __mul__(lhs, rhs):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, Function):
      return rhs._mulconst(lhs)
    elif isinstance(lhs, Function) and isinstance(rhs, (int, float, complex)):
      return lhs._mulconst(rhs)

  def __add__(lhs, rhs):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, Function):
      return rhs._addconst(lhs)
    elif isinstance(lhs, Function) and isinstance(rhs, (int, float, complex)):
      return lhs._addconst(rhs)

  def __truediv__(lhs, rhs):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, Function):
      return rhs._ldivconst(lhs)
    elif isinstance(lhs, Function) and isinstance(rhs, (int, float, complex)):
      return lhs._divconst(rhs)

  def __sub__(lhs, rhs):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, Function):
      return rhs._lsubconst(lhs)
    elif isinstance(lhs, Function) and isinstance(rhs, (int, float, complex)):
      return lhs._subconst(rhs)
