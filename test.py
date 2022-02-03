import libcalculus

f = (1 + libcalculus.Function.Identity()) / 4.
g = 2 + libcalculus.Function.Identity()
print((libcalculus.Function.Sec() @ libcalculus.Function.Exp())(5 + 3j))
print((2 + ((libcalculus.Function.Sec() @ libcalculus.Function.Exp()) ** 2)).latex("x"))
