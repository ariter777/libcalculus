#ifndef CFUNCTION_H
#define CFUNCTION_H
#include <iostream>
#include <complex>
#include <functional>
#include <string>
#include <regex>

namespace libcalculus {
    using namespace std::complex_literals;
    using dtype = std::complex<double>;
    using function = std::function<dtype(dtype)>;
    #define LATEX_VAR "%var"

    enum OP_TYPE {
        FUNCTION, // Applying a function - sin, cos, etc.
        ADD, // Addition
        SUB, // Subtraction
        MUL, // Multiplication
        DIV, // Division
        LPOW, // Power base
        RPOW, // Power exponent
    };

    class CFunction {
    private:
        function _f = [](dtype z) { return z; };
        std::string _latex = LATEX_VAR;
        char _last_op = 0;

        static std::string _parenthesize(std::string const &expr) {
            std::string result = "(";
            result.append(expr);
            result.append(")");
            return result;
        }

        static std::string parenthesize_if(std::string const &expr, char new_op, char last_op) {
            if (new_op == OP_TYPE::FUNCTION || new_op == OP_TYPE::DIV) return expr;
            else if ((last_op == OP_TYPE::ADD || last_op == OP_TYPE::SUB) && (new_op == OP_TYPE::MUL || new_op == OP_TYPE::LPOW))
                return CFunction::_parenthesize(expr);
            else return expr;
        }
    public:
        CFunction() {}
        CFunction(function f) : _f{f} {}
        CFunction(CFunction const &cf) : _f{cf._f}, _latex{cf._latex}, _last_op{cf._last_op} {}
        CFunction(function f, std::string const &latex, char last_op) : _f{f}, _latex{latex}, _last_op{last_op} {}
        dtype operator()(dtype z) const;
        std::string latex(std::string const &varname = "z") const;

        CFunction compose(CFunction const &rhs) const noexcept;
        CFunction operator+(CFunction const &rhs) const noexcept;
        CFunction operator-(CFunction const &rhs) const noexcept;
        CFunction operator*(CFunction const &rhs) const noexcept;
        CFunction operator/(CFunction const &rhs) const noexcept;
        CFunction pow(CFunction const &rhs) const noexcept;
        CFunction reciprocal() const noexcept;

        CFunction addconst(dtype a) const noexcept;
        CFunction mulconst(dtype a) const noexcept;
        CFunction powconst(dtype a) const noexcept;
        CFunction lpowconst(dtype a) const noexcept;

        static CFunction Exp() { return CFunction([](dtype z) { return std::exp(z); }, "e^{" LATEX_VAR "}", 0); }
        static CFunction Sin() { return CFunction([](dtype z) { return std::sin(z); }, "\\sin\\left(" LATEX_VAR "\\right)", 0); }
        static CFunction Cos() { return CFunction([](dtype z) { return std::cos(z); }, "\\cos\\left(" LATEX_VAR "\\right)", 0); }
        static CFunction Tan() { return CFunction([](dtype z) { return std::tan(z); }, "\\tan\\left(" LATEX_VAR "\\right)", 0); }
        static CFunction Sec() { return CFunction([](dtype z) { return 1. / std::cos(z); }, "\\sec\\left(" LATEX_VAR "\\right)", 0); }
        static CFunction Csc() { return CFunction([](dtype z) { return 1. / std::sin(z); }, "\\csc\\left(" LATEX_VAR "\\right)", 0); }
        static CFunction Cot() { return CFunction([](dtype z) { return 1. / std::tan(z); }, "\\cot\\left(" LATEX_VAR "\\right)", 0); }
    };
}
#endif
