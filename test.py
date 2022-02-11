import libcalculus
import numpy as np
f = libcalculus.ComplexFunction.Sin()
f -= libcalculus.ComplexFunction.Cos()
f /= 41
print(f(3 + 7j))
print(f.latex())
