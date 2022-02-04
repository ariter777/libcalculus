import libcalculus
import numpy as np
f = 1. / libcalculus.ComplexFunction.Identity()
print(f.latex())
print(libcalculus.residue(f, 0))
