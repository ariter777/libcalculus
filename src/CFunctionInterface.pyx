# distutils: language = c++
from Definitions cimport *
from CFunction cimport *

cdef class CFunctionInterface:
  """A class that represents a generic function (complex, real, etc.), deducing types only when used."""
  cdef RealFunction realfunction
  cdef Contour contour
  cdef ComplexFunction complexfunction

  def __cinit__(CFunctionInterface self, RealFunction realfunction=None, Contour contour=None, ComplexFunction complexfunction=None):
    self.realfunction = realfunction
    self.contour = contour
    self.complexfunction = complexfunction
