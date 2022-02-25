# distutils: language = c++
from Definitions cimport *
from CFunction cimport *
cimport cython
import numpy as np
cimport numpy as np

cdef class ComplexFunction:
  cdef CFunction[COMPLEX, COMPLEX] cfunction

  @cython.boundscheck(False)
  @cython.wraparound(False)
  cdef np.ndarray[COMPLEX] _call_array(ComplexFunction self, np.ndarray[const COMPLEX] z):
    cdef np.ndarray[COMPLEX] result = np.zeros_like(z, dtype=complex)
    for i in range(z.shape[0]):
      result[i] = self.cfunction(z[i])
    return result

  def __call__(ComplexFunction self, z):
    if isinstance(z, (int, float, complex)):
      return self.cfunction(z)
    elif isinstance(z, np.ndarray) and z.dtype == complex:
      return self._call_array(z.ravel()).reshape(z.shape)
    elif isinstance(z, np.ndarray) and np.issubdtype(z.dtype, np.number):
      return self._call_array(z.ravel().astype(complex, copy=False)).reshape(z.shape)
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
  def Constant(const COMPLEX c):
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
  def Sinh():
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Sinh()
    return F

  @staticmethod
  def Cosh():
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Cosh()
    return F

  @staticmethod
  def Tanh():
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Tanh()
    return F

  @staticmethod
  def Sech():
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Sech()
    return F

  @staticmethod
  def Csch():
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Csch()
    return F

  @staticmethod
  def Coth():
    cdef ComplexFunction F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Coth()
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

  @staticmethod
  def If(ComplexComparison comp_, ComplexFunction then_, ComplexFunction else_=ComplexFunction.Constant(0)):
    F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].If[COMPLEX](comp_.ccomparison, then_.cfunction, else_.cfunction)
    return F
