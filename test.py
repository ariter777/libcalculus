import libcalculus
import numpy as np
f = libcalculus.ComplexFunction.Sin() @ (5 * libcalculus.ComplexFunction.Exp())
contour = libcalculus.Contour.Sphere()
print(libcalculus.integrate(f, contour, 0., 5.))
print(f.latex())
