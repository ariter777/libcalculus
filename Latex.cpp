#include "Latex.h"

namespace libcalculus {
    namespace Latex {
        std::string _parenthesize(std::string const &expr) {
            std::string result = " \\left( ";
            result.append(expr);
            result.append(" \\right) ");
            return result;
        }

        std::string parenthesize_if(std::string const &expr, char new_op, char last_op) {
            if (new_op == OP_TYPE::FUNC || new_op == OP_TYPE::DIV || new_op == OP_TYPE::RPOW) return expr;
            else if (((last_op == OP_TYPE::ADD || last_op == OP_TYPE::SUB) && (new_op == OP_TYPE::MUL || new_op == OP_TYPE::NEG))
                     || (last_op != OP_TYPE::NOP && new_op == OP_TYPE::LPOW)
                     || (last_op == OP_TYPE::NEG && (new_op == OP_TYPE::ADD || new_op == OP_TYPE::SUB || new_op == OP_TYPE::MUL)))
                return Latex::_parenthesize(expr);
            else return expr;
        }

        template<> std::string fmt_const(COMPLEX a, bool parenthesize) {
            std::ostringstream oss;
            if (std::imag(a) == 0.) {
                oss << std::real(a);
            } else if (std::real(a) == 0.) {
                oss << std::imag(a) << " i";
            } else {
                oss << std::real(a) << (std::imag(a) > 0 ? " + " : "") << std::imag(a) << " i";
            }
            return (parenthesize && (std::real(a) < 0 || std::imag(a) != 0.)) ? Latex::_parenthesize(oss.str()) : oss.str();
        }
    }


    template<> CFunction<COMPLEX, COMPLEX> CFunction<COMPLEX, COMPLEX>::Constant(COMPLEX c) { return CFunction([=](COMPLEX z) { return c; }, Latex::fmt_const(c, false),
                                                (std::real(c) < 0 || std::imag(c) != 0.) ? OP_TYPE::ADD : OP_TYPE::NOP); }
}
