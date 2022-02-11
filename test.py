import libcalculus
import numpy as np
f = libcalculus.ComplexFunction.Sin()
f /= libcalculus.ComplexFunction.Cos()
print(f(3 + 7j))
print(f.latex())
