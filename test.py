#!/usr/bin/env python3
from libcalculus import ComplexFunction

import numpy as np
import operator
import types
import functools
import argparse
import pqdm.processes
import multiprocessing as mp

class ValueTester:
    BOUND = 20
    MAX_OPS = 10
    MAX_TRIES = 20
    MAX_ERRORS = 20
    N_JOBS = mp.cpu_count()

    BASE_FUNCTIONS = {ComplexFunction.Constant: None,
                      ComplexFunction.Identity: lambda z: z,
                      ComplexFunction.Exp: lambda z: complex(np.exp(z)),
                      ComplexFunction.Sin: lambda z: complex(np.sin(z)),
                      ComplexFunction.Cos: lambda z: complex(np.cos(z)),
                      ComplexFunction.Tan: lambda z: complex(np.tan(z)),
                      ComplexFunction.Sec: lambda z: complex(1.) / complex(np.cos(z)),
                      ComplexFunction.Csc: lambda z: complex(1.) / complex(np.sin(z)),
                      ComplexFunction.Cot: lambda z: complex(1.) / complex(np.tan(z))}

    BINARY_OPERATIONS = [operator.iadd, operator.isub, operator.imul, operator.itruediv, operator.ipow,
                         operator.add, operator.sub, operator.mul, operator.truediv, operator.pow,
                         operator.matmul]
    UNARY_OPERATIONS = [operator.neg]
    OPERATION_TYPES = [BINARY_OPERATIONS, UNARY_OPERATIONS]

    def _crand(self):
        real, imag = np.random.uniform(-self.BOUND, self.BOUND, size=2)
        return real + 1j * imag

    def _random_base_function(self):
        """Returns a random function object and its corresponding lambda."""
        func = np.random.choice(list(self.BASE_FUNCTIONS.keys()))
        if func is ComplexFunction.Constant:
            c = self._crand()
            return func(c), lambda z, v=c: v
        else:
            return func(), self.BASE_FUNCTIONS[func]

    def _gen_function(self, n):
        """Generate a random function object with n operations of any kind."""
        func, comp_func = self._random_base_function()

        for _ in range(n):
            op_type = np.random.choice(self.OPERATION_TYPES, p=[len(entry) / sum(len(entry2) for entry2 in self.OPERATION_TYPES) for entry in self.OPERATION_TYPES])
            op = np.random.choice(op_type)
            if op_type is self.BINARY_OPERATIONS:
                operand_type = np.random.choice([0, 1], p=[.2, .8])
                if operand_type == 0 and op != operator.matmul: # Operation with a random constant:
                    operand = self._crand()
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

    def _run_func(self, n_vals):
        np.seterr(all="ignore")
        n_tries = self.MAX_TRIES + 1
        n_errors = self.MAX_ERRORS + 1
        while n_tries > self.MAX_TRIES:
            n_tries = 0
            n_errors = 0
            n_ops = np.random.randint(0, self.MAX_OPS)
            f, cf = self._gen_function(n_ops)
            for _ in range(n_vals):
                while True:
                    val = self._crand()
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
                    raise ValueError(f"\033[1;91mERROR IN FUNCTION:\033[0m {f.latex()}\n\t at {val}: {f_val} vs actual {cf_val}")

                if n_tries > self.MAX_TRIES:
                    break

    def run(self, n_funcs, n_vals):
        """Generate n_funcs random functions and check them on n_values values."""
        pqdm.processes.pqdm([n_vals] * n_funcs, self._run_func, n_jobs=self.N_JOBS, exception_behaviour="immediate")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Test suite for libcalculus.")
    parser.add_argument("n_funcs", help="Number of random functions to generate", nargs="?", default=5000, type=int)
    parser.add_argument("n_vals", help="Number of inputs to check on each function", nargs="?", default=20, type=int)
    args = parser.parse_args()

    tester = ValueTester()
    tester.run(args.n_funcs, args.n_vals)
