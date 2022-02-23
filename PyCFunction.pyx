# distutils: language = c++
from libcpp.string cimport string
from libcpp cimport bool as cbool
from libc.math cimport M_PI, M_E
import numpy as np
cimport numpy as np
cimport cython
np.import_array()

ctypedef double REAL
ctypedef np.complex128_t COMPLEX

cdef extern from "CFunction.cpp" nogil:
  pass

cdef extern from "CComparison.cpp" nogil:
  pass

cdef extern from "Latex.cpp" nogil:
  pass

cdef extern from "CComparison.h" namespace "libcalculus" nogil:
  cdef cppclass CComparison[Dom, Ran]:
    cbool eval(Dom z) except +
    CComparison[Dom, Ran] operator~() except +
    CComparison[Dom, Ran] operator|(CComparison[Dom, Ran] &rhs) except +
    CComparison[Dom, Ran] operator&(CComparison[Dom, Ran] &rhs) except +

cdef extern from "CFunction.h" namespace "libcalculus" nogil:
  cdef cppclass CFunction[Dom, Ran]:
    CFunction() except +
    Ran operator()(Dom z) except +
    string latex(string &varname) except +

    # Function composition
    CFunction[Predom, Ran] compose[Predom](CFunction[Predom, Dom] &rhs) except +

    # In-place function-with-function operators
    CFunction[Dom, Ran] &operator+=(CFunction[Dom, Ran] &rhs) except +
    CFunction[Dom, Ran] &operator-=(CFunction[Dom, Ran] &rhs) except +
    CFunction[Dom, Ran] &operator*=(CFunction[Dom, Ran] &rhs) except +
    CFunction[Dom, Ran] &operator/=(CFunction[Dom, Ran] &rhs) except +

    # In-place function-with-constant operators
    CFunction[Dom, Ran] &operator+=(Ran c) except +
    CFunction[Dom, Ran] &operator-=(Ran c) except +
    CFunction[Dom, Ran] &operator*=(Ran c) except +
    CFunction[Dom, Ran] &operator/=(Ran c) except +

    # Function additive inverse
    CFunction[Dom, Ran] operator-() except +

    # Function-with-function operators
    CFunction[Dom, Ran] operator+(CFunction[Dom, Ran] &rhs) except +
    CFunction[Dom, Ran] operator-(CFunction[Dom, Ran] &rhs) except +
    CFunction[Dom, Ran] operator*(CFunction[Dom, Ran] &rhs) except +
    CFunction[Dom, Ran] operator/(CFunction[Dom, Ran] &rhs) except +
    CFunction[Dom, Ran] pow(CFunction[Dom, Ran] &rhs) except +

    # Constant powers
    CFunction[Dom, Ran] pow(Ran rhs) except +
    CFunction[Dom, Ran] lpow(Ran lhs) except +

    # Comparison operators
    CComparison[Dom, Ran] operator>(CFunction[Dom, Ran] &rhs) except +
    CComparison[Dom, Ran] operator<(CFunction[Dom, Ran] &rhs) except +
    CComparison[Dom, Ran] operator==(CFunction[Dom, Ran] &rhs) except +
    CComparison[Dom, Ran] operator>=(CFunction[Dom, Ran] &rhs) except +
    CComparison[Dom, Ran] operator<=(CFunction[Dom, Ran] &rhs) except +
    CComparison[Dom, Ran] operator!=(CFunction[Dom, Ran] &rhs) except +

    # Preset instances
    @staticmethod
    CFunction[Dom, Ran] Constant(Ran c) except +
    @staticmethod
    CFunction[Dom, Ran] Re() except +
    @staticmethod
    CFunction[Dom, Ran] Im() except +
    @staticmethod
    CFunction[Dom, Ran] Abs() except +
    @staticmethod
    CFunction[Dom, Ran] Exp() except +
    @staticmethod
    CFunction[Dom, Ran] Sin() except +
    @staticmethod
    CFunction[Dom, Ran] Cos() except +
    @staticmethod
    CFunction[Dom, Ran] Tan() except +
    @staticmethod
    CFunction[Dom, Ran] Sec() except +
    @staticmethod
    CFunction[Dom, Ran] Csc() except +
    @staticmethod
    CFunction[Dom, Ran] Cot() except +
    @staticmethod
    CFunction[Dom, Ran] Pi() except +
    @staticmethod
    CFunction[Dom, Ran] E() except +
    @staticmethod
    CFunction[Dom, Ran] If(CComparison[Dom, Ran] &cond_, CFunction[Dom, Ran] &then_, CFunction[Dom, Ran] &else_) except +

  # Constant-with-function operators
  CFunction[COMPLEX, COMPLEX] csubC "operator-"(COMPLEX lhs, CFunction[COMPLEX, COMPLEX] &rhs) except +
  CFunction[COMPLEX, COMPLEX] cdivC "operator/"(COMPLEX lhs, CFunction[COMPLEX, COMPLEX] &rhs) except +
  CFunction[REAL, COMPLEX] rsubC "operator-"(COMPLEX lhs, CFunction[REAL, COMPLEX] &rhs) except +
  CFunction[REAL, COMPLEX] rdivC "operator/"(COMPLEX lhs, CFunction[REAL, COMPLEX] &rhs) except +
  CFunction[REAL, REAL] rsubR "operator-"(REAL lhs, CFunction[REAL, REAL] &rhs) except +
  CFunction[REAL, REAL] rdivR "operator/"(REAL lhs, CFunction[REAL, REAL] &rhs) except +


cdef class RealComparison:
  cdef CComparison[REAL, REAL] ccomparison

  def __call__(RealComparison self, REAL x):
    return self.ccomparison.eval(x)

  def __invert__(RealComparison self):
    cdef RealComparison result = RealComparison()
    result.ccomparison = ~self.ccomparison
    return result

  def __or__(RealComparison lhs, RealComparison rhs):
    cdef RealComparison result = RealComparison()
    result.ccomparison = lhs.ccomparison | rhs.ccomparison
    return result

  def __and__(RealComparison lhs, RealComparison rhs):
    cdef RealComparison result = RealComparison()
    result.ccomparison = lhs.ccomparison & rhs.ccomparison
    return result

cdef class ComplexComparison:
  cdef CComparison[COMPLEX, COMPLEX] ccomparison

  def __call__(ComplexComparison self, COMPLEX z):
    return self.ccomparison.eval(z)

  def __invert__(ComplexComparison self):
    cdef ComplexComparison result = ComplexComparison()
    result.ccomparison = ~self.ccomparison
    return result

  def __or__(ComplexComparison lhs, ComplexComparison rhs):
    cdef ComplexComparison result = ComplexComparison()
    result.ccomparison = lhs.ccomparison | rhs.ccomparison
    return result

  def __and__(ComplexComparison lhs, ComplexComparison rhs):
    cdef ComplexComparison result = ComplexComparison()
    result.ccomparison = lhs.ccomparison & rhs.ccomparison
    return result

cdef class ComplexFunction:
  cdef CFunction[COMPLEX, COMPLEX] cfunction

  @cython.boundscheck(False)
  @cython.wraparound(False)
  cdef _call_array(ComplexFunction self, np.ndarray[const COMPLEX] z):
    cdef np.ndarray[COMPLEX] result = np.zeros(z.shape[0], dtype=complex)
    for i in range(z.shape[0]):
      result[i] = self.cfunction(z[i])
    return result

  def __call__(ComplexFunction self, z):
    if isinstance(z, (int, float, complex)):
      return self.cfunction(z)
    elif isinstance(z, np.ndarray) and np.issubdtype(z.dtype, np.number):
      result = self._call_array(np.asarray(z.flatten(), dtype=complex))
      return result.reshape(z.shape)
    else:
      raise NotImplementedError

  def latex(ComplexFunction self, str varname="z"):
    return self.cfunction.latex(varname.encode()).decode()

  def _compose(ComplexFunction self, ComplexFunction rhs):
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = self.cfunction.compose[COMPLEX](rhs.cfunction)
    return F

  def _compose_contour(ComplexFunction self, Contour rhs):
    cdef Contour F = Contour((<Contour>rhs)._start, (<Contour>rhs)._end)
    F.cfunction = self.cfunction.compose[REAL](rhs.cfunction)
    return F

  def __neg__(ComplexFunction self):
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = -self.cfunction
    return F

  def __iadd__(ComplexFunction lhs, rhs):
    if isinstance(rhs, ComplexFunction):
      lhs.cfunction += (<ComplexFunction>rhs).cfunction
      return lhs
    elif isinstance(rhs, (int, float, complex)):
      lhs.cfunction += <COMPLEX>rhs
      return lhs

  def __isub__(ComplexFunction lhs, rhs):
    if isinstance(rhs, ComplexFunction):
      lhs.cfunction -= (<ComplexFunction>rhs).cfunction
      return lhs
    elif isinstance(rhs, (int, float, complex)):
      lhs.cfunction -= <COMPLEX>rhs
      return lhs

  def __imul__(ComplexFunction lhs, rhs):
    if isinstance(rhs, ComplexFunction):
      lhs.cfunction *= (<ComplexFunction>rhs).cfunction
      return lhs
    elif isinstance(rhs, (int, float, complex)):
      lhs.cfunction *= <COMPLEX>rhs
      return lhs

  def __itruediv__(ComplexFunction lhs, rhs):
    if isinstance(rhs, ComplexFunction):
      lhs.cfunction /= (<ComplexFunction>rhs).cfunction
      return lhs
    elif isinstance(rhs, (int, float, complex)):
      lhs.cfunction /= <COMPLEX>rhs
      return lhs

  def __add__(lhs, rhs):
    cdef ComplexFunction result = ComplexFunction()
    if isinstance(lhs, ComplexFunction) and isinstance(rhs, (ComplexFunction, int, float, complex)):
      result.cfunction = (<ComplexFunction>lhs).cfunction
      result += rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, ComplexFunction):
      result.cfunction = (<ComplexFunction>rhs).cfunction
      result += lhs
    else:
      raise NotImplementedError
    return result

  def __sub__(lhs, rhs):
    cdef ComplexFunction result = ComplexFunction()
    if isinstance(lhs, ComplexFunction) and isinstance(rhs, (ComplexFunction, int, float, complex)):
      result.cfunction = (<ComplexFunction>lhs).cfunction
      result -= rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, ComplexFunction):
      result.cfunction = csubC(<COMPLEX>lhs, (<ComplexFunction>rhs).cfunction) # FIX!!
    else:
      raise NotImplementedError
    return result

  def __mul__(lhs, rhs):
    cdef ComplexFunction result = ComplexFunction()
    if isinstance(lhs, ComplexFunction) and isinstance(rhs, (ComplexFunction, int, float, complex)):
      result.cfunction = (<ComplexFunction>lhs).cfunction
      result *= rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, ComplexFunction):
      result.cfunction = (<ComplexFunction>rhs).cfunction
      result *= lhs
    else:
      raise NotImplementedError
    return result

  def __truediv__(lhs, rhs):
    cdef ComplexFunction result = ComplexFunction()
    if isinstance(lhs, ComplexFunction) and isinstance(rhs, (ComplexFunction, int, float, complex)):
      result.cfunction = (<ComplexFunction>lhs).cfunction
      result /= rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, ComplexFunction):
      result.cfunction = cdivC(<COMPLEX>lhs, (<ComplexFunction>rhs).cfunction)
    else:
      raise NotImplementedError
    return result

  def __pow__(lhs, rhs, mod):
    cdef ComplexFunction result = ComplexFunction()
    if isinstance(lhs, ComplexFunction) and isinstance(rhs, ComplexFunction):
      result.cfunction = (<ComplexFunction>lhs).cfunction.pow((<ComplexFunction>rhs).cfunction)
    elif isinstance(lhs, ComplexFunction) and isinstance(rhs, (int, float, complex)):
      result.cfunction = (<ComplexFunction>lhs).cfunction.pow(<COMPLEX>rhs)
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, ComplexFunction):
      result.cfunction = (<ComplexFunction>rhs).cfunction.lpow(<COMPLEX>lhs)
    else:
      raise NotImplementedError
    return result

  def __matmul__(lhs, rhs):
    if isinstance(lhs, ComplexFunction) and isinstance(rhs, ComplexFunction):
      return lhs._compose(rhs)
    if isinstance(lhs, ComplexFunction) and isinstance(rhs, Contour):
      return lhs._compose_contour(rhs)
    else:
      raise NotImplementedError

  def __eq__(lhs, rhs):
    cdef ComplexComparison result = ComplexComparison()
    if isinstance(lhs, ComplexFunction) and isinstance(rhs, ComplexFunction):
      result.ccomparison = (<ComplexFunction>lhs).cfunction == (<ComplexFunction>rhs).cfunction
      return result
    elif isinstance(lhs, ComplexFunction) and isinstance(rhs, (int, float, complex)):
      result.ccomparison = (<ComplexFunction>lhs).cfunction == CFunction[COMPLEX, COMPLEX].Constant(<COMPLEX>rhs)
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, ComplexFunction):
      result.ccomparison = CFunction[COMPLEX, COMPLEX].Constant(<COMPLEX>lhs) == (<ComplexFunction>rhs).cfunction
    else:
      raise NotImplementedError
    return result



  def __ne__(lhs, rhs):
    cdef ComplexComparison result = ComplexComparison()
    if isinstance(lhs, ComplexFunction) and isinstance(rhs, ComplexFunction):
      result.ccomparison = (<ComplexFunction>lhs).cfunction != (<ComplexFunction>rhs).cfunction
      return result
    elif isinstance(lhs, ComplexFunction) and isinstance(rhs, (int, float, complex)):
      result.ccomparison = (<ComplexFunction>lhs).cfunction != CFunction[COMPLEX, COMPLEX].Constant(<COMPLEX>rhs)
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, ComplexFunction):
      result.ccomparison = CFunction[COMPLEX, COMPLEX].Constant(<COMPLEX>lhs) != (<ComplexFunction>rhs).cfunction
    else:
      raise NotImplementedError
    return result

  @staticmethod
  def Constant(COMPLEX c):
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Constant(c)
    return F

  @staticmethod
  def Re():
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Re()
    return F

  @staticmethod
  def Im():
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Im()
    return F

  @staticmethod
  def Abs():
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Abs()
    return F

  @staticmethod
  def Identity():
    return ComplexFunction()

  @staticmethod
  def Exp():
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Exp()
    return F

  @staticmethod
  def Sin():
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Sin()
    return F

  @staticmethod
  def Cos():
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Cos()
    return F

  @staticmethod
  def Tan():
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Tan()
    return F

  @staticmethod
  def Sec():
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Sec()
    return F

  @staticmethod
  def Csc():
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Csc()
    return F

  @staticmethod
  def Cot():
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Cot()
    return F

  @staticmethod
  def Pi():
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Pi()
    return F

  @staticmethod
  def E():
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].E()
    return F

cdef class Contour:
  cdef CFunction[REAL, COMPLEX] cfunction
  cdef REAL _start, _end

  def __cinit__(Contour self, const REAL start=0., const REAL end=1.):
    self._start = start
    self._end = end

  @cython.boundscheck(False)
  @cython.wraparound(False)
  cdef _call_array(Contour self, np.ndarray[const REAL] t):
    cdef np.ndarray[COMPLEX] result = np.zeros(t.shape[0], dtype=complex)
    for i in range(t.shape[0]):
      result[i] = self.cfunction(t[i])
    return result

  def __call__(Contour self, t):
    if isinstance(t, (int, float, complex)):
      return self.cfunction(t)
    elif isinstance(t, np.ndarray) and np.issubdtype(t.dtype, np.number):
      result = self._call_array(np.asarray(t.flatten(), dtype=np.double))
      return result.reshape(t.shape)
    else:
      raise NotImplementedError

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
    return self.cfunction.latex(varname.encode()).decode()

  def _compose_real(Contour self, RealFunction rhs):
    cdef Contour F = Contour(self._start, self._end)
    F.cfunction = self.cfunction.compose[REAL](rhs.cfunction)
    return F

  def __neg__(Contour self):
    cdef Contour F = Contour(self._start, self._end)
    F.cfunction = -self.cfunction
    return F

  def __invert__(Contour self):
    cdef Contour F = Contour(self._end, self._start)
    F.cfunction = self.cfunction
    return F

  def __iadd__(Contour lhs, rhs):
    if isinstance(rhs, Contour):
      lhs.cfunction += (<Contour>rhs).cfunction
      return lhs
    elif isinstance(rhs, (int, float, complex)):
      lhs.cfunction += <COMPLEX>rhs
      return lhs

  def __isub__(Contour lhs, rhs):
    if isinstance(rhs, Contour):
      lhs.cfunction -= (<Contour>rhs).cfunction
      return lhs
    elif isinstance(rhs, (int, float, complex)):
      lhs.cfunction -= <COMPLEX>rhs
      return lhs

  def __imul__(Contour lhs, rhs):
    if isinstance(rhs, Contour):
      lhs.cfunction *= (<Contour>rhs).cfunction
      return lhs
    elif isinstance(rhs, (int, float, complex)):
      lhs.cfunction *= <COMPLEX>rhs
      return lhs

  def __itruediv__(Contour lhs, rhs):
    if isinstance(rhs, Contour):
      lhs.cfunction /= (<Contour>rhs).cfunction
      return lhs
    elif isinstance(rhs, (int, float, complex)):
      lhs.cfunction /= <COMPLEX>rhs
      return lhs

  def __add__(lhs, rhs):
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
      raise NotImplementedError
    return result

  def __sub__(lhs, rhs):
    cdef Contour result
    if isinstance(lhs, Contour) and isinstance(rhs, (Contour, int, float, complex)):
      result = Contour((<Contour>lhs)._start, (<Contour>lhs)._end)
      result.cfunction = (<Contour>lhs).cfunction
      result -= rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      result = Contour((<Contour>rhs)._start, (<Contour>rhs)._end)
      result.cfunction = rsubC(<COMPLEX>lhs, (<Contour>rhs).cfunction)
    else:
      raise NotImplementedError
    return result

  def __mul__(lhs, rhs):
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
      raise NotImplementedError
    return result

  def __truediv__(lhs, rhs):
    cdef Contour result
    if isinstance(lhs, Contour) and isinstance(rhs, (Contour, int, float, complex)):
      result = Contour((<Contour>lhs)._start, (<Contour>lhs)._end)
      result.cfunction = (<Contour>lhs).cfunction
      result /= rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      result = Contour((<Contour>rhs)._start, (<Contour>rhs)._end)
      result.cfunction = rdivC(<COMPLEX>lhs, (<Contour>rhs).cfunction)
    else:
      raise NotImplementedError
    return result

  def __pow__(lhs, rhs, mod):
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
      raise NotImplementedError
    return result

  def __matmul__(lhs, rhs):
    if isinstance(lhs, Contour) and isinstance(rhs, RealFunction):
      return lhs._compose_real(rhs)
    else:
      raise NotImplementedError

  @staticmethod
  def Constant(COMPLEX c):
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Constant(c)
    return F

  @staticmethod
  def Abs():
    cdef Contour F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Abs()
    return F

  @staticmethod
  def Identity(start=0., end=1.):
    return Contour(start, end)

  @staticmethod
  def Exp(start=0., end=1.):
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Exp()
    return F

  @staticmethod
  def Sin(start=0., end=1.):
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Sin()
    return F

  @staticmethod
  def Cos(start=0., end=1.):
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Cos()
    return F

  @staticmethod
  def Tan(start=0., end=1.):
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Tan()
    return F

  @staticmethod
  def Sec(start=0., end=1.):
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Sec()
    return F

  @staticmethod
  def Csc(start=0., end=1.):
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Csc()
    return F

  @staticmethod
  def Cot(start=0., end=1.):
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Cot()
    return F

  @staticmethod
  def Pi(start=0., end=1.):
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Pi()
    return F

  @staticmethod
  def E(start=0., end=1.):
    cdef Contour F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].E()
    return F

  @staticmethod
  def Sphere(complex center=0., REAL radius=1., ccw=False):
    return center + (-1. if ccw else 1.) * radius * (ComplexFunction.Exp() @ (1j * Contour.Identity(0., 2. * M_PI)))



cdef class RealFunction:
  cdef CFunction[REAL, REAL] cfunction

  @cython.boundscheck(False)
  @cython.wraparound(False)
  cdef _call_array(RealFunction self, np.ndarray[const REAL] t):
    cdef np.ndarray[REAL] result = np.zeros(t.shape[0], dtype=np.double)
    for i in range(t.shape[0]):
      result[i] = self.cfunction(t[i])
    return result

  def __call__(RealFunction self, t):
    if isinstance(t, (int, float, complex)):
      return self.cfunction(t)
    elif isinstance(t, np.ndarray) and np.issubdtype(t.dtype, np.number):
      result = self._call_array(np.asarray(t.flatten(), dtype=np.double))
      return result.reshape(t.shape)
    else:
      raise NotImplementedError

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

  def __iadd__(RealFunction lhs, rhs):
    if isinstance(rhs, RealFunction):
      lhs.cfunction += (<RealFunction>rhs).cfunction
      return lhs
    elif isinstance(rhs, (int, float, complex)):
      lhs.cfunction += <REAL>rhs
      return lhs

  def __isub__(RealFunction lhs, rhs):
    if isinstance(rhs, RealFunction):
      lhs.cfunction -= (<RealFunction>rhs).cfunction
      return lhs
    elif isinstance(rhs, (int, float, complex)):
      lhs.cfunction -= <REAL>rhs
      return lhs

  def __imul__(RealFunction lhs, rhs):
    if isinstance(rhs, RealFunction):
      lhs.cfunction *= (<RealFunction>rhs).cfunction
      return lhs
    elif isinstance(rhs, (int, float, complex)):
      lhs.cfunction *= <REAL>rhs
      return lhs

  def __itruediv__(RealFunction lhs, rhs):
    if isinstance(rhs, RealFunction):
      lhs.cfunction /= (<RealFunction>rhs).cfunction
      return lhs
    elif isinstance(rhs, (int, float, complex)):
      lhs.cfunction /= <REAL>rhs
      return lhs

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
      raise NotImplementedError
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
      raise NotImplementedError
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
      raise NotImplementedError
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
      raise NotImplementedError
    return result

  def __matmul__(lhs, rhs):
    if isinstance(lhs, RealFunction) and isinstance(rhs, RealFunction):
      return lhs._compose(rhs)
    else:
      raise NotImplementedError

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
      raise NotImplementedError
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
      raise NotImplementedError
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
      raise NotImplementedError
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
      raise NotImplementedError
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
      raise NotImplementedError
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
  def Constant(REAL c):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Constant(c)
    return F

  @staticmethod
  def Abs():
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Abs()
    return F

  @staticmethod
  def Identity(start=0., end=1.):
    return RealFunction()

  @staticmethod
  def Exp(start=0., end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Exp()
    return F

  @staticmethod
  def Sin(start=0., end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Sin()
    return F

  @staticmethod
  def Cos(start=0., end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Cos()
    return F

  @staticmethod
  def Tan(start=0., end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Tan()
    return F

  @staticmethod
  def Sec(start=0., end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Sec()
    return F

  @staticmethod
  def Csc(start=0., end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Csc()
    return F

  @staticmethod
  def Cot(start=0., end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Cot()
    return F

  @staticmethod
  def Pi(start=0., end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].Pi()
    return F

  @staticmethod
  def E(start=0., end=1.):
    cdef RealFunction F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].E()
    return F

  @staticmethod
  def If(RealComparison comp_, RealFunction then_, RealFunction else_=RealFunction.Constant(0)):
    F = RealFunction()
    F.cfunction = CFunction[REAL, REAL].If(comp_.ccomparison, then_.cfunction, else_.cfunction)
    return F
