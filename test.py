import libcalculus
import numpy as np
f = libcalculus.ComplexFunction.Sin() @ (libcalculus.ComplexFunction.Identity() ** 2)
print(libcalculus.derivative(1 - -f + 2, 1 - 2j))
print((1 - -f + 2).latex())
