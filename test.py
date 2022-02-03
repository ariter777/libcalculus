import libcalculus
f = libcalculus.Function.Csc() @ (libcalculus.Function.Identity() / libcalculus.pi * libcalculus.e)
print(f.latex())
