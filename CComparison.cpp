#include "CComparison.h"

namespace libcalculus {
    template<typename Dom, typename Ran>
    CComparison<Dom, Ran> CComparison<Dom, Ran>::operator~() const {
        std::string new_latex = "\\neg\\left(";
        new_latex.append(this->latex);
        new_latex.append("\\right)");
        return CComparison([old_eval = this->eval](Dom z) { return !old_eval(z); }, new_latex);
    }

    template<typename Dom, typename Ran>
    CComparison<Dom, Ran> CComparison<Dom, Ran>::operator|(CComparison<Dom, Ran> const &rhs) const {
        std::string new_latex = "\\left(";
        new_latex.append(this->latex);
        new_latex.append("\\right)\\vee\\left(");
        new_latex.append(rhs.latex);
        new_latex.append("\\right)");
        return CComparison([lhs_eval = this->eval, rhs_eval = rhs.eval](Dom z) { return lhs_eval(z) || rhs_eval(z); },
                                     new_latex);
    }

    template<typename Dom, typename Ran>
    CComparison<Dom, Ran> CComparison<Dom, Ran>::operator&(CComparison<Dom, Ran> const &rhs) const {
        std::string new_latex = "\\left(";
        new_latex.append(this->latex);
        new_latex.append("\\right)\\wedge\\left(");
        new_latex.append(rhs.latex);
        new_latex.append("\\right)");
        return CComparison([lhs_eval = this->eval, rhs_eval = rhs.eval](Dom z) { return lhs_eval(z) && rhs_eval(z); },
                                     new_latex);
    }
}
