#pragma once
#include <functional>
#include "CFunction.h"

namespace libcalculus {
    template<typename T>
    struct Traits {
        static constexpr REAL tol = 0;
    };

    template<>
    struct Traits<REAL> {
        static constexpr REAL tol = 1e-6;
    };

    template<>
    struct Traits<COMPLEX> {
        static constexpr REAL tol = 1e-6;
    };


    template<typename Dom, typename Ran>
    class CComparison {
    public:
        std::string latex;
        std::function<bool(Dom)> eval = [](Dom z) { return true; };

        CComparison() {}
        CComparison(std::function<bool(Dom)> const &eval, std::string const &latex) : latex{latex}, eval{eval} {}

        // Binary operators
        CComparison<Dom, Ran> operator~() const {
            std::string new_latex = "\\neg\\left(";
            new_latex.append(this->latex);
            new_latex.append("\\right)");
            return CComparison([old_eval = this->eval](Dom z) { return !old_eval(z); }, new_latex);
        }

        CComparison<Dom, Ran> operator|(CComparison<Dom, Ran> const &rhs) const {
            std::string new_latex = "\\left(";
            new_latex.append(this->latex);
            new_latex.append("\\right)\\vee\\left(");
            new_latex.append(rhs.latex);
            new_latex.append("\\right)");
            return CComparison([lhs_eval = this->eval, rhs_eval = rhs.eval](Dom z) { return lhs_eval(z) || rhs_eval(z); },
                                         new_latex);
        }

        CComparison<Dom, Ran> operator&(CComparison<Dom, Ran> const &rhs) const {
            std::string new_latex = "\\left(";
            new_latex.append(this->latex);
            new_latex.append("\\right)\\wedge\\left(");
            new_latex.append(rhs.latex);
            new_latex.append("\\right)");
            return CComparison([lhs_eval = this->eval, rhs_eval = rhs.eval](Dom z) { return lhs_eval(z) && rhs_eval(z); },
                                         new_latex);
        }
    };
}
