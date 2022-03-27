# distutils: language = c++
from Definitions cimport *
import numpy as np

cdef class Comparison:
  """A class that represents a generic comparison (complex, real, etc.), deducing types only when used.
  Comparisons such as Function() > 0 and Function() == 1j produce instances of this class."""
  cdef RealComparison realcomparison
  cdef ComplexComparison complexcomparison

  def __cinit__(Comparison self, RealComparison realcomparison, ComplexComparison complexcomparison):
    self.realcomparison = realcomparison.copy() if realcomparison is not None else None
    self.complexcomparison = complexcomparison.copy() if complexcomparison is not None else None

  def __call__(Comparison self, x):
    """Evaluate the comparison at a point or on an np.ndarray of points."""
    if self.realcomparison is None and self.complexcomparison is None:
      raise ValueError("The comparison is malformed and could not be evaluated.")
    if _isrealscalar(x):
      return self.realcomparison.ccomparison.eval(<REAL>x) if self.realcomparison is not None else \
             self.complexcomparison.ccomparison.eval(<COMPLEX>x)
    elif _isrealarray(x):
      return self.realcomparison._call_array(x.ravel().astype(np.double, copy=False)) if self.realcomparison is not None else \
             self.complexcomparison._call_array(x.ravel().astype(complex, copy=False))
    elif _iscomplexscalar(x) and self.complexcomparison is not None:
      return self.complexcomparison.ccomparison.eval(<COMPLEX>x)
    elif _iscomplexarray(x) and self.complexcomparison is not None:
      return self.complexcomparison._call_array(x.ravel().astype(complex, copy=False)).reshape(x.shape)
    else:
      raise NotImplementedError(f"Input of type {type(x)} not supported.")

  def __invert__(Comparison self):
    return Comparison(~self.realcomparison if self.realcomparison is not None else None,
                      ~self.complexcomparison if self.complexcomparison is not None else None)

  def __iand__(Comparison self, Comparison rhs not None):
    if self.realcomparison is not None and rhs.realcomparison is not None:
      self.realcomparison.iand(rhs.realcomparison)
    else:
      self.realcomparison = None
    if self.complexcomparison is not None and rhs.complexcomparison is not None:
      self.complexcomparison.iand(rhs.complexcomparison)
    else:
      self.complexcomparison = None
    return self

  def __ior__(Comparison self, Comparison rhs not None):
    if self.realcomparison is not None and rhs.realcomparison is not None:
      self.realcomparison.ior(rhs.realcomparison)
    else:
      self.realcomparison = None
    if self.complexcomparison is not None and rhs.complexcomparison is not None:
      self.complexcomparison.ior(rhs.complexcomparison)
    else:
      self.complexcomparison = None
    return self

  def __and__(Comparison lhs, Comparison rhs):
    return Comparison(lhs.realcomparison & rhs.realcomparison if lhs.realcomparison is not None and rhs.realcomparison is not None else None,
                      lhs.complexcomparison & rhs.complexcomparison if lhs.complexcomparison is not None and rhs.complexcomparison is not None else None)

  def __or__(Comparison lhs, Comparison rhs):
    return Comparison(lhs.realcomparison | rhs.realcomparison if lhs.realcomparison is not None and rhs.realcomparison is not None else None,
                      lhs.complexcomparison | rhs.complexcomparison if lhs.complexcomparison is not None and rhs.complexcomparison is not None else None)
