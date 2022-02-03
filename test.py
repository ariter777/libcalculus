import libcalculus
f = 5 * libcalculus.ComplexFunction.Identity()
g = libcalculus.ComplexFunction.Pi() + libcalculus.ComplexFunction.Identity()
h = 2 ** ((f ** ((3 + 5j) / (g + libcalculus.ComplexFunction.Csc() * (2 + 3j)))))
print(h.latex())
print(h(29 + 7j))
