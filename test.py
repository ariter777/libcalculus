import libcalculus
f = 5j * (libcalculus.ComplexFunction.Exp() @ libcalculus.Contour.Sin())
print(f.latex())
print(f(3))
