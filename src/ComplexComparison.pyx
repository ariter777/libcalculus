# distutils: language = c++
from Definitions cimport *
from CComparison cimport *
cimport cython

cdef class ComplexComparison:
  cdef CComparison[COMPLEX] ccomparison

  @cython.boundscheck(False)
  @cython.wraparound(False)
  cdef np.ndarray[cbool] _call_array(ComplexComparison self, np.ndarray[const COMPLEX] z):
    cdef np.ndarray[cbool] result = np.zeros_like(z, dtype=bool)
    for i in range(z.shape[0]):
      result[i] = self.ccomparison.eval(z[i])
    return result

  def copy(ComplexComparison self):
    """Create a copy of the object."""
    cdef ComplexComparison result = ComplexComparison()
    result.ccomparison = CComparison[COMPLEX](self.ccomparison)
    return result

  def __call__(ComplexComparison self, z):
    if isinstance(z, (int, float, complex)):
      return self.ccomparison.eval(z)
    elif isinstance(z, np.ndarray) and z.dtype == complex:
      return self._call_array(z.ravel()).reshape(z.shape)
    elif isinstance(z, np.ndarray) and np.issubdtype(z.dtype, np.number):
      return self._call_array(z.ravel().astype(complex, copy=False)).reshape(z.shape)
    else:
      raise NotImplementedError

  def __invert__(ComplexComparison self):
    cdef ComplexComparison result = ComplexComparison()
    result.ccomparison = ~self.ccomparison
    return result

  def __iand__(ComplexComparison self, ComplexComparison rhs not None):
    self.ccomparison.iand(rhs.ccomparison)
    return self

  def __ior__(ComplexComparison self, ComplexComparison rhs not None):
    self.ccomparison.ior(rhs.ccomparison)
    return self

  def __and__(ComplexComparison lhs not None, ComplexComparison rhs not None):
    cdef ComplexComparison result = ComplexComparison()
    result.ccomparison = lhs.ccomparison & rhs.ccomparison
    return result

  def __or__(ComplexComparison lhs not None, ComplexComparison rhs not None):
    cdef ComplexComparison result = ComplexComparison()
    result.ccomparison = lhs.ccomparison | rhs.ccomparison
    return result
