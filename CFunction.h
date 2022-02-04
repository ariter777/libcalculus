#pragma once
#ifndef CFUNCTION_H
#define CFUNCTION_H
#include <iostream>
#include <iomanip>
#include <complex>
#include <functional>
#include <string>
#include <sstream>
#include <regex>

namespace libcalculus {
    using namespace std::complex_literals;
    #define LATEX_VAR "%var"

    enum OP_TYPE {
        NOP, // Nothing
        FUNCTION, // Applying a function - sin, cos, etc.
        ADD, // Addition
        SUB, // Subtraction
        MUL, // Multiplication
        DIV, // Division
        LPOW, // Power base
        RPOW, // Power exponent
        MULCONST, // Multiplication by a constant
    };

    namespace Latex {
        std::string _parenthesize(std::string const &expr);
        template<typename T> std::string fmt_const(T a, bool parenthesize = false);
    }

    template <typename Dom, typename Ran>
    class CFunction {
        using function = std::function<Ran(Dom)>;
    private:
        function _f = [](Dom z) { return z; };
        std::string _latex = LATEX_VAR;
        char _last_op = OP_TYPE::NOP;
        template<typename Dom2, typename Ran2> friend class CFunction;
    public:
        CFunction() {}
        CFunction(function f) : _f{f} {}
        CFunction(CFunction const &cf) : _f{cf._f}, _latex{cf._latex}, _last_op{cf._last_op} {}
        CFunction(function f, std::string const &latex, char last_op) : _f{f}, _latex{latex}, _last_op{last_op} {}
        Ran operator()(Dom z) const;
        std::string latex(std::string const &varname = "z") const;

        template<typename Predom> CFunction<Predom, Ran> compose(CFunction<Predom, Dom> const &rhs) const;
        CFunction<Dom, Ran> operator+(CFunction<Dom, Ran> const &rhs) const;
        CFunction<Dom, Ran> operator-(CFunction<Dom, Ran> const &rhs) const;
        CFunction<Dom, Ran> operator*(CFunction<Dom, Ran> const &rhs) const;
        CFunction<Dom, Ran> operator/(CFunction<Dom, Ran> const &rhs) const;
        CFunction<Dom, Ran> pow(CFunction<Dom, Ran> const &rhs) const;

        CFunction<Dom, Ran> addconst(Ran a) const;
        CFunction<Dom, Ran> subconst(Ran a) const;
        CFunction<Dom, Ran> lsubconst(Ran a) const;
        CFunction<Dom, Ran> divconst(Ran a) const;
        CFunction<Dom, Ran> ldivconst(Ran a) const;
        CFunction<Dom, Ran> mulconst(Ran a) const;
        CFunction<Dom, Ran> powconst(Ran a) const;
        CFunction<Dom, Ran> lpowconst(Ran a) const;

        static CFunction<Dom, Ran> Exp() { return CFunction<Dom, Ran>([](Dom z) { return std::exp(z); }, "e^{" LATEX_VAR "}", 0); }
        static CFunction<Dom, Ran> Sin() { return CFunction([](Dom z) { return std::sin(z); }, "\\sin\\left(" LATEX_VAR "\\right)", 0); }
        static CFunction<Dom, Ran> Cos() { return CFunction([](Dom z) { return std::cos(z); }, "\\cos\\left(" LATEX_VAR "\\right)", 0); }
        static CFunction<Dom, Ran> Tan() { return CFunction([](Dom z) { return std::tan(z); }, "\\tan\\left(" LATEX_VAR "\\right)", 0); }
        static CFunction<Dom, Ran> Sec() { return CFunction([](Dom z) { return 1. / std::cos(z); }, "\\sec\\left(" LATEX_VAR "\\right)", 0); }
        static CFunction<Dom, Ran> Csc() { return CFunction([](Dom z) { return 1. / std::sin(z); }, "\\csc\\left(" LATEX_VAR "\\right)", 0); }
        static CFunction<Dom, Ran> Cot() { return CFunction([](Dom z) { return 1. / std::tan(z); }, "\\cot\\left(" LATEX_VAR "\\right)", 0); }
        static CFunction<Dom, Ran> Pi() { return CFunction([](Dom z) { return M_PI; }, "\\pi", OP_TYPE::NOP); }
        static CFunction<Dom, Ran> E() { return CFunction([](Dom z) { return M_E; }, "e", OP_TYPE::NOP); }
    };
}
#endif
