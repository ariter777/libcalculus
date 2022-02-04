import libcalculus
import numpy as np
f = 1. / libcalculus.ComplexFunction.Identity()
print(libcalculus.derivative(f, 3 + 2j, 2))
