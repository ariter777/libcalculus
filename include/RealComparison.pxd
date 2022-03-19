from CComparison cimport *
from Definitions cimport *

cdef class RealComparison:
  """Comparison between functions that take in real values.
  Comparisons such as RealFunction() > 0 and Contour() == 1j produce instances of this class.
  """
  cdef CComparison[REAL] ccomparison
