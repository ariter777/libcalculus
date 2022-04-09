# distutils: language = c++
from Definitions cimport *
import sys, os
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

include "RealComparison.pyx"
include "ComplexComparison.pyx"
include "Comparison.pyx"

include "ComplexFunction.pyx"
include "Contour.pyx"
include "RealFunction.pyx"
include "Function.pyx"

include "CCalculus.pyx"


def constant(c):
  if _isrealscalar(c):
    return Function(RealFunction.Constant(<REAL>c), Contour.Constant(<COMPLEX>c), ComplexFunction.Constant(<COMPLEX>c))
  elif _iscomplexscalar(c):
    return Function(None, Contour.Constant(<COMPLEX>c), ComplexFunction.Constant(<COMPLEX>c))
  else:
    raise NotImplementedError(f"Type {type(c)} not supported.")

def __setattr__(name):
  raise AttributeError(f"cannot set attribute {name} in module {__name__}")

def __getattr__(name):
  if name in sys.modules[__name__].__dict__:
    return sys.modules[__name__].__dict__[name]
  # Basic functions
  elif name == "identity":
    return Function(RealFunction.Identity(), Contour.Identity(), ComplexFunction.Identity())
  elif name == "real":
    return Function(RealFunction.Identity(), Contour.Identity(), ComplexFunction.Re())
  elif name == "imag":
    return Function(RealFunction.Identity(), Contour.Identity(), ComplexFunction.Im())
  elif name == "abs":
    return Function(RealFunction.Abs(), Contour.Abs(), ComplexFunction.Abs())
  elif name == "conj":
    return Function(RealFunction.Identity(), Contour.Identity(), ComplexFunction.Conj())
  elif name == "exp":
    return Function(RealFunction.Exp(), Contour.Exp(), ComplexFunction.Exp())

  # Trigonometric functions
  elif name == "sin":
    return Function(RealFunction.Sin(), Contour.Sin(), ComplexFunction.Sin())
  elif name == "cos":
    return Function(RealFunction.Cos(), Contour.Cos(), ComplexFunction.Cos())
  elif name == "tan":
    return Function(RealFunction.Tan(), Contour.Tan(), ComplexFunction.Tan())
  elif name == "csc":
    return Function(RealFunction.Csc(), Contour.Csc(), ComplexFunction.Csc())
  elif name == "sec":
    return Function(RealFunction.Sec(), Contour.Sec(), ComplexFunction.Sec())
  elif name == "cot":
    return Function(RealFunction.Cot(), Contour.Cot(), ComplexFunction.Cot())

  # Hyperbolic functions
  elif name == "sinh":
    return Function(RealFunction.Sinh(), Contour.Sinh(), ComplexFunction.Sinh())
  elif name == "cosh":
    return Function(RealFunction.Cosh(), Contour.Cosh(), ComplexFunction.Cosh())
  elif name == "tanh":
    return Function(RealFunction.Tanh(), Contour.Tanh(), ComplexFunction.Tanh())
  elif name == "csch":
    return Function(RealFunction.Csch(), Contour.Csch(), ComplexFunction.Csch())
  elif name == "sech":
    return Function(RealFunction.Sech(), Contour.Sech(), ComplexFunction.Sech())
  elif name == "coth":
    return Function(RealFunction.Coth(), Contour.Coth(), ComplexFunction.Coth())

  # Inverse trigonometric functions
  elif name == "arcsin":
    return Function(RealFunction.Arcsin(), Contour.Arcsin(), ComplexFunction.Arcsin())
  elif name == "arccos":
    return Function(RealFunction.Arccos(), Contour.Arccos(), ComplexFunction.Arccos())
  elif name == "arctan":
    return Function(RealFunction.Arctan(), Contour.Arctan(), ComplexFunction.Arctan())
  elif name == "arccsc":
    return Function(RealFunction.Arccsc(), Contour.Arccsc(), ComplexFunction.Arccsc())
  elif name == "arcsec":
    return Function(RealFunction.Arcsec(), Contour.Arcsec(), ComplexFunction.Arcsec())
  elif name == "arccot":
    return Function(RealFunction.Arccot(), Contour.Arccot(), ComplexFunction.Arccot())

 # Inverse hyperbolic functions
  elif name == "arsinh":
    return Function(RealFunction.Arsinh(), Contour.Arsinh(), ComplexFunction.Arsinh())
  elif name == "arcosh":
    return Function(RealFunction.Arcosh(), Contour.Arcosh(), ComplexFunction.Arcosh())
  elif name == "artanh":
    return Function(RealFunction.Artanh(), Contour.Artanh(), ComplexFunction.Artanh())
  elif name == "arcsch":
    return Function(RealFunction.Arcsch(), Contour.Arcsch(), ComplexFunction.Arcsch())
  elif name == "arsech":
    return Function(RealFunction.Arsech(), Contour.Arsech(), ComplexFunction.Arsech())
  elif name == "arcoth":
    return Function(RealFunction.Arcoth(), Contour.Arcoth(), ComplexFunction.Arcoth())

  # Constants
  elif name == "pi":
   return Function(RealFunction.Pi(), Contour.Pi(), ComplexFunction.Pi())
  elif name == "e":
   return Function(RealFunction.E(), Contour.E(), ComplexFunction.E())

  else:
   raise AttributeError(f"module {__name__} has no attribute {name}")

# Piecewise functions
def piecewise(Comparison comp_ not None, Function then_ not None, Function else_ not None=constant(0)):
  return Function(RealFunction.If(comp_.realcomparison, then_.realfunction, else_.realfunction) \
                    if comp_.realcomparison is not None and then_.realfunction is not None and else_.realfunction is not None else None,
                  Contour.If(comp_.realcomparison, then_.contour, else_.contour) \
                    if comp_.realcomparison is not None and then_.contour is not None and else_.contour is not None else None,
                  ComplexFunction.If(comp_.complexcomparison, then_.complexfunction, else_.complexfunction) \
                    if comp_.complexcomparison is not None and then_.complexfunction is not None and else_.complexfunction is not None else None)


def line(const COMPLEX z1, const COMPLEX z2):
  return Function(None,
                  Contour.Line(z1, z2),
                  None)

def sphere(const COMPLEX center=0., const REAL radius=1.):
  return Function(None,
                  center + radius * (ComplexFunction.Exp() @ (2j * Contour.Pi() * Contour.Identity())),
                  None)
