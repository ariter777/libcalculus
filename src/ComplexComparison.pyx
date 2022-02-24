# distutils: language = c++
cdef class ComplexComparison:
  cdef CComparison[COMPLEX, COMPLEX] ccomparison

  def __call__(ComplexComparison self, COMPLEX z):
    return self.ccomparison.eval(z)

  def __invert__(ComplexComparison self):
    cdef ComplexComparison result = ComplexComparison()
    result.ccomparison = ~self.ccomparison
    return result

  def __or__(ComplexComparison lhs, ComplexComparison rhs):
    cdef ComplexComparison result = ComplexComparison()
    result.ccomparison = lhs.ccomparison | rhs.ccomparison
    return result

  def __and__(ComplexComparison lhs, ComplexComparison rhs):
    cdef ComplexComparison result = ComplexComparison()
    result.ccomparison = lhs.ccomparison & rhs.ccomparison
    return result
