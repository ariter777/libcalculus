from Definitions cimport *

cdef extern from "CComparison.cpp" nogil:
  pass

cdef extern from "CComparison.h" namespace "libcalculus" nogil:
  cdef cppclass CComparison[Dom, Ran]:
    cbool eval(Dom z) except +
    # Unary operators
    CComparison[Dom, Ran] operator~() except +

    # Binary operators
    CComparison[Dom, Ran] operator|(CComparison[Dom, Ran] &rhs) except +
    CComparison[Dom, Ran] operator&(CComparison[Dom, Ran] &rhs) except +

    # In-place binary operators
    CComparison[Dom, Ran] &operator|=(CComparison[Dom, Ran] &rhs) except +
    CComparison[Dom, Ran] &operator&=(CComparison[Dom, Ran] &rhs) except +
