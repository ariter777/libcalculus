import libcalculus
f = libcalculus.Function.Cot() @ (libcalculus.Function.Identity() / libcalculus.pi * libcalculus.e)
print(f.latex())
print(f(3 + 5j) * 20)
