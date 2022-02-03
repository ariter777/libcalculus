#include "CFunction.h"

namespace libcalculus {
    dtype CFunction::operator()(dtype z) const {
        return this->_f(z);
    }

    std::string CFunction::latex(std::string const &varname) const {
        std::cout << varname << std::endl;
        return std::regex_replace(this->_latex, std::regex(LATEX_VAR), varname);
    }

    CFunction CFunction::compose(CFunction const &rhs) const noexcept {
        auto const lhs_f = this->_f, rhs_f = rhs._f;

        std::string new_latex = std::regex_replace(this->_latex, std::regex(LATEX_VAR),
                                CFunction::parenthesize_if(rhs._latex, OP_TYPE::FUNCTION, rhs._last_op));
        return CFunction([=](dtype z) { return lhs_f(rhs_f(z)); }, new_latex, this->_last_op);
    }

    CFunction CFunction::operator+(CFunction const &rhs) const noexcept {
        auto const lhs_f = this->_f, rhs_f = rhs._f;
        std::string new_latex = CFunction::parenthesize_if(this->_latex, OP_TYPE::ADD, this->_last_op);
        new_latex.append(" + ");
        new_latex.append(CFunction::parenthesize_if(rhs._latex, OP_TYPE::ADD, rhs._last_op));
        return CFunction([=](dtype z) { return lhs_f(z) + rhs_f(z); }, new_latex, OP_TYPE::ADD);
    }

    CFunction CFunction::operator-(CFunction const &rhs) const noexcept {
        auto const lhs_f = this->_f, rhs_f = rhs._f;
        std::string new_latex = CFunction::parenthesize_if(this->_latex, OP_TYPE::SUB, this->_last_op);
        new_latex.append(" - ");
        new_latex.append(CFunction::parenthesize_if(rhs._latex, OP_TYPE::SUB, rhs._last_op));
        return CFunction([=](dtype z) { return lhs_f(z) - rhs_f(z); }, new_latex, OP_TYPE::SUB);
    }

    CFunction CFunction::operator*(CFunction const &rhs) const noexcept {
        auto const lhs_f = this->_f, rhs_f = rhs._f;
        std::string new_latex = CFunction::parenthesize_if(this->_latex, OP_TYPE::MUL, this->_last_op);
        new_latex.append(" \\cdot ");
        new_latex.append(CFunction::parenthesize_if(rhs._latex, OP_TYPE::MUL, rhs._last_op));
        return CFunction([=](dtype z) { return lhs_f(z) * rhs_f(z); }, new_latex, OP_TYPE::MUL);
    }

    CFunction CFunction::operator/(CFunction const &rhs) const noexcept {
        auto const lhs_f = this->_f, rhs_f = rhs._f;
        std::string new_latex = "\\frac{";
        new_latex.append(CFunction::parenthesize_if(this->_latex, OP_TYPE::DIV, this->_last_op));
        new_latex.append("}{");
        new_latex.append(CFunction::parenthesize_if(rhs._latex, OP_TYPE::DIV, rhs._last_op));
        new_latex.append("}");
        return CFunction([=](dtype z) { return lhs_f(z) / rhs_f(z); }, new_latex, OP_TYPE::DIV);
    }

    CFunction CFunction::pow(CFunction const &rhs) const noexcept {
        auto const lhs_f = this->_f, rhs_f = rhs._f;
        std::string new_latex = "{";
        new_latex.append(CFunction::parenthesize_if(rhs._latex, OP_TYPE::LPOW, rhs._last_op));
        new_latex.append("}^{");
        new_latex.append(CFunction::parenthesize_if(rhs._latex, OP_TYPE::RPOW, rhs._last_op));
        new_latex.append("}");
        return CFunction([=](dtype z) { return std::pow(lhs_f(z), rhs_f(z)); }, new_latex, OP_TYPE::LPOW);
    }

    CFunction CFunction::reciprocal() const noexcept {
        auto const old_f  = this->_f;
        std::string new_latex = "\\frac{1}{";
        new_latex.append(CFunction::parenthesize_if(this->_latex, OP_TYPE::DIV, this->_last_op));
        new_latex.append("}");
        return CFunction([=](dtype z) { return 1. / old_f(z); }, new_latex, OP_TYPE::DIV);
    }

    CFunction CFunction::addconst(dtype a) const noexcept {
        auto const old_f = this->_f;
        std::string new_latex = this->_latex;
        new_latex.append(" + ");
        new_latex.append(std::to_string(std::real(a)));
        if (std::imag(a) != 0) {
            new_latex.append(" + ");
            new_latex.append(std::to_string(std::imag(a)));
            new_latex.append(" i");
        }
        return CFunction([=](dtype z) { return old_f(z) + a; }, new_latex, OP_TYPE::ADD);
    }

    CFunction CFunction::mulconst(dtype a) const noexcept {
        auto const old_f = this->_f;
        std::string new_latex = "";
        if (std::imag(a) != 0) new_latex.append("\\left(");
        new_latex.append(std::to_string(std::real(a)));
        if (std::imag(a) != 0) {
            new_latex.append(" + ");
            new_latex.append(std::to_string(std::imag(a)));
            new_latex.append(" i\\right)");
        }
        return CFunction([=](dtype z) { return a * old_f(z); });
    }

    CFunction CFunction::powconst(dtype a) const noexcept {
        auto const old_f = this->_f;
        std::string new_latex = "{";
        new_latex.append(CFunction::parenthesize_if(this->_latex, OP_TYPE::LPOW, this->_last_op));
        new_latex.append("}");
        return CFunction([=](dtype z) { return std::pow(old_f(z), a); }, new_latex, OP_TYPE::LPOW);
    }

    CFunction CFunction::lpowconst(dtype a) const noexcept {
        auto const old_f = this->_f;
        return CFunction([=](dtype z) { return std::pow(a, old_f(z)); });
    }
}
