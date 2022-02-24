from libcpp cimport bool as cbool
from libcpp.string cimport string
from libc.math cimport M_PI, M_E

import numpy as np
cimport numpy as np
np.import_array()

ctypedef double REAL
ctypedef np.complex128_t COMPLEX

cimport cython
