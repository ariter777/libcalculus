# distutils: language = c++
from libcpp.complex cimport complex as complex_t
from libcpp.string cimport string
from libc.math cimport M_PI, M_E

ctypedef double REAL
ctypedef complex_t[REAL] COMPLEX

cdef extern from "CFunction.cpp":
  pass

cdef extern from "Latex.cpp":
  pass

cdef extern from "CFunction.h" namespace "libcalculus":
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

    @staticmethod
    CFunction[Dom, Ran] Constant(Ran c) except +
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


  # Function-with-constant operators
  CFunction[Dom, Ran] operator+[Dom, Ran](CFunction[Dom, Ran] &lhs, Ran rhs) except +
  CFunction[Dom, Ran] operator-[Dom, Ran](CFunction[Dom, Ran] &lhs, Ran rhs) except +
  CFunction[Dom, Ran] operator*[Dom, Ran](CFunction[Dom, Ran] &lhs, Ran rhs) except +
  CFunction[Dom, Ran] operator/[Dom, Ran](CFunction[Dom, Ran] &lhs, Ran rhs) except +

  # Constant-with-function operators
  CFunction[Dom, Ran] operator-[Dom, Ran](Ran lhs, CFunction[Dom, Ran] &rhs) except +
  CFunction[Dom, Ran] operator/[Dom, Ran](Ran lhs, CFunction[Dom, Ran] &rhs) except +


cdef class ComplexFunction:
  cdef CFunction[COMPLEX, COMPLEX] cfunction

  def __cinit__(self):
    pass

  def __call__(self, COMPLEX z):
    return self.cfunction(z)

  def latex(self, str varname = "z"):
    return self.cfunction.latex(varname.encode()).decode()

  def _add(self, ComplexFunction rhs):
    F = ComplexFunction()
    F.cfunction = self.cfunction + rhs.cfunction
    return F

  def _sub(self, ComplexFunction rhs):
    F = ComplexFunction()
    F.cfunction = self.cfunction - rhs.cfunction
    return F

  def _mul(self, ComplexFunction rhs):
    F = ComplexFunction()
    F.cfunction = self.cfunction * rhs.cfunction
    return F

  def _div(self, ComplexFunction rhs):
    F = ComplexFunction()
    F.cfunction = self.cfunction / rhs.cfunction
    return F

  def _pow(self, ComplexFunction rhs):
    F = ComplexFunction()
    F.cfunction = self.cfunction.pow(rhs.cfunction)
    return F

  def _compose(self, ComplexFunction rhs):
    F = ComplexFunction()
    F.cfunction = self.cfunction.compose[COMPLEX](rhs.cfunction)
    return F

  def _compose_contour(self, Contour rhs):
    F = Contour(rhs._start, rhs._end)
    F.cfunction = self.cfunction.compose[REAL](rhs.cfunction)
    return F

  def __neg__(self):
    F = ComplexFunction()
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
      result.cfunction = (<ComplexFunction>rhs).cfunction # FIX!!
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
      result.cfunction = <COMPLEX>lhs / (<ComplexFunction>rhs).cfunction
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

  @staticmethod
  def Constant(COMPLEX c):
    F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Constant(c)
    return F

  @staticmethod
  def Identity():
    return ComplexFunction()

  @staticmethod
  def Exp():
    F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Exp()
    return F

  @staticmethod
  def Sin():
    F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Sin()
    return F

  @staticmethod
  def Cos():
    F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Cos()
    return F

  @staticmethod
  def Tan():
    F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Tan()
    return F

  @staticmethod
  def Sec():
    F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Sec()
    return F

  @staticmethod
  def Csc():
    F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Csc()
    return F

  @staticmethod
  def Cot():
    F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Cot()
    return F

  @staticmethod
  def Pi():
    F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].Pi()
    return F

  @staticmethod
  def E():
    F = ComplexFunction()
    F.cfunction = CFunction[COMPLEX, COMPLEX].E()
    return F

cdef class Contour:
  cdef CFunction[REAL, COMPLEX] cfunction
  cdef REAL _start, _end

  def __cinit__(self, start=0., end=1.):
    self._start = start
    self._end = end

  def __call__(self, REAL t):
    return self.cfunction(t)

  @property
  def start(self):
    return self._start

  @property
  def end(self):
    return self._end

  def latex(self, str varname = "t"):
    return self.cfunction.latex(varname.encode()).decode()

  def __neg__(self):
    F = Contour(self._start, self._end)
    F.cfunction = -self.cfunction
    return F

  def __invert__(self):
    F = Contour(self._end, self._start)
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
    if isinstance(lhs, Contour) and isinstance(rhs, (Contour, int, float, complex)):
      result = Contour(lhs._start, lhs._start)
      result.cfunction = lhs.cfunction
      result += rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      result = Contour(rhs._start, rhs._start)
      result.cfunction = rhs.cfunction
      result += lhs
    else:
      raise NotImplementedError
    return result

  def __sub__(lhs, rhs):
    if isinstance(lhs, Contour) and isinstance(rhs, (Contour, int, float, complex)):
      result = Contour(lhs._start, lhs._start)
      result.cfunction = lhs.cfunction
      result -= rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      result = Contour(rhs._start, rhs._start)
      result.cfunction = <COMPLEX>lhs - rhs.cfunction
    else:
      raise NotImplementedError
    return result

  def __mul__(lhs, rhs):
    if isinstance(lhs, Contour) and isinstance(rhs, (Contour, int, float, complex)):
      result = Contour(lhs._start, lhs._start)
      result.cfunction = lhs.cfunction
      result *= rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      result = Contour(rhs._start, rhs._start)
      result.cfunction = rhs.cfunction
      result *= lhs
    else:
      raise NotImplementedError
    return result

  def __truediv__(lhs, rhs):
    if isinstance(lhs, Contour) and isinstance(rhs, (Contour, int, float, complex)):
      result = Contour(lhs._start, lhs._start)
      result.cfunction = lhs.cfunction
      result /= rhs
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      result = Contour(rhs._start, rhs._start)
      result.cfunction = <COMPLEX>lhs / rhs.cfunction
    else:
      raise NotImplementedError
    return result

  def __pow__(lhs, rhs, mod):
    if isinstance(lhs, Contour) and isinstance(rhs, Contour):
      result = Contour(lhs._start, lhs._start)
      result.cfunction = (<Contour>lhs).cfunction.pow((<Contour>rhs).cfunction)
    elif isinstance(lhs, Contour) and isinstance(rhs, (int, float, complex)):
      result = Contour(lhs._start, lhs._start)
      result.cfunction = (<Contour>lhs).cfunction.pow(<COMPLEX>rhs)
    elif isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      result = Contour(rhs._start, rhs._start)
      result.cfunction = (<Contour>rhs).cfunction.lpow(<COMPLEX>lhs)
    else:
      raise NotImplementedError
    return result

  def __matmul__(lhs, rhs):
    raise NotImplementedError

  @staticmethod
  def Constant(COMPLEX c):
    F = Contour()
    F.cfunction = CFunction[REAL, COMPLEX].Constant(c)
    return F

  @staticmethod
  def Identity(start=0., end=1.):
    return Contour(start, end)

  @staticmethod
  def Exp(start=0., end=1.):
    F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Exp()
    return F

  @staticmethod
  def Sin(start=0., end=1.):
    F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Sin()
    return F

  @staticmethod
  def Cos(start=0., end=1.):
    F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Cos()
    return F

  @staticmethod
  def Tan(start=0., end=1.):
    F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Tan()
    return F

  @staticmethod
  def Sec(start=0., end=1.):
    F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Sec()
    return F

  @staticmethod
  def Csc(start=0., end=1.):
    F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Csc()
    return F

  @staticmethod
  def Cot(start=0., end=1.):
    F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Cot()
    return F

  @staticmethod
  def Pi(start=0., end=1.):
    F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].Pi()
    return F

  @staticmethod
  def E(start=0., end=1.):
    F = Contour(start, end)
    F.cfunction = CFunction[REAL, COMPLEX].E()
    return F

  @staticmethod
  def Sphere(complex center=0., REAL radius=1., ccw=False):
    return center + (-1. if ccw else 1.) * radius * (ComplexFunction.Exp() @ (1j * Contour.Identity(0., 2. * M_PI)))
