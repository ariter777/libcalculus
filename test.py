import libcalculus
import numpy as np
f = libcalculus.ComplexFunction.Sin()
print(libcalculus.derivative(f, 1 - 2j))
print(f.latex())
