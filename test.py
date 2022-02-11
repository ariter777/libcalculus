from libcalculus import ComplexFunction

import numpy as np
import operator
import types
import functools
import argparse
import tqdm

np.seterr(all="ignore")
BOUND = 20
MAX_OPS = 6
MAX_TRIES = 20
MAX_ERRORS = 20

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

def _crand():
    real, imag = np.random.uniform(-BOUND, BOUND, size=2)
    return real + 1j * imag

def _copy_func(f):
    g = types.FunctionType(f.__code__, f.__globals__, name=f.__name__,
                           argdefs=f.__defaults__,
                           closure=f.__closure__)
    g = functools.update_wrapper(g, f)
    g.__kwdefaults__ = f.__kwdefaults__
    return g

def _random_base_function():
    """Returns a random function object and its corresponding lambda."""
    func = np.random.choice(list(BASE_FUNCTIONS.keys()))
    if func is ComplexFunction.Constant:
        c = _crand()
        return func(c), lambda z, v=c: v
    else:
        return func(), BASE_FUNCTIONS[func]

def gen_function(n):
    """Generate a random function object with n operations of any kind."""
    func, comp_func = _random_base_function()

    for _ in range(n):
        op_type = np.random.choice(OPERATION_TYPES, p=[len(entry) / sum(len(entry2) for entry2 in OPERATION_TYPES) for entry in OPERATION_TYPES])
        op = np.random.choice(op_type)
        if op_type is BINARY_OPERATIONS:
            operand_type = np.random.choice([0, 1], p=[.2, .8])
            if operand_type == 0 and op != operator.matmul: # Operation with a random constant:
                operand = _crand()
                comp_operand = lambda z, v=operand: v
            else:
                operand, comp_operand = _random_base_function()
            order = np.random.choice([-1, 1])
            func = op(*[func, operand][::order])
            if op != operator.matmul:
                comp_func = lambda z, op_=op, comp_func_=comp_func, comp_operand_=comp_operand, order_=order: op_(*[comp_func_(z), comp_operand_(z)][::order_])
            else:
                comp_func = lambda z, op_=op, comp_func_=comp_func, comp_operand_=comp_operand, order_=order: \
                                comp_func_(comp_operand_(z)) if order_ == 1 else comp_operand_(comp_func_(z))

        elif op_type is UNARY_OPERATIONS:
            func = op(func)
            comp_func = lambda z, op_=op, comp_func_=comp_func: op_(comp_func_(z))
    return func, comp_func

def run_test(n_funcs, n_vals):
    """Generate n_funcs random functions and check them on n_values values."""
    for _ in tqdm.trange(n_funcs):
        n_tries = MAX_TRIES + 1
        n_errors = MAX_ERRORS + 1
        while n_tries > MAX_TRIES:
            n_tries = 0
            n_errors = 0
            n_ops = np.random.randint(0, MAX_OPS)
            f, cf = gen_function(n_ops)
            for __ in range(n_vals):
                while True:
                    val = _crand()
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
                        if n_tries > MAX_TRIES: # We've hit a functional division by zero (e.g. 1 / (z - z)):
                            break

                if n_errors >= MAX_ERRORS:
                    print(f"ERROR IN FUNCTION: {f.latex()}\n\t at {val}: {f_val} vs actual {cf_val}")
                    return

                if n_tries > MAX_TRIES:
                    break

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Test suite for libcalculus.")
    parser.add_argument("n_funcs", help="Number of random functions to generate", default=200, type=int)
    parser.add_argument("n_vals", help="Number of inputs to check on each function", default=20, type=int)
    args = parser.parse_args()
    run_test(args.n_funcs, args.n_vals)
