import libcalculus
import numpy as np
f =  libcalculus.ComplexFunction.Sin() @ libcalculus.ComplexFunction.Constant(5 + 3j) + libcalculus.ComplexFunction.Exp()
print(libcalculus.derivative(f, 1 - 2j))
print(f.latex())
