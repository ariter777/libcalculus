#include "CFunction.h"

namespace libcalculus {
    dtype CFunction::operator()(dtype z) const {
        return this->_f(z);
    }

    std::string CFunction::latex(std::string const &varname) const {
        return std::regex_replace(this->_latex, std::regex(LATEX_VAR), varname);
    }

    CFunction CFunction::compose(CFunction const &rhs) const {
        auto const lhs_f = this->_f, rhs_f = rhs._f;

        std::string new_latex = std::regex_replace(this->_latex, std::regex(LATEX_VAR),
                                CFunction::parenthesize_if(rhs._latex, OP_TYPE::FUNCTION, rhs._last_op));
        return CFunction([=](dtype z) { return lhs_f(rhs_f(z)); }, new_latex, this->_last_op);
    }

    CFunction CFunction::operator+(CFunction const &rhs) const {
        auto const lhs_f = this->_f, rhs_f = rhs._f;
        std::string new_latex = CFunction::parenthesize_if(this->_latex, OP_TYPE::ADD, this->_last_op);
        new_latex.append(" + ");
        new_latex.append(CFunction::parenthesize_if(rhs._latex, OP_TYPE::ADD, rhs._last_op));
        return CFunction([=](dtype z) { return lhs_f(z) + rhs_f(z); }, new_latex, OP_TYPE::ADD);
    }

    CFunction CFunction::operator-(CFunction const &rhs) const {
        auto const lhs_f = this->_f, rhs_f = rhs._f;
        std::string new_latex = CFunction::parenthesize_if(this->_latex, OP_TYPE::SUB, this->_last_op);
        new_latex.append(" - ");
        new_latex.append(CFunction::parenthesize_if(rhs._latex, OP_TYPE::SUB, rhs._last_op));
        return CFunction([=](dtype z) { return lhs_f(z) - rhs_f(z); }, new_latex, OP_TYPE::SUB);
    }

    CFunction CFunction::operator*(CFunction const &rhs) const {
        auto const lhs_f = this->_f, rhs_f = rhs._f;
        std::string new_latex = CFunction::parenthesize_if(this->_latex, OP_TYPE::MUL, this->_last_op);
        if (rhs._last_op == OP_TYPE::MULCONST) new_latex.append(" \\cdot ");
        new_latex.append(CFunction::parenthesize_if(rhs._latex, OP_TYPE::MUL, rhs._last_op));
        return CFunction([=](dtype z) { return lhs_f(z) * rhs_f(z); }, new_latex, OP_TYPE::MUL);
    }

    CFunction CFunction::operator/(CFunction const &rhs) const {
        auto const lhs_f = this->_f, rhs_f = rhs._f;
        std::string new_latex = " \\frac{";
        new_latex.append(CFunction::parenthesize_if(this->_latex, OP_TYPE::DIV, this->_last_op));
        new_latex.append("}{");
        new_latex.append(CFunction::parenthesize_if(rhs._latex, OP_TYPE::DIV, rhs._last_op));
        new_latex.append("}");
        return CFunction([=](dtype z) { return lhs_f(z) / rhs_f(z); }, new_latex, OP_TYPE::DIV);
    }

    CFunction CFunction::pow(CFunction const &rhs) const {
        auto const lhs_f = this->_f, rhs_f = rhs._f;
        std::string new_latex = "{";
        new_latex.append(CFunction::parenthesize_if(this->_latex, OP_TYPE::LPOW, this->_last_op));
        new_latex.append("}^{");
        new_latex.append(CFunction::parenthesize_if(rhs._latex, OP_TYPE::RPOW, rhs._last_op));
        new_latex.append("}");
        return CFunction([=](dtype z) { return std::pow(lhs_f(z), rhs_f(z)); }, new_latex, OP_TYPE::LPOW);
    }

    CFunction CFunction::addconst(dtype a) const {
        auto const old_f = this->_f;
        std::string new_latex = this->_latex;
        new_latex.append(" + ");
        new_latex.append(CFunction::fmt_const(a, false));
        return CFunction([=](dtype z) { return old_f(z) + a; }, new_latex, OP_TYPE::ADD);
    }

    CFunction CFunction::subconst(dtype a) const {
        auto const old_f = this->_f;
        std::string new_latex = this->_latex;
        new_latex.append(" - ");
        new_latex.append(CFunction::fmt_const(a, false));
        return CFunction([=](dtype z) { return old_f(z) - a; }, new_latex, OP_TYPE::SUB);
    }

    CFunction CFunction::lsubconst(dtype a) const {
        auto const old_f = this->_f;
        std::string new_latex = CFunction::fmt_const(a, false);
        new_latex.append(" - ");
        new_latex.append(this->_latex);
        return CFunction([=](dtype z) { return a - old_f(z); }, new_latex, OP_TYPE::SUB);
    }

    CFunction CFunction::mulconst(dtype a) const {
        auto const old_f = this->_f;
        std::string new_latex = CFunction::fmt_const(a, true);
        if (this->_last_op == OP_TYPE::MULCONST) new_latex.append(" \\cdot ");
        new_latex.append(CFunction::parenthesize_if(this->_latex, OP_TYPE::MUL, this->_last_op));
        return CFunction([=](dtype z) { return a * old_f(z); }, new_latex, OP_TYPE::MULCONST);
    }

    CFunction CFunction::divconst(dtype a) const {
        auto const old_f = this->_f;
        std::string new_latex = " \\frac{";
        new_latex.append(CFunction::parenthesize_if(this->_latex, OP_TYPE::DIV, this->_last_op));
        new_latex.append("}{");
        new_latex.append(CFunction::fmt_const(a, false));
        new_latex.append("}");
        return CFunction([=](dtype z) { return old_f(z) / a; }, new_latex, OP_TYPE::DIV);
    }

    CFunction CFunction::ldivconst(dtype a) const {
        auto const old_f = this->_f;
        std::string new_latex = " \\frac{";
        new_latex.append(CFunction::fmt_const(a, false));
        new_latex.append("}{");
        new_latex.append(CFunction::parenthesize_if(this->_latex, OP_TYPE::DIV, this->_last_op));
        new_latex.append("}");
        return CFunction([=](dtype z) { return a / old_f(z); }, new_latex, OP_TYPE::DIV);
    }

    CFunction CFunction::powconst(dtype a) const {
        auto const old_f = this->_f;
        std::string new_latex = "{";
        new_latex.append(CFunction::parenthesize_if(this->_latex, OP_TYPE::LPOW, this->_last_op));
        new_latex.append("}^{");
        new_latex.append(CFunction::fmt_const(a, false));
        new_latex.append("}");
        return CFunction([=](dtype z) { return std::pow(old_f(z), a); }, new_latex, OP_TYPE::LPOW);
    }

    CFunction CFunction::lpowconst(dtype a) const {
        auto const old_f = this->_f;
        return CFunction([=](dtype z) { return std::pow(a, old_f(z)); });
    }
}
