#pragma once
#include <complex>

namespace libcalculus {
    using namespace std::complex_literals;
    enum OP_TYPE {
        NOP, // Nothing
        FUNC, // Applying a function - sin, cos, etc.
        ADD, // Addition: (f, g) -> f + g
        SUB, // Subtraction: (f, g) -> f - g
        MUL, // Multiplication: (f, g) -> f * g
        DIV, // Division: (f, g) -> f / g
        LPOW, // Power base: (f, g) -> f ^ g
        RPOW, // Power exponent: (g, f) -> f ^ g
        MULCONST, // Multiplication by a constant: (f, a) -> a * f
        NEG, // Negation: f -> -f
        IF, // Cases
    };
    
    using REAL = double;
    using COMPLEX = std::complex<double>;
}
