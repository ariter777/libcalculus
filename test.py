#!/usr/bin/env python3
import libcalculus
from libcalculus import ComplexFunction, RealFunction, Contour, integrate

import numpy as np
import scipy.misc, scipy.integrate
import operator
import argparse
import pqdm.processes
import multiprocessing as mp
import requests
import warnings

class Tester:
    def run(self):
        print(f"\033[1mStarting {type(self).__name__}:\033[0m")

    def _done(self):
        print(f"\033[1;92mDone: {type(self).__name__}.\033[0m\n")

class FunctionTester(Tester):
    BASE_FUNCTIONS = {libcalculus.constant: None,
                      libcalculus.identity: lambda z: z,
                      libcalculus.real: lambda z: np.real(z),
                      libcalculus.imag: lambda z: np.imag(z),
                      libcalculus.conj: lambda z: np.conj(z),
                      libcalculus.abs: lambda z: np.abs(z),
                      libcalculus.exp: lambda z: complex(np.exp(z)),
                      libcalculus.sin: lambda z: complex(np.sin(z)),
                      libcalculus.cos: lambda z: complex(np.cos(z)),
                      libcalculus.tan: lambda z: complex(np.tan(z)),
                      libcalculus.sec: lambda z: complex(1.) / complex(np.cos(z)),
                      libcalculus.csc: lambda z: complex(1.) / complex(np.sin(z)),
                      libcalculus.cot: lambda z: complex(1.) / complex(np.tan(z)),
                      libcalculus.sinh: lambda z: complex(np.sinh(z)),
                      libcalculus.cosh: lambda z: complex(np.cosh(z)),
                      libcalculus.tanh: lambda z: complex(np.tanh(z)),
                      libcalculus.sech: lambda z: complex(1.) / complex(np.cosh(z)),
                      libcalculus.csch: lambda z: complex(1.) / complex(np.sinh(z)),
                      libcalculus.coth: lambda z: complex(1.) / complex(np.tanh(z))}
    BINARY_OPERATIONS = [operator.iadd, operator.isub, operator.imul, operator.itruediv, operator.ipow,
                         operator.add, operator.sub, operator.mul, operator.truediv, operator.pow,
                         operator.matmul]
    UNARY_OPERATIONS = [operator.neg]
    OPERATION_TYPES = np.array([BINARY_OPERATIONS, UNARY_OPERATIONS], dtype=object)
    BOUND = 20
    MAX_OPS = 5
    MAX_TRIES = 20
    MAX_ERRORS = 20
    N_JOBS = mp.cpu_count()

    def _rand(self, n=1):
        real, imag = np.random.uniform(-self.BOUND, self.BOUND, size=(2, n))
        return (real + 1j * imag) if n > 1 else (real[0] + 1j * imag[0])

    def _random_base_function(self):
        """Returns a random function object and its corresponding lambda."""
        func = np.random.choice(list(self.BASE_FUNCTIONS.keys()))
        if func is ComplexFunction.Constant or func is RealFunction.Constant or func is Contour.Constant or func is libcalculus.constant:
            c = self._rand()
            return func(c), lambda z, v=c: v
        else:
            return func.copy() if isinstance(func, libcalculus.Function) else func(), self.BASE_FUNCTIONS[func]

    def _gen_function(self, n_ops=None):
        """Generate a random function object with n operations of any kind."""
        n_ops = n_ops if n_ops is not None else np.random.randint(0, self.MAX_OPS)
        func, comp_func = self._random_base_function()

        for _ in range(n_ops):
            op_type = np.random.choice(self.OPERATION_TYPES, p=[len(entry) / sum(len(entry2) for entry2 in self.OPERATION_TYPES) for entry in self.OPERATION_TYPES])
            op = np.random.choice(op_type)
            if op_type is self.BINARY_OPERATIONS:
                operand_type = np.random.choice([0, 1], p=[.2, .8])
                if operand_type == 0 and op != operator.matmul: # Operation with a random constant:
                    operand = self._rand()
                    comp_operand = lambda z, v=operand: v
                else:
                    operand, comp_operand = self._random_base_function()
                order = np.random.choice([-1, 1])
                func = op(*[func, operand][::order])
                if op != operator.matmul:
                    comp_func = lambda z, op_=op, comp_func_=comp_func, comp_operand_=comp_operand, order_=order: op_(*[comp_func_(z), comp_operand_(z)][::order_])
                else:
                    comp_func = lambda z, op_=op, comp_func_=comp_func, comp_operand_=comp_operand, order_=order: \
                                    comp_func_(comp_operand_(z)) if order_ == 1 else comp_operand_(comp_func_(z))

            elif op_type is self.UNARY_OPERATIONS:
                func = op(func)
                comp_func = lambda z, op_=op, comp_func_=comp_func: op_(comp_func_(z))
        return func, comp_func

    def _run_func(self, n_vals, n_ops=None):
        np.seterr(all="ignore")
        n_tries = self.MAX_TRIES + 1
        n_errors = self.MAX_ERRORS + 1
        while n_tries > self.MAX_TRIES:
            n_tries = 0
            n_errors = 0
            f, cf = self._gen_function(n_ops)
            for _ in range(n_vals):
                while True:
                    val = self._rand()
                    try:
                        f_val, cf_val = f(val), cf(val)
                        if np.isfinite(f_val) and np.isfinite(cf_val):
                            if not np.allclose(f_val, cf_val):
                                n_errors += 1
                            break
                        n_tries += 1
                    except (OverflowError, ZeroDivisionError):
                        n_tries += 1
                    finally:
                        if n_tries > self.MAX_TRIES: # We've hit a functional division by zero (e.g. 1 / (z - z)):
                            break

                if n_errors >= self.MAX_ERRORS:
                    raise ValueError(f"\033[1;41mERROR IN {type(self).__name__}:\033[0m {f.latex()}\n\t at {val}: {f_val} vs actual {cf_val}")

                if n_tries > self.MAX_TRIES:
                    break


    def run(self, n_funcs, n_vals):
        """Generate n_funcs random functions and check them on n_values values."""
        super().run()
        # First try with an increasing number of operations; that way an error in a basic operator will pop up with a simple function
        # and not a convoluted one
        pqdm.processes.pqdm([[n_vals, i] for i in range(self.MAX_OPS)],
                            self._run_func, n_jobs=self.N_JOBS, argument_type="args", exception_behaviour="immediate", bounded=True,
                            disable=True)

        # Now try with a random number of operations.
        pqdm.processes.pqdm([[n_vals, None] for _ in range(n_funcs - self.MAX_OPS)],
                            self._run_func, n_jobs=self.N_JOBS, argument_type="args", exception_behaviour="immediate", bounded=True)

        super()._done()

class ComplexFunctionTester(FunctionTester):
    BASE_FUNCTIONS = {ComplexFunction.Constant: None,
                      ComplexFunction.Identity: lambda z: z,
                      ComplexFunction.Re: lambda z: np.real(z),
                      ComplexFunction.Im: lambda z: np.imag(z),
                      ComplexFunction.Conj: lambda z: np.conj(z),
                      ComplexFunction.Abs: lambda z: np.abs(z),
                      ComplexFunction.Exp: lambda z: complex(np.exp(z)),
                      ComplexFunction.Sin: lambda z: complex(np.sin(z)),
                      ComplexFunction.Cos: lambda z: complex(np.cos(z)),
                      ComplexFunction.Tan: lambda z: complex(np.tan(z)),
                      ComplexFunction.Sec: lambda z: complex(1.) / complex(np.cos(z)),
                      ComplexFunction.Csc: lambda z: complex(1.) / complex(np.sin(z)),
                      ComplexFunction.Cot: lambda z: complex(1.) / complex(np.tan(z)),
                      ComplexFunction.Sinh: lambda z: complex(np.sinh(z)),
                      ComplexFunction.Cosh: lambda z: complex(np.cosh(z)),
                      ComplexFunction.Tanh: lambda z: complex(np.tanh(z)),
                      ComplexFunction.Sech: lambda z: complex(1.) / complex(np.cosh(z)),
                      ComplexFunction.Csch: lambda z: complex(1.) / complex(np.sinh(z)),
                      ComplexFunction.Coth: lambda z: complex(1.) / complex(np.tanh(z))}

class RealFunctionTester(ComplexFunctionTester):
    BOUND = 20.
    BASE_FUNCTIONS = {RealFunction.Constant: None,
                      RealFunction.Identity: lambda z: z,
                      RealFunction.Abs: lambda z: np.abs(z),
                      RealFunction.Exp: lambda z: np.exp(z),
                      RealFunction.Sin: lambda z: np.sin(z),
                      RealFunction.Cos: lambda z: np.cos(z),
                      RealFunction.Tan: lambda z: np.tan(z),
                      RealFunction.Sec: lambda z: 1. / np.cos(z),
                      RealFunction.Csc: lambda z: 1. / np.sin(z),
                      RealFunction.Cot: lambda z: 1. / np.tan(z),
                      RealFunction.Sinh: lambda z: np.sinh(z),
                      RealFunction.Cosh: lambda z: np.cosh(z),
                      RealFunction.Tanh: lambda z: np.tanh(z),
                      RealFunction.Sech: lambda z: 1. / np.cosh(z),
                      RealFunction.Csch: lambda z: 1. / np.sinh(z),
                      RealFunction.Coth: lambda z: 1. / np.tanh(z)}

    def _rand(self, n=1):
        return np.random.uniform(-self.BOUND, self.BOUND, size=n) if n > 1 else np.random.uniform(-self.BOUND, self.BOUND)

class ContourTester(ComplexFunctionTester):
    BOUND = 20.
    BASE_FUNCTIONS = {Contour.Constant: None,
                      Contour.Identity: lambda t: t,
                      Contour.Abs: lambda t: np.abs(t),
                      Contour.Exp: lambda t: complex(np.exp(t)),
                      Contour.Sin: lambda t: complex(np.sin(t)),
                      Contour.Cos: lambda t: complex(np.cos(t)),
                      Contour.Tan: lambda t: complex(np.tan(t)),
                      Contour.Sec: lambda t: complex(1.) / complex(np.cos(t)),
                      Contour.Csc: lambda t: complex(1.) / complex(np.sin(t)),
                      Contour.Cot: lambda t: complex(1.) / complex(np.tan(t)),
                      Contour.Sinh: lambda t: complex(np.sinh(t)),
                      Contour.Cosh: lambda t: complex(np.cosh(t)),
                      Contour.Tanh: lambda t: complex(np.tanh(t)),
                      Contour.Sech: lambda t: complex(1.) / complex(np.cosh(t)),
                      Contour.Csch: lambda t: complex(1.) / complex(np.sinh(t)),
                      Contour.Coth: lambda t: complex(1.) / complex(np.tanh(t))}

    BINARY_OPERATIONS = [operator.iadd, operator.isub, operator.imul, operator.itruediv, operator.ipow,
                         operator.add, operator.sub, operator.mul, operator.truediv, operator.pow]

    def _rand(self, n=1):
        return np.random.uniform(-self.BOUND, self.BOUND, size=n) if n > 1 else np.random.uniform(-self.BOUND, self.BOUND)

    def _gen_function(self, n_ops=None):
        c, cc = super()._gen_function(n_ops)
        return c, cc

class IntegralTester(FunctionTester):
    MAX_OPS = 1
    BOUND = 1.
    TOL = 1e-3

    def __init__(self):
        self.cft = ComplexFunctionTester()
        self.ct = ContourTester()

    def _scipy_integrate(self, integrand, start, end, tol=1e-3):
        integrand_real = lambda t: np.real(integrand(t))
        integrand_imag = lambda t: np.imag(integrand(t))
        return scipy.integrate.quad(integrand_real, start, end, epsabs=tol)[0] + \
               1j * scipy.integrate.quad(integrand_imag, start, end, epsabs=tol)[0]

    def _random_contour(self):
        radius = abs(self.ct._rand())
        center = self.cft._rand()
        c = Contour.Sphere(radius=radius, center=center)
        cc = lambda t: center + radius * np.exp(1j * t)
        return c, cc

    def _run_integral(self, n_integrals):
        f, cf = self.cft._gen_function(self.MAX_OPS)
        with warnings.catch_warnings(record=True) as w:
            for _ in range(n_integrals):
                warnings.simplefilter("always")
                c, cc = self._random_contour()
                start, end = self.ct._rand(2)
                dcc = lambda t: scipy.misc.derivative(cc, t, dx=self.TOL)

                integral = integrate(f, c, start, end, tol=self.TOL)
                cintegral = self._scipy_integrate(lambda t: cf(cc(t)) * dcc(t), start, end, tol=self.TOL)
                if len(w) > 1 or np.isnan(integral) or np.isnan(cintegral):
                    return self._run_integral(n_integrals) # Run a random function again
                elif not np.allclose(integral, cintegral, rtol=10. * self.TOL, atol=10. * self.TOL):
                    raise ValueError(f"\033[1;41mERROR IN {type(self).__name__}:\033[0m {f.latex()}\n\t "
                                     f"integrating along {c.latex()} from {c.start} to {c.end}: {integral} vs actual {cintegral}")

    def run(self, n_funcs, n_integrals):
        """Generate n_funcs random functions and check n_integrals random integrals on each function."""
        super().run()
        pqdm.processes.pqdm([[n_integrals]] * n_funcs, self._run_integral, n_jobs=self.N_JOBS, argument_type="args", exception_behaviour="immediate", bounded=True)
        super()._done()

class LatexTester(Tester):
    RENDERER_URL = r"https://latex.codecogs.com/gif.latex?\bg_white\LARGE "
    SAVE_PATH = "latex.gif"

    def _render_latex(self, latex):
        r = requests.get(self.RENDERER_URL + latex)
        if r.status_code == 200:
            return r.content
        else:
            raise requests.exceptions.RequestException(f"HTTP Status: {r.status_code}")

    def run(self, n_funcs, n_ops=None):
        super().run()
        complex_tester = ComplexFunctionTester()
        funcs = (complex_tester._gen_function(n_ops)[0] for _ in range(n_funcs))
        latex = r"\\" + r"\\\\\\".join(func.latex() for func in funcs)
        rendered_latex = self._render_latex(latex)
        with open(self.SAVE_PATH, "wb") as wfd:
            wfd.write(rendered_latex)
        print(f"Written Latex to {self.SAVE_PATH}.")
        super()._done()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Test suite for libcalculus.")
    parser.add_argument("-a", "--all", action="store_true")
    parser.add_argument("--Function", action="store_true")
    parser.add_argument("--ComplexFunction", action="store_true")
    parser.add_argument("--RealFunction", action="store_true")
    parser.add_argument("--Contour", action="store_true")
    parser.add_argument("--Integral", action="store_true")
    parser.add_argument("--Latex", action="store_true")
    args = parser.parse_args()

    if args.ComplexFunction or args.all:
        tester = ComplexFunctionTester()
        tester.run(500, 10)

    if args.Function or args.all:
        tester = FunctionTester()
        tester.run(500, 10)

    if args.RealFunction or args.all:
        tester = RealFunctionTester()
        tester.run(500, 10)

    if args.Contour or args.all:
        tester = ContourTester()
        tester.run(500, 10)

    if args.Integral or args.all:
        tester = IntegralTester()
        tester.run(2, 2)

    if args.Latex or args.all:
        tester = LatexTester()
        tester.run(3)
