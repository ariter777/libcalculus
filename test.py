import libcalculus
import numpy as np
f = libcalculus.ComplexFunction.Sin() @ (5 * libcalculus.ComplexFunction.Exp())
contour = libcalculus.Contour.Sphere()
print(contour.start, contour.end)
print(libcalculus.integrate(f, contour))
print(f.latex())
