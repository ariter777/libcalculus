import libcalculus

f = (1 + libcalculus.Function.Identity()) / 4.
g = 2 + libcalculus.Function.Identity()
print((f ** g)(5 + 3j))
