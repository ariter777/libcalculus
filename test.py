import libcalculus
import numpy as np
print(libcalculus.integrate(libcalculus.ComplexFunction.Sin() @ (5 * libcalculus.ComplexFunction.Exp()), libcalculus.Contour.Sphere(), 0., 5.))
