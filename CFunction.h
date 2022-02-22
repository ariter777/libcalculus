#pragma once
#include <iostream>
#include <iomanip>
#include <complex>
#include <functional>
#include <string>
#include <sstream>
#include <regex>
#include "Latex.h"
#include "CComparison.h"

namespace libcalculus {
    using namespace std::complex_literals;
    #define LATEX_VAR "%var"

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

    template <typename Dom, typename Ran>
    class CFunction {
        using function = std::function<Ran(Dom)>;
    private:
        function _f = [](Dom z) { return z; };
        std::string _latex = LATEX_VAR;
        OP_TYPE _last_op = OP_TYPE::NOP;
        template<typename, typename> friend class CFunction;
    public:
        CFunction() {}
        CFunction(function const &f) : _f{f} {}
        CFunction(function const &f, std::string const &latex, OP_TYPE last_op) : _f{f}, _latex{latex}, _last_op{last_op} {}
        Ran operator()(Dom z) const;
        std::string latex(std::string const &varname = "z") const;

        /* Function composition */
        template<typename Predom> CFunction<Predom, Ran> compose(CFunction<Predom, Dom> const &rhs) const;

        /* In-place function-with-function operators */
        CFunction<Dom, Ran> &operator+=(CFunction<Dom, Ran> const &rhs);
        CFunction<Dom, Ran> &operator-=(CFunction<Dom, Ran> const &rhs);
        CFunction<Dom, Ran> &operator*=(CFunction<Dom, Ran> const &rhs);
        CFunction<Dom, Ran> &operator/=(CFunction<Dom, Ran> const &rhs);

        /* In-place function-with-constant operators */
        CFunction<Dom, Ran> &operator+=(Ran const c);
        CFunction<Dom, Ran> &operator-=(Ran const c);
        CFunction<Dom, Ran> &operator*=(Ran const c);
        CFunction<Dom, Ran> &operator/=(Ran const c);

        /* Function additive inverse */
        CFunction<Dom, Ran> operator-() const;

        /* Function-with-function operators */
        inline CFunction<Dom, Ran> operator+(CFunction<Dom, Ran> const &rhs) const { return CFunction(*this) += rhs; }
        inline CFunction<Dom, Ran> operator-(CFunction<Dom, Ran> const &rhs) const { return CFunction(*this) -= rhs; }
        inline CFunction<Dom, Ran> operator*(CFunction<Dom, Ran> const &rhs) const { return CFunction(*this) *= rhs; }
        inline CFunction<Dom, Ran> operator/(CFunction<Dom, Ran> const &rhs) const { return CFunction(*this) /= rhs; }
        CFunction<Dom, Ran> pow(CFunction<Dom, Ran> const &rhs) const;

        /* Function-with-constant operators */
        template<typename Dom_, typename Ran_> friend CFunction<Dom_, Ran_> operator+(CFunction<Dom_, Ran_> const &lhs, Ran rhs);
        template<typename Dom_, typename Ran_> friend CFunction<Dom_, Ran_> operator-(CFunction<Dom_, Ran_> const &lhs, Ran rhs);
        template<typename Dom_, typename Ran_> friend CFunction<Dom_, Ran_> operator*(CFunction<Dom_, Ran_> const &lhs, Ran rhs);
        template<typename Dom_, typename Ran_> friend CFunction<Dom_, Ran_> operator/(CFunction<Dom_, Ran_> const &lhs, Ran rhs);
        CFunction<Dom, Ran> pow(Ran const c) const;

        /* Constant-with-function operators */
        template<typename Dom_, typename Ran_> friend CFunction<Dom_, Ran_> operator-(Ran_ lhs, CFunction<Dom_, Ran_> const &rhs);
        template<typename Dom_, typename Ran_> friend CFunction<Dom_, Ran_> operator/(Ran_ lhs, CFunction<Dom_, Ran_> const &rhs);
        CFunction<Dom, Ran> lpow(Ran const c) const;

        /* Comparison operators */
        CComparison<Dom, Ran> operator>(CFunction<Dom, Ran> const &rhs) const;
        CComparison<Dom, Ran> operator<(CFunction<Dom, Ran> const &rhs) const;
        CComparison<Dom, Ran> operator==(CFunction<Dom, Ran> const &rhs) const;
        CComparison<Dom, Ran> operator>=(CFunction<Dom, Ran> const &rhs) const;
        CComparison<Dom, Ran> operator<=(CFunction<Dom, Ran> const &rhs) const;
        CComparison<Dom, Ran> operator!=(CFunction<Dom, Ran> const &rhs) const;

        /* Preset instances */
        static CFunction<Dom, Ran> Constant(Ran const c) { return CFunction([=](Dom z) { return c; }, Latex::fmt_const(c, false), OP_TYPE::NOP); }
        static CFunction<Dom, Ran> Re() { return CFunction([=](Dom z) { return std::real(z); }, "\\text{Re}\\left(" LATEX_VAR "\\right)", OP_TYPE::FUNC); }
        static CFunction<Dom, Ran> Im() { return CFunction([=](Dom z) { return std::imag(z); }, "\\text{Im}\\left(" LATEX_VAR "\\right)", OP_TYPE::FUNC); }
        static CFunction<Dom, Ran> Abs() { return CFunction([=](Dom z) { return std::abs(z); }, "\\left|" LATEX_VAR "\\right|", OP_TYPE::FUNC); }

        static CFunction<Dom, Ran> Exp() { return CFunction([](Dom z) { return std::exp(z); }, "e^{" LATEX_VAR "}", OP_TYPE::NOP); }
        static CFunction<Dom, Ran> Sin() { return CFunction([](Dom z) { return std::sin(z); }, "\\sin\\left(" LATEX_VAR "\\right)", OP_TYPE::FUNC); }
        static CFunction<Dom, Ran> Cos() { return CFunction([](Dom z) { return std::cos(z); }, "\\cos\\left(" LATEX_VAR "\\right)", OP_TYPE::FUNC); }
        static CFunction<Dom, Ran> Tan() { return CFunction([](Dom z) { return std::tan(z); }, "\\tan\\left(" LATEX_VAR "\\right)", OP_TYPE::FUNC); }
        static CFunction<Dom, Ran> Sec() { return CFunction([](Dom z) { return 1. / std::cos(z); }, "\\sec\\left(" LATEX_VAR "\\right)", OP_TYPE::FUNC); }
        static CFunction<Dom, Ran> Csc() { return CFunction([](Dom z) { return 1. / std::sin(z); }, "\\csc\\left(" LATEX_VAR "\\right)", OP_TYPE::FUNC); }
        static CFunction<Dom, Ran> Cot() { return CFunction([](Dom z) { return 1. / std::tan(z); }, "\\cot\\left(" LATEX_VAR "\\right)", OP_TYPE::FUNC); }
        static CFunction<Dom, Ran> Pi() { return CFunction([](Dom z) { return M_PI; }, "\\pi", OP_TYPE::NOP); }
        static CFunction<Dom, Ran> E() { return CFunction([](Dom z) { return M_E; }, "e", OP_TYPE::NOP); }

        static CFunction<Dom, Ran> If(CComparison<Dom, Ran> const &cond_, CFunction<Dom, Ran> const &then_,
                                      CFunction<Dom, Ran> const &else_ = CFunction<Dom, Ran>::Constant(Ran{0})) {
              std::string new_latex = "\\begin{cases} ";
              new_latex.append(then_._latex);
              new_latex.append(" & ;\\;");
              new_latex.append(cond_.latex);
              new_latex.append(" \\\\ ");
              new_latex.append(else_._latex);
              new_latex.append(" & ;\\;\\text{else}\\end{cases} ");
              return CFunction([cond__ = cond_.eval, then__ = then_._f, else__ = else_._f](Dom z) { return cond__(z) ? then__(z) : else__(z); },
                               new_latex, OP_TYPE::IF);
        }
    };
}
