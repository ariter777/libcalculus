# distutils: language = c++
from libcpp.complex cimport complex as complex_t
from libcpp.functional cimport function

cdef extern from "CFunction.cpp":
  pass

cdef extern from "CFunction.h" namespace "libcalculus":
  cdef cppclass CFunction:
    function[complex_t[double](complex_t[double])] f

    CFunction() except +
    complex_t[double] operator()(complex_t[double] z) except +

  cdef CFunction identity
  cdef CFunction mulconst(complex_t[double] a) except +

cdef class Function:
  cdef CFunction cfunction

  def __cinit__(self):
    pass

  def __call__(self, complex_t[double] z):
    return self.cfunction(z)

  @staticmethod
  def Identity():
    F = Function()
    F.cfunction = identity
    return F

  def __mul__(lhs, rhs):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, Function):
      F = Function()
      F.cfunction = mulconst(complex(lhs))
      return F
    elif isinstance(lhs, Function) and isinstance(rhs, (int, float, complex)):
      F = Function()
      F.cfunction = mulconst(complex(rhs))
      return F
