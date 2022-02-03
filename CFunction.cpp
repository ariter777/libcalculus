#include "CFunction.h"

namespace libcalculus {
    template<typename Dom, typename Ran>
    Ran CFunction<Dom, Ran>::operator()(Dom z) const {
        return this->_f(z);
    }

    template<typename Dom, typename Ran>
    std::string CFunction<Dom, Ran>::latex(std::string const &varname) const {
        return std::regex_replace(this->_latex, std::regex(LATEX_VAR), varname);
    }

    template<typename Dom, typename Ran>
    template<typename Predom>
    CFunction<Predom, Ran> CFunction<Dom, Ran>::compose(CFunction<Predom, Dom> const &rhs) const {
        auto const lhs_f = this->_f, rhs_f = rhs._f;

        std::string new_latex = std::regex_replace(this->_latex, std::regex(LATEX_VAR),
                                Latex::parenthesize_if(rhs._latex, OP_TYPE::FUNCTION, rhs._last_op));
        return CFunction<Predom, Ran>([=](Predom z) { return lhs_f(rhs_f(z)); }, new_latex, this->_last_op);
    }

    template<typename Dom, typename Ran>
    CFunction<Dom, Ran> CFunction<Dom, Ran>::operator+(CFunction const &rhs) const {
        auto const lhs_f = this->_f, rhs_f = rhs._f;
        std::string new_latex = Latex::parenthesize_if(this->_latex, OP_TYPE::ADD, this->_last_op);
        new_latex.append(" + ");
        new_latex.append(Latex::parenthesize_if(rhs._latex, OP_TYPE::ADD, rhs._last_op));
        return CFunction([=](Dom z) { return lhs_f(z) + rhs_f(z); }, new_latex, OP_TYPE::ADD);
    }

    template<typename Dom, typename Ran>
    CFunction<Dom, Ran> CFunction<Dom, Ran>::operator-(CFunction const &rhs) const {
        auto const lhs_f = this->_f, rhs_f = rhs._f;
        std::string new_latex = Latex::parenthesize_if(this->_latex, OP_TYPE::SUB, this->_last_op);
        new_latex.append(" - ");
        new_latex.append(Latex::parenthesize_if(rhs._latex, OP_TYPE::SUB, rhs._last_op));
        return CFunction([=](Dom z) { return lhs_f(z) - rhs_f(z); }, new_latex, OP_TYPE::SUB);
    }

    template<typename Dom, typename Ran>
    CFunction<Dom, Ran> CFunction<Dom, Ran>::operator*(CFunction const &rhs) const {
        auto const lhs_f = this->_f, rhs_f = rhs._f;
        std::string new_latex = Latex::parenthesize_if(this->_latex, OP_TYPE::MUL, this->_last_op);
        if (rhs._last_op == OP_TYPE::MULCONST) new_latex.append(" \\cdot ");
        new_latex.append(Latex::parenthesize_if(rhs._latex, OP_TYPE::MUL, rhs._last_op));
        return CFunction([=](Dom z) { return lhs_f(z) * rhs_f(z); }, new_latex, OP_TYPE::MUL);
    }

    template<typename Dom, typename Ran>
    CFunction<Dom, Ran> CFunction<Dom, Ran>::operator/(CFunction const &rhs) const {
        auto const lhs_f = this->_f, rhs_f = rhs._f;
        std::string new_latex = " \\frac{";
        new_latex.append(Latex::parenthesize_if(this->_latex, OP_TYPE::DIV, this->_last_op));
        new_latex.append("}{");
        new_latex.append(Latex::parenthesize_if(rhs._latex, OP_TYPE::DIV, rhs._last_op));
        new_latex.append("}");
        return CFunction([=](Dom z) { return lhs_f(z) / rhs_f(z); }, new_latex, OP_TYPE::DIV);
    }

    template<typename Dom, typename Ran>
    CFunction<Dom, Ran> CFunction<Dom, Ran>::pow(CFunction const &rhs) const {
        auto const lhs_f = this->_f, rhs_f = rhs._f;
        std::string new_latex = "{";
        new_latex.append(Latex::parenthesize_if(this->_latex, OP_TYPE::LPOW, this->_last_op));
        new_latex.append("}^{");
        new_latex.append(Latex::parenthesize_if(rhs._latex, OP_TYPE::RPOW, rhs._last_op));
        new_latex.append("}");
        return CFunction([=](Dom z) { return std::pow(lhs_f(z), rhs_f(z)); }, new_latex, OP_TYPE::LPOW);
    }

    template<typename Dom, typename Ran>
    CFunction<Dom, Ran> CFunction<Dom, Ran>::addconst(Ran a) const {
        auto const old_f = this->_f;
        std::string new_latex = this->_latex;
        new_latex.append(" + ");
        new_latex.append(Latex::fmt_const(a, false));
        return CFunction([=](Dom z) { return old_f(z) + a; }, new_latex, OP_TYPE::ADD);
    }

    template<typename Dom, typename Ran>
    CFunction<Dom, Ran> CFunction<Dom, Ran>::subconst(Ran a) const {
        auto const old_f = this->_f;
        std::string new_latex = this->_latex;
        new_latex.append(" - ");
        new_latex.append(Latex::fmt_const(a, false));
        return CFunction([=](Dom z) { return old_f(z) - a; }, new_latex, OP_TYPE::SUB);
    }

    template<typename Dom, typename Ran>
    CFunction<Dom, Ran> CFunction<Dom, Ran>::lsubconst(Ran a) const {
        auto const old_f = this->_f;
        std::string new_latex = Latex::fmt_const(a, false);
        new_latex.append(" - ");
        new_latex.append(this->_latex);
        return CFunction([=](Dom z) { return a - old_f(z); }, new_latex, OP_TYPE::SUB);
    }

    template<typename Dom, typename Ran>
    CFunction<Dom, Ran> CFunction<Dom, Ran>::mulconst(Ran a) const {
        auto const old_f = this->_f;
        std::string new_latex = Latex::fmt_const(a, true);
        if (this->_last_op == OP_TYPE::MULCONST) new_latex.append(" \\cdot ");
        new_latex.append(Latex::parenthesize_if(this->_latex, OP_TYPE::MUL, this->_last_op));
        return CFunction([=](Dom z) { return a * old_f(z); }, new_latex, OP_TYPE::MULCONST);
    }

    template<typename Dom, typename Ran>
    CFunction<Dom, Ran> CFunction<Dom, Ran>::divconst(Ran a) const {
        auto const old_f = this->_f;
        std::string new_latex = " \\frac{";
        new_latex.append(Latex::parenthesize_if(this->_latex, OP_TYPE::DIV, this->_last_op));
        new_latex.append("}{");
        new_latex.append(Latex::fmt_const(a, false));
        new_latex.append("}");
        return CFunction([=](Dom z) { return old_f(z) / a; }, new_latex, OP_TYPE::DIV);
    }

    template<typename Dom, typename Ran>
    CFunction<Dom, Ran> CFunction<Dom, Ran>::ldivconst(Ran a) const {
        auto const old_f = this->_f;
        std::string new_latex = " \\frac{";
        new_latex.append(Latex::fmt_const(a, false));
        new_latex.append("}{");
        new_latex.append(Latex::parenthesize_if(this->_latex, OP_TYPE::DIV, this->_last_op));
        new_latex.append("}");
        return CFunction([=](Dom z) { return a / old_f(z); }, new_latex, OP_TYPE::DIV);
    }

    template<typename Dom, typename Ran>
    CFunction<Dom, Ran> CFunction<Dom, Ran>::powconst(Ran a) const {
        auto const old_f = this->_f;
        std::string new_latex = "{";
        new_latex.append(Latex::parenthesize_if(this->_latex, OP_TYPE::LPOW, this->_last_op));
        new_latex.append("}^{");
        new_latex.append(Latex::fmt_const(a, false));
        new_latex.append("}");
        return CFunction([=](Dom z) { return std::pow(old_f(z), a); }, new_latex, OP_TYPE::LPOW);
    }

    template<typename Dom, typename Ran>
    CFunction<Dom, Ran> CFunction<Dom, Ran>::lpowconst(Ran a) const {
        auto const old_f = this->_f;
        std::string new_latex = "{";
        new_latex.append(Latex::fmt_const(a, false));
        new_latex.append("}^{");
        new_latex.append(Latex::parenthesize_if(this->_latex, OP_TYPE::LPOW, this->_last_op));
        new_latex.append("}");
        return CFunction([=](Dom z) { return std::pow(a, old_f(z)); }, new_latex, OP_TYPE::LPOW);
    }
}
