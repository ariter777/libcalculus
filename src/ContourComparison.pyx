# distutils: language = c++
from Definitions cimport *
from CComparison cimport *
cimport cython

cdef class ContourComparison:
  cdef CComparison[REAL, COMPLEX] ccomparison

  @cython.boundscheck(False)
  @cython.wraparound(False)
  cdef np.ndarray[cbool] _call_array(ContourComparison self, np.ndarray[const REAL] t):
    cdef np.ndarray[cbool] result = np.zeros_like(t, dtype=bool)
    for i in range(t.shape[0]):
      result[i] = self.ccomparison.eval(t[i])
    return result

  def __call__(ContourComparison self, t):
    if isinstance(t, (int, float)):
      return self.ccomparison.eval(t)
    elif isinstance(t, np.ndarray) and t.dtype == np.double:
      return self._call_array(t.ravel()).reshape(t.shape)
    elif isinstance(t, np.ndarray) and np.issubdtype(t.dtype, np.number):
      return self._call_array(t.ravel().astype(np.double, copy=False)).reshape(t.shape)
    else:
      raise NotImplementedError

  def __invert__(ContourComparison self):
    cdef ContourComparison result = ContourComparison()
    result.ccomparison = ~self.ccomparison
    return result

  def __or__(ContourComparison lhs, ContourComparison rhs):
    cdef ContourComparison result = ContourComparison()
    result.ccomparison = lhs.ccomparison | rhs.ccomparison
    return result

  def __and__(ContourComparison lhs, ContourComparison rhs):
    cdef ContourComparison result = ContourComparison()
    result.ccomparison = lhs.ccomparison & rhs.ccomparison
    return result
