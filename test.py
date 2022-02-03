import libcalculus

f = (-1 + libcalculus.Function.Identity()) / (4 - 18j)
g = 2 + libcalculus.Function.Identity()
print((f ** ((3 + 5j) / (g + libcalculus.Function.Csc() ** (2 + 3j)))).latex())
