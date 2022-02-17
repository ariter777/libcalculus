#!/usr/bin/env python3
from libcalculus import ComplexFunction, Contour, integrate

import numpy as np
import scipy.misc, scipy.integrate
import operator
import argparse
import pqdm.processes
import multiprocessing as mp
import requests

class Tester:
    def run(self):
        print(f"\033[1mStarting {type(self).__name__}:\033[0m")

    def _done(self):
        print(f"\033[1;92mDone: {type(self).__name__}.\033[0m\n")

class FunctionTester(Tester):
    BINARY_OPERATIONS = [operator.iadd, operator.isub, operator.imul, operator.itruediv, operator.ipow,
                         operator.add, operator.sub, operator.mul, operator.truediv, operator.pow,
                         operator.matmul]
    UNARY_OPERATIONS = [operator.neg]
    OPERATION_TYPES = [BINARY_OPERATIONS, UNARY_OPERATIONS]
    BOUND = 20
    MAX_OPS = 5
    MAX_TRIES = 20
    MAX_ERRORS = 20
    N_JOBS = mp.cpu_count()

    def _rand(self):
        real, imag = np.random.uniform(-self.BOUND, self.BOUND, size=2)
        return real + 1j * imag

    def _random_base_function(self):
        """Returns a random function object and its corresponding lambda."""
        func = np.random.choice(list(self.BASE_FUNCTIONS.keys()))
        if func is ComplexFunction.Constant or func is Contour.Constant:
            c = self._rand()
            return func(c), lambda z, v=c: v
        else:
            return func(), self.BASE_FUNCTIONS[func]

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

class ComplexFunctionTester(FunctionTester):
    BASE_FUNCTIONS = {ComplexFunction.Constant: None,
                      ComplexFunction.Identity: lambda z: z,
                      ComplexFunction.Exp: lambda z: complex(np.exp(z)),
                      ComplexFunction.Sin: lambda z: complex(np.sin(z)),
                      ComplexFunction.Cos: lambda z: complex(np.cos(z)),
                      ComplexFunction.Tan: lambda z: complex(np.tan(z)),
                      ComplexFunction.Sec: lambda z: complex(1.) / complex(np.cos(z)),
                      ComplexFunction.Csc: lambda z: complex(1.) / complex(np.sin(z)),
                      ComplexFunction.Cot: lambda z: complex(1.) / complex(np.tan(z))}

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
                    raise ValueError(f"\033[1;41mERROR IN {type(f).__name__}:\033[0m {f.latex()}\n\t at {val}: {f_val} vs actual {cf_val}")

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

class ContourTester(ComplexFunctionTester):
    BOUND = 20.
    BASE_FUNCTIONS = {Contour.Constant: None,
                      Contour.Identity: lambda z: z,
                      Contour.Exp: lambda t: complex(np.exp(t)),
                      Contour.Sin: lambda t: complex(np.sin(t)),
                      Contour.Cos: lambda t: complex(np.cos(t)),
                      Contour.Tan: lambda t: complex(np.tan(t)),
                      Contour.Sec: lambda t: complex(1.) / complex(np.cos(t)),
                      Contour.Csc: lambda t: complex(1.) / complex(np.sin(t)),
                      Contour.Cot: lambda t: complex(1.) / complex(np.tan(t))}

    BINARY_OPERATIONS = [operator.iadd, operator.isub, operator.imul, operator.itruediv, operator.ipow,
                         operator.add, operator.sub, operator.mul, operator.truediv, operator.pow]

    def _rand(self, n=1):
        return np.random.uniform(-self.BOUND, self.BOUND, size=n)

    def _gen_function(self, n_ops=None):
        c, cc = super()._gen_function(n_ops)
        c.start, c.end = self._rand(2)
        return c, cc

class IntegralTester(FunctionTester):
    MAX_OPS = 0
    BOUND = 20.

    def __init__(self):
        self.cft = ComplexFunctionTester()
        self.ct = ContourTester()

    def _scipy_integrate(self, integrand, start, end, tol=1e-3):
        integrand_real = lambda t: np.real(integrand(t))
        integrand_imag = lambda t: np.imag(integrand(t))
        return scipy.integrate.quad(integrand_real, start, end, epsabs=tol)[0] + \
               1j * scipy.integrate.quad(integrand_imag, start, end, epsabs=tol)[0]

    def _random_contour(self):
        np.seterr(all="ignore")
        radius = abs(self.ct._rand())
        center = self.cft._rand()
        start, end = self.ct._rand(2)
        c = Contour.Sphere(radius=radius, center=center)
        c.start = start
        c.end = end
        cc = lambda t: center + radius * np.exp(1j * t)
        return c, cc

    def _run_integral(self, n_integrals):
        tol = 1e-3
        f, cf = self.cft._gen_function(self.MAX_OPS)
        for _ in range(n_integrals):
            c, cc = self._random_contour()
            dcc = lambda t: scipy.misc.derivative(cc, t, dx=tol)

            integral = integrate(f, c, tol=tol)
            cintegral = self._scipy_integrate(lambda t: cf(cc(t)) * dcc(t), c.start, c.end, tol=tol)
            print(np.allclose(integral, cintegral, rtol=tol))

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
    #args = parser.parse_args()

    tester = ComplexFunctionTester()
    tester.run(100, 10)

    tester = ContourTester()
    tester.run(100, 10)

    tester = IntegralTester()
    tester.run(2, 2)

    tester = LatexTester()
    tester.run(3)
