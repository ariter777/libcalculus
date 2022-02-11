from libcalculus import ComplexFunction

import numpy as np
import operator

BOUND = 1000.

BASE_FUNCTIONS = [ComplexFunction.Constant, ComplexFunction.Identity, ComplexFunction.Exp,
                  ComplexFunction.Sin, ComplexFunction.Cos, ComplexFunction.Tan,
                  ComplexFunction.Sec, ComplexFunction.Csc, ComplexFunction.Cot]
BINARY_OPERATIONS = [operator.iadd, operator.isub, operator.imul, operator.itruediv, operator.pow,
                     operator.add, operator.sub, operator.mul, operator.truediv, operator.ipow,
                     operator.matmul]
UNARY_OPERATIONS = [operator.neg]
OPERATION_TYPES = [BINARY_OPERATIONS, UNARY_OPERATIONS]

def _crand():
    real, imag = np.random.uniform(-BOUND, BOUND, size=2)
    return real + 1j * imag

def _random_base_function():
    result = np.random.choice(BASE_FUNCTIONS)
    if result is ComplexFunction.Constant:
        return result(_crand())
    else:
        return result()

def gen_function(n):
    """Generate a random function object with n operations of any kind."""
    result = _random_base_function()

    while n > 0:
        op_type = np.random.choice(OPERATION_TYPES, p=[len(entry) / sum(len(entry2) for entry2 in OPERATION_TYPES) for entry in OPERATION_TYPES])
        op = np.random.choice(op_type)
        if op_type is BINARY_OPERATIONS:
            operand_type = np.random.choice([0, 1], p=[.2, .8])
            if operand_type == 0: # Operation with a random constant:
                operand = _crand()
            elif operand_type == 1:
                operand = _random_base_function()
            order = np.random.choice([-1, 1])
            result = op(*[result, operand][::order])
        elif op_type is UNARY_OPERATIONS:
            result = op(result)
        n -= 1
    return result
