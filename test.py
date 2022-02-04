import libcalculus
import numpy as np
f = libcalculus.ComplexFunction.Sin() @ (libcalculus.ComplexFunction.Identity() ** 2)
print(libcalculus.derivative(f, 1 - 2j))
