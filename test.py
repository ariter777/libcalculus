import libcalculus
import numpy as np
f = libcalculus.ComplexFunction.Constant(5 + 3j)
print(libcalculus.derivative(f, 1 - 2j))
print(f.latex())
