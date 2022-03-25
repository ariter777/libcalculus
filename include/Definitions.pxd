from libcpp cimport bool as cbool
from libcpp.string cimport string
from libc.math cimport M_PI, M_E

import numpy as np
cimport numpy as np
np.import_array()

ctypedef double REAL
ctypedef np.complex128_t COMPLEX

cimport cython

cdef inline cbool _isrealscalar(x):
  return isinstance(x, (int, float, np.int8, np.int16, np.int32, np.int64, np.float16, np.float32, np.float64, np.double))

cdef inline cbool _isrealarray(x):
  return isinstance(x, np.ndarray) and x.dtype in (int, float, np.int8, np.int16, np.int32, np.int64, np.float16, np.float32, np.float64, np.double)

cdef inline cbool _iscomplexscalar(x):
  return isinstance(x, (complex, np.complex64, np.complex128))

cdef inline cbool _iscomplexarray(x):
  return isinstance(x, np.ndarray) and x.dtype in (complex, np.complex64, np.complex128)
