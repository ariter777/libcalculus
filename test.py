import libcalculus
f = 5 * libcalculus.Function.Identity()
g = libcalculus.pi + libcalculus.Function.Identity()
h = 2 ** ((f ** ((3 + 5j) / (g + libcalculus.Function.Csc() * (2 + 3j)))))
print(h.latex())
print(h(29 + 7j))
