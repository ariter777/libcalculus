from Definitions cimport *
from CComparison cimport *

cdef extern from "CFunction.cpp" nogil:
  pass

cdef extern from "Latex.cpp" nogil:
  pass

cdef extern from "CFunction.h" namespace "libcalculus" nogil:
  cdef cppclass CFunction[Dom, Ran]:
    CFunction() except +
    CFunction(CFunction[Dom, Ran] cf) except +
    Ran operator()(Dom z) except +
    void _call_array "operator()"(Dom *z, Ran *result, size_t n) except +
    string latex(string &varname) except +

    # Function composition
    CFunction[Predom, Ran] compose[Predom](CFunction[Predom, Dom] &rhs) except +

    # In-place function-with-function operators
    CFunction[Dom, Ran] &operator+=(CFunction[Dom, Ran] &rhs) except +
    CFunction[Dom, Ran] &operator-=(CFunction[Dom, Ran] &rhs) except +
    CFunction[Dom, Ran] &operator*=(CFunction[Dom, Ran] &rhs) except +
    CFunction[Dom, Ran] &operator/=(CFunction[Dom, Ran] &rhs) except +
    CFunction[Dom, Ran] &ipow(CFunction[Dom, Ran] &rhs) except +

    # In-place function-with-constant operators
    CFunction[Dom, Ran] &operator+=(Ran c) except +
    CFunction[Dom, Ran] &operator-=(Ran c) except +
    CFunction[Dom, Ran] &operator*=(Ran c) except +
    CFunction[Dom, Ran] &operator/=(Ran c) except +
    CFunction[Dom, Ran] &ipow(Ran c) except +

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
    CComparison[Dom] operator>(CFunction[Dom, Ran] &rhs) except +
    CComparison[Dom] operator<(CFunction[Dom, Ran] &rhs) except +
    CComparison[Dom] operator==(CFunction[Dom, Ran] &rhs) except +
    CComparison[Dom] operator>=(CFunction[Dom, Ran] &rhs) except +
    CComparison[Dom] operator<=(CFunction[Dom, Ran] &rhs) except +
    CComparison[Dom] operator!=(CFunction[Dom, Ran] &rhs) except +

    # Preset instances
    @staticmethod
    CFunction[Dom, Ran] Constant(Ran c) except +
    @staticmethod
    CFunction[Dom, Ran] Re() except +
    @staticmethod
    CFunction[Dom, Ran] Im() except +
    @staticmethod
    CFunction[Dom, Ran] Conj() except +
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
    CFunction[Dom, Ran] Sinh() except +
    @staticmethod
    CFunction[Dom, Ran] Cosh() except +
    @staticmethod
    CFunction[Dom, Ran] Tanh() except +
    @staticmethod
    CFunction[Dom, Ran] Sech() except +
    @staticmethod
    CFunction[Dom, Ran] Csch() except +
    @staticmethod
    CFunction[Dom, Ran] Coth() except +
    @staticmethod
    CFunction[Dom, Ran] Pi() except +
    @staticmethod
    CFunction[Dom, Ran] E() except +
    @staticmethod
    CFunction[Dom, Ran] If(CComparison[Dom] &cond_, CFunction[Dom, Ran] &then_, CFunction[Dom, Ran] &else_) except +

  # Constant-with-function operators
  CFunction[COMPLEX, COMPLEX] csubC "operator-"(COMPLEX lhs, CFunction[COMPLEX, COMPLEX] &rhs) except +
  CFunction[COMPLEX, COMPLEX] cdivC "operator/"(COMPLEX lhs, CFunction[COMPLEX, COMPLEX] &rhs) except +
  CFunction[REAL, COMPLEX] rsubC "operator-"(COMPLEX lhs, CFunction[REAL, COMPLEX] &rhs) except +
  CFunction[REAL, COMPLEX] rdivC "operator/"(COMPLEX lhs, CFunction[REAL, COMPLEX] &rhs) except +
  CFunction[REAL, REAL] rsubR "operator-"(REAL lhs, CFunction[REAL, REAL] &rhs) except +
  CFunction[REAL, REAL] rdivR "operator/"(REAL lhs, CFunction[REAL, REAL] &rhs) except +
