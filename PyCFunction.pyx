# distutils: language = c++
from libcpp.complex cimport complex as complex_t
from libcpp.string cimport string

cdef extern from "CFunction.cpp":
  pass

cdef extern from "CFunction.h" namespace "libcalculus":
  cdef cppclass CFunction[Dom, Ran]:
    CFunction() except +
    CFunction(CFunction[Dom, Ran] cf) except +
    Ran operator()(Dom z) except +
    CFunction[Predom, Ran] compose[Predom](CFunction[Predom, Dom] rhs) except +
    string latex(string varname) except +

    CFunction[Dom, Ran] operator+(CFunction[Dom, Ran] rhs) except +
    CFunction[Dom, Ran] operator-(CFunction[Dom, Ran] rhs) except +
    CFunction[Dom, Ran] operator*(CFunction[Dom, Ran] rhs) except +
    CFunction[Dom, Ran] operator/(CFunction[Dom, Ran] rhs) except +
    CFunction[Dom, Ran] pow(CFunction[Dom, Ran] rhs) except +

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
  cdef CFunction[complex_t[double], complex_t[double]] cfunction

  def __cinit__(self):
    pass

  def __call__(self, complex_t[double] z):
    return self.cfunction(z)

  def latex(self, str varname = "z"):
    return self.cfunction.latex(varname.encode()).decode()

  def _add(self, ComplexFunction rhs):
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]](self.cfunction) + rhs.cfunction
    return F

  def _sub(self, ComplexFunction rhs):
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]](self.cfunction) - rhs.cfunction
    return F

  def _mul(self, ComplexFunction rhs):
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]](self.cfunction) * rhs.cfunction
    return F

  def _div(self, ComplexFunction rhs):
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]](self.cfunction) / rhs.cfunction
    return F

  def _pow(self, ComplexFunction rhs):
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]](self.cfunction).pow(rhs.cfunction)
    return F

  def _compose(self, ComplexFunction rhs):
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]](self.cfunction).compose[complex_t[double]](rhs.cfunction)
    return F

  def _compose_contour(self, Contour rhs):
    F = Contour()
    F.cfunction = CFunction[complex_t[double], complex_t[double]](self.cfunction).compose[double](rhs.cfunction)
    return F

  def _addconst(self, complex_t[double] a):
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]](self.cfunction).addconst(a)
    return F

  def _subconst(self, complex_t[double] a):
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]](self.cfunction).subconst(a)
    return F

  def _lsubconst(self, complex_t[double] a):
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]](self.cfunction).lsubconst(a)
    return F

  def _mulconst(self, complex_t[double] a):
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]](self.cfunction).mulconst(a)
    return F

  def _divconst(self, complex_t[double] a):
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]](self.cfunction).divconst(a)
    return F

  def _ldivconst(self, complex_t[double] a):
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]](self.cfunction).ldivconst(a)
    return F

  def _powconst(self, complex_t[double] a):
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]](self.cfunction).powconst(a)
    return F

  def _lpowconst(self, complex_t[double] a):
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]](self.cfunction).lpowconst(a)
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
    F.cfunction = CFunction[complex_t[double], complex_t[double]].Exp()
    return F

  @staticmethod
  def Sin():
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]].Sin()
    return F

  @staticmethod
  def Cos():
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]].Cos()
    return F

  @staticmethod
  def Tan():
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]].Tan()
    return F

  @staticmethod
  def Sec():
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]].Sec()
    return F

  @staticmethod
  def Csc():
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]].Csc()
    return F

  @staticmethod
  def Cot():
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]].Cot()
    return F

  @staticmethod
  def Pi():
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]].Pi()
    return F

  @staticmethod
  def E():
    F = ComplexFunction()
    F.cfunction = CFunction[complex_t[double], complex_t[double]].E()
    return F

cdef class Contour:
  cdef CFunction[double, complex_t[double]] cfunction
  cdef double start, end

  def __cinit__(self, start=0., end=1.):
    self.start = start
    self.end = end

  def __call__(self, double t):
    return self.cfunction(t)

  def latex(self, str varname = "t"):
    return self.cfunction.latex(varname.encode()).decode()

  def _add(self, Contour rhs):
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]](self.cfunction) + rhs.cfunction
    return F

  def _sub(self, Contour rhs):
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]](self.cfunction) - rhs.cfunction
    return F

  def _mul(self, Contour rhs):
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]](self.cfunction) * rhs.cfunction
    return F

  def _div(self, Contour rhs):
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]](self.cfunction) / rhs.cfunction
    return F

  def _pow(self, Contour rhs):
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]](self.cfunction).pow(rhs.cfunction)
    return F

  def _addconst(self, complex_t[double] a):
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]](self.cfunction).addconst(a)
    return F

  def _subconst(self, complex_t[double] a):
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]](self.cfunction).subconst(a)
    return F

  def _lsubconst(self, complex_t[double] a):
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]](self.cfunction).lsubconst(a)
    return F

  def _mulconst(self, complex_t[double] a):
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]](self.cfunction).mulconst(a)
    return F

  def _divconst(self, complex_t[double] a):
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]](self.cfunction).divconst(a)
    return F

  def _ldivconst(self, complex_t[double] a):
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]](self.cfunction).ldivconst(a)
    return F

  def _powconst(self, complex_t[double] a):
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]](self.cfunction).powconst(a)
    return F

  def _lpowconst(self, complex_t[double] a):
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]](self.cfunction).lpowconst(a)
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
  def Identity():
    return Contour()

  @staticmethod
  def Exp():
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]].Exp()
    return F

  @staticmethod
  def Sin():
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]].Sin()
    return F

  @staticmethod
  def Cos():
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]].Cos()
    return F

  @staticmethod
  def Tan():
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]].Tan()
    return F

  @staticmethod
  def Sec():
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]].Sec()
    return F

  @staticmethod
  def Csc():
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]].Csc()
    return F

  @staticmethod
  def Cot():
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]].Cot()
    return F

  @staticmethod
  def Pi():
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]].Pi()
    return F

  @staticmethod
  def E():
    F = Contour()
    F.cfunction = CFunction[double, complex_t[double]].E()
    return F

  @staticmethod
  def Sphere(complex center=0., double radius=1., ccw=False):
    return (-1. if ccw else 1.) * radius * (ComplexFunction.Exp() @ (1j * Contour.Identity()))
