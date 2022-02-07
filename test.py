import libcalculus
import numpy as np
f =  libcalculus.ComplexFunction.Sin() @ libcalculus.ComplexFunction.Constant(5 + 3j) + libcalculus.ComplexFunction.Exp()
print(libcalculus.integrate(f, libcalculus.Contour.Sin()))
print(f.latex())
