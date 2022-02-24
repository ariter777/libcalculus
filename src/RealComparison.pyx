# distutils: language = c++
from Definitions cimport *

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
