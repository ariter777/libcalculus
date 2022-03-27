from Definitions cimport *

cdef extern from "CComparison.cpp" nogil:
  pass

cdef extern from "CComparison.h" namespace "libcalculus" nogil:
  cdef cppclass CComparison[Dom]:
    CComparison() except +
    CComparison(CComparison[Dom] cc) except +
    cbool eval(Dom z) except +
    # Unary operators
    CComparison[Dom] operator~() except +

    # Binary operators
    CComparison[Dom] operator|(CComparison[Dom] &rhs) except +
    CComparison[Dom] operator&(CComparison[Dom] &rhs) except +

    # In-place binary operators
    CComparison[Dom] &ior "operator|="(CComparison[Dom] &rhs) except +
    CComparison[Dom] &iand "operator&="(CComparison[Dom] &rhs) except +
