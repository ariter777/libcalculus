# distutils: language = c++
from Definitions cimport *
import os
cimport openmp

cdef class _Globals:
  cdef size_t NUM_THREADS

  def __cinit__(_Globals self):
    self.NUM_THREADS = int(os.environ.get("OMP_NUM_THREADS", 1))

cdef _Globals Globals = _Globals()

def threads(const size_t n=0):
  """Get or set the number of threads available for the library to use."""
  if n == 0:
    return Globals.NUM_THREADS
  else:
    Globals.NUM_THREADS = n
    openmp.omp_set_num_threads(n)
    return n

include "CCalculus.pyx"

include "RealComparison.pyx"
include "ComplexComparison.pyx"
include "Comparison.pyx"

include "ComplexFunction.pyx"
include "Contour.pyx"
include "RealFunction.pyx"

include "Function.pyx"


def constant(c):
  if _isrealscalar(c):
    return Function(RealFunction.Constant(<REAL>c), Contour.Constant(<COMPLEX>c), ComplexFunction.Constant(<COMPLEX>c))
  elif _iscomplexscalar(c):
    return Function(None, Contour.Constant(<COMPLEX>c), ComplexFunction.Constant(<COMPLEX>c))
  else:
    raise NotImplementedError(f"Type {type(c)} not supported.")

# Basic functions
id = Function(RealFunction.Identity(), Contour.Identity(), ComplexFunction.Identity())
real = Function(RealFunction.Identity(), Contour.Identity(), ComplexFunction.Re())
imag = Function(RealFunction.Identity(), Contour.Identity(), ComplexFunction.Im())
abs = Function(RealFunction.Abs(), Contour.Abs(), ComplexFunction.Abs())
conj = Function(RealFunction.Identity(), Contour.Identity(), ComplexFunction.Conj())
exp = Function(RealFunction.Exp(), Contour.Exp(), ComplexFunction.Exp())

# Trigonometric functions
sin = Function(RealFunction.Sin(), Contour.Sin(), ComplexFunction.Sin())
cos = Function(RealFunction.Cos(), Contour.Cos(), ComplexFunction.Cos())
tan = Function(RealFunction.Tan(), Contour.Tan(), ComplexFunction.Tan())
csc = Function(RealFunction.Csc(), Contour.Csc(), ComplexFunction.Csc())
sec = Function(RealFunction.Sec(), Contour.Sec(), ComplexFunction.Sec())
cot = Function(RealFunction.Cot(), Contour.Cot(), ComplexFunction.Cot())

# Hyperbolic functions
sinh = Function(RealFunction.Sinh(), Contour.Sinh(), ComplexFunction.Sinh())
cosh = Function(RealFunction.Cosh(), Contour.Cosh(), ComplexFunction.Cosh())
tanh = Function(RealFunction.Tanh(), Contour.Tanh(), ComplexFunction.Tanh())
csch = Function(RealFunction.Csch(), Contour.Csch(), ComplexFunction.Csch())
sech = Function(RealFunction.Sech(), Contour.Sech(), ComplexFunction.Sech())
coth = Function(RealFunction.Coth(), Contour.Coth(), ComplexFunction.Coth())

# Constants
pi = Function(RealFunction.Pi(), Contour.Pi(), ComplexFunction.Pi())
e = Function(RealFunction.E(), Contour.E(), ComplexFunction.E())

# Piecewise functions
def piecewise(Comparison comp_, Function then_ not None, Function else_=constant(0)):
  return Function(RealFunction.If(comp_.realcomparison, then_.realfunction, else_.realfunction) \
                    if comp_.realcomparison is not None and then_.realfunction is not None and else_.realfunction is not None else None,
                  Contour.If(comp_.complexcomparison, then_.contour, else_.contour) \
                    if comp_.complexcomparison is not None and then_.contour is not None and else_.contour is not None else None,
                  ComplexFunction.If(comp_.complexcomparison, then_.complexfunction, else_.complexfunction) \
                    if comp_.complexcomparison is not None and then_.complexfunction is not None and else_.complexfunction is not None else None)
