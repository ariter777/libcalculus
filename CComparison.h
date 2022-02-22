#pragma once
#include <functional>
#include "CFunction.h"

namespace libcalculus {
    template<typename Dom, typename Ran>
    class CComparison {
    public:
        static constexpr REAL EQ_TOL = 1e-6;
        std::string latex;
        std::function<bool(Dom)> eval = [](Dom z) { return true; };

        CComparison() {}
        CComparison(std::function<bool(Dom)> const &eval, std::string const &latex) : latex{latex}, eval{eval} {}

        // Binary operators
        inline CComparison<Dom, Ran> operator~() const {
            std::string new_latex = "\\neg\\left(";
            new_latex.append(this->latex);
            new_latex.append("\\right)");
            return CComparison<Dom, Ran>([old_eval = this->eval](Dom z) { return !old_eval(z); }, new_latex);
        }

        inline CComparison<Dom, Ran> operator|(CComparison<Dom, Ran> const &rhs) const {
            std::string new_latex = "\\left(";
            new_latex.append(this->latex);
            new_latex.append("\\right)\\vee\\left(");
            new_latex.append(rhs.latex);
            new_latex.append("\\right)");
            return CComparison<Dom, Ran>([lhs_eval = this->eval, rhs_eval = rhs.eval](Dom z) { return lhs_eval(z) || rhs_eval(z); },
                                         new_latex);
        }

        inline CComparison<Dom, Ran> operator&(CComparison<Dom, Ran> const &rhs) const {
            std::string new_latex = "\\left(";
            new_latex.append(this->latex);
            new_latex.append("\\right)\\wedge\\left(");
            new_latex.append(rhs.latex);
            new_latex.append("\\right)");
            return CComparison<Dom, Ran>([lhs_eval = this->eval, rhs_eval = rhs.eval](Dom z) { return lhs_eval(z) && rhs_eval(z); },
                                         new_latex);
        }
    };
}
