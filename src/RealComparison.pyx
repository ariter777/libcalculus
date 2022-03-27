# distutils: language = c++
from Definitions cimport *
from CComparison cimport *
cimport cython
import numpy as np
cimport numpy as np

cdef class RealComparison:
  """Comparison between functions that take in real values.
  Comparisons such as RealFunction() > 0 and Contour() == 1j produce instances of this class.
  """
  cdef CComparison[REAL] ccomparison

  @cython.boundscheck(False)
  @cython.wraparound(False)
  cdef np.ndarray[cbool] _call_array(RealComparison self, np.ndarray[const REAL] t):
    cdef np.ndarray[cbool] result = np.zeros_like(t, dtype=bool)
    for i in range(t.shape[0]):
      result[i] = self.ccomparison.eval(t[i])
    return result

  def copy(RealComparison self):
    """Create a copy of the object."""
    cdef RealComparison result = RealComparison()
    result.ccomparison = CComparison[REAL](self.ccomparison)
    return result

  def __call__(RealComparison self, t):
    if isinstance(t, (int, float)):
      return self.ccomparison.eval(t)
    elif isinstance(t, np.ndarray) and t.dtype == np.double:
      return self._call_array(t.ravel()).reshape(t.shape)
    elif isinstance(t, np.ndarray) and np.issubdtype(t.dtype, np.number):
      return self._call_array(t.ravel().astype(np.double, copy=False)).reshape(t.shape)
    else:
      raise NotImplementedError

  def __invert__(RealComparison self):
    cdef RealComparison result = RealComparison()
    result.ccomparison = ~self.ccomparison
    return result

  def __iand__(RealComparison self, RealComparison rhs not None):
    self.ccomparison.iand(rhs.ccomparison)
    return self

  def __ior__(RealComparison self, RealComparison rhs not None):
    self.ccomparison.iand(rhs.ccomparison)
    return self

  def __and__(RealComparison lhs not None, RealComparison rhs not None):
    cdef RealComparison result = RealComparison()
    result.ccomparison = lhs.ccomparison & rhs.ccomparison
    return result

  def __or__(RealComparison lhs not None, RealComparison rhs not None):
    cdef RealComparison result = RealComparison()
    result.ccomparison = lhs.ccomparison | rhs.ccomparison
    return result
