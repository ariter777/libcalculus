import libcalculus
import numpy as np
f = 3 - libcalculus.ComplexFunction.Sin()
print(f(3 + 7j))
print(f.latex())
