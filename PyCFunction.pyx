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

    CFunction[Predom, Ran] compose[Predom](CFunction[Predom, Dom] &rhs) except +
    CFunction[Dom, Ran] operator-() except +
    CFunction[Dom, Ran] operator+(CFunction[Dom, Ran] &rhs) except +
    CFunction[Dom, Ran] operator-(CFunction[Dom, Ran] &rhs) except +
    CFunction[Dom, Ran] operator*(CFunction[Dom, Ran] &rhs) except +
    CFunction[Dom, Ran] operator/(CFunction[Dom, Ran] &rhs) except +
    CFunction[Dom, Ran] pow(CFunction[Dom, Ran] &rhs) except +

    CFunction[Dom, Ran] mulconst(Ran a) except +
    CFunction[Dom, Ran] addconst(Ran a) except +
    CFunction[Dom, Ran] subconst(Ran a) except +
    CFunction[Dom, Ran] lsubconst(Ran a) except +
    CFunction[Dom, Ran] divconst(Ran a) except +
    CFunction[Dom, Ran] ldivconst(Ran a) except +
    CFunction[Dom, Ran] powconst(Ran a) except +
    CFunction[Dom, Ran] lpowconst(Ran a) except +

    @staticmethod
    CFunction[Dom, Ran] Exp()
    @staticmethod
    CFunction[Dom, Ran] Sin()
    @staticmethod
    CFunction[Dom, Ran] Cos()
    @staticmethod
    CFunction[Dom, Ran] Tan()
    @staticmethod
    CFunction[Dom, Ran] Sec()
    @staticmethod
    CFunction[Dom, Ran] Csc()
    @staticmethod
    CFunction[Dom, Ran] Cot()
    @staticmethod
    CFunction[Dom, Ran] Pi()
    @staticmethod
    CFunction[Dom, Ran] E()

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

  def _addconst(self, COMPLEX a):
    F = ComplexFunction()
    F.cfunction = self.cfunction.addconst(a)
    return F

  def _subconst(self, COMPLEX a):
    F = ComplexFunction()
    F.cfunction = self.cfunction.subconst(a)
    return F

  def _lsubconst(self, COMPLEX a):
    F = ComplexFunction()
    F.cfunction = self.cfunction.lsubconst(a)
    return F

  def _mulconst(self, COMPLEX a):
    F = ComplexFunction()
    F.cfunction = self.cfunction.mulconst(a)
    return F

  def _divconst(self, COMPLEX a):
    F = ComplexFunction()
    F.cfunction = self.cfunction.divconst(a)
    return F

  def _ldivconst(self, COMPLEX a):
    F = ComplexFunction()
    F.cfunction = self.cfunction.ldivconst(a)
    return F

  def _powconst(self, COMPLEX a):
    F = ComplexFunction()
    F.cfunction = self.cfunction.powconst(a)
    return F

  def _lpowconst(self, COMPLEX a):
    F = ComplexFunction()
    F.cfunction = self.cfunction.lpowconst(a)
    return F

  def __neg__(self):
    F = ComplexFunction()
    F.cfunction = -self.cfunction
    return F

  def __add__(lhs, rhs):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, ComplexFunction):
      return rhs._addconst(lhs)
    elif isinstance(lhs, ComplexFunction) and isinstance(rhs, (int, float, complex)):
      return lhs._addconst(rhs)
    elif isinstance(lhs, ComplexFunction) and isinstance(rhs, ComplexFunction):
      return lhs._add(rhs)
    else:
      raise NotImplementedError

  def __sub__(lhs, rhs):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, ComplexFunction):
      return rhs._lsubconst(lhs)
    elif isinstance(lhs, ComplexFunction) and isinstance(rhs, (int, float, complex)):
      return lhs._subconst(rhs)
    elif isinstance(lhs, ComplexFunction) and isinstance(rhs, ComplexFunction):
      return lhs._sub(rhs)
    else:
      raise NotImplementedError

  def __mul__(lhs, rhs):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, ComplexFunction):
      return rhs._mulconst(lhs)
    elif isinstance(lhs, ComplexFunction) and isinstance(rhs, (int, float, complex)):
      return lhs._mulconst(rhs)
    elif isinstance(lhs, ComplexFunction) and isinstance(rhs, ComplexFunction):
      return lhs._mul(rhs)
    else:
      raise NotImplementedError

  def __truediv__(lhs, rhs):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, ComplexFunction):
      return rhs._ldivconst(lhs)
    elif isinstance(lhs, ComplexFunction) and isinstance(rhs, (int, float, complex)):
      return lhs._divconst(rhs)
    elif isinstance(lhs, ComplexFunction) and isinstance(rhs, ComplexFunction):
      return lhs._div(rhs)
    else:
      raise NotImplementedError

  def __pow__(lhs, rhs, mod):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, ComplexFunction):
      return rhs._lpowconst(lhs)
    elif isinstance(lhs, ComplexFunction) and isinstance(rhs, (int, float, complex)):
      return lhs._powconst(rhs)
    elif isinstance(lhs, ComplexFunction) and isinstance(rhs, ComplexFunction):
      return lhs._pow(rhs)
    else:
      raise NotImplementedError

  def __matmul__(lhs, rhs):
    if isinstance(lhs, ComplexFunction) and isinstance(rhs, ComplexFunction):
      return lhs._compose(rhs)
    if isinstance(lhs, ComplexFunction) and isinstance(rhs, Contour):
      return lhs._compose_contour(rhs)
    else:
      raise NotImplementedError

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

  def _add(self, Contour rhs):
    F = Contour(rhs._start, rhs._end) # Arbitrarily chooses the bounds of the rhs Contour.
    F.cfunction = self.cfunction + rhs.cfunction
    return F

  def _sub(self, Contour rhs):
    F = Contour(rhs._start, rhs._end)
    F.cfunction = self.cfunction - rhs.cfunction
    return F

  def _mul(self, Contour rhs):
    F = Contour(rhs._start, rhs._end)
    F.cfunction = self.cfunction * rhs.cfunction
    return F

  def _div(self, Contour rhs):
    F = Contour(rhs._start, rhs._end)
    F.cfunction = self.cfunction / rhs.cfunction
    return F

  def _pow(self, Contour rhs):
    F = Contour(rhs._start, rhs._end)
    F.cfunction = self.cfunction.pow(rhs.cfunction)
    return F

  def _addconst(self, COMPLEX a):
    F = Contour(self._start, self._end)
    F.cfunction = self.cfunction.addconst(a)
    return F

  def _subconst(self, COMPLEX a):
    F = Contour(self._start, self._end)
    F.cfunction = self.cfunction.subconst(a)
    return F

  def _lsubconst(self, COMPLEX a):
    F = Contour(self._start, self._end)
    F.cfunction = self.cfunction.lsubconst(a)
    return F

  def _mulconst(self, COMPLEX a):
    F = Contour(self._start, self._end)
    F.cfunction = self.cfunction.mulconst(a)
    return F

  def _divconst(self, COMPLEX a):
    F = Contour(self._start, self._end)
    F.cfunction = self.cfunction.divconst(a)
    return F

  def _ldivconst(self, COMPLEX a):
    F = Contour(self._start, self._end)
    F.cfunction = self.cfunction.ldivconst(a)
    return F

  def _powconst(self, COMPLEX a):
    F = Contour(self._start, self._end)
    F.cfunction = self.cfunction.powconst(a)
    return F

  def _lpowconst(self, COMPLEX a):
    F = Contour(self._start, self._end)
    F.cfunction = self.cfunction.lpowconst(a)
    return F

  def __neg__(self):
    F = Contour(self._start, self._end)
    F.cfunction = -self.cfunction
    return F

  def __add__(lhs, rhs):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      return rhs._addconst(lhs)
    elif isinstance(lhs, Contour) and isinstance(rhs, (int, float, complex)):
      return lhs._addconst(rhs)
    elif isinstance(lhs, Contour) and isinstance(rhs, Contour):
      return lhs._add(rhs)
    else:
      raise NotImplementedError

  def __sub__(lhs, rhs):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      return rhs._lsubconst(lhs)
    elif isinstance(lhs, Contour) and isinstance(rhs, (int, float, complex)):
      return lhs._subconst(rhs)
    elif isinstance(lhs, Contour) and isinstance(rhs, Contour):
      return lhs._sub(rhs)
    else:
      raise NotImplementedError

  def __mul__(lhs, rhs):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      return rhs._mulconst(lhs)
    elif isinstance(lhs, Contour) and isinstance(rhs, (int, float, complex)):
      return lhs._mulconst(rhs)
    elif isinstance(lhs, Contour) and isinstance(rhs, Contour):
      return lhs._mul(rhs)
    else:
      raise NotImplementedError

  def __truediv__(lhs, rhs):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      return rhs._ldivconst(lhs)
    elif isinstance(lhs, Contour) and isinstance(rhs, (int, float, complex)):
      return lhs._divconst(rhs)
    elif isinstance(lhs, Contour) and isinstance(rhs, Contour):
      return lhs._div(rhs)
    else:
      raise NotImplementedError

  def __pow__(lhs, rhs, mod):
    if isinstance(lhs, (int, float, complex)) and isinstance(rhs, Contour):
      return rhs._lpowconst(lhs)
    elif isinstance(lhs, Contour) and isinstance(rhs, (int, float, complex)):
      return lhs._powconst(rhs)
    elif isinstance(lhs, Contour) and isinstance(rhs, Contour):
      return lhs._pow(rhs)
    else:
      raise NotImplementedError

  def __matmul__(lhs, rhs):
    raise NotImplementedError

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
