#pragma once
#include <functional>
#include "CFunction.h"

namespace libcalculus {
    template<typename Dom, typename Ran>
    class CComparison {
    public:
        static constexpr REAL EQ_TOL = 1e-6;
        std::function<bool(Dom)> eval = [](Dom z) { return true; };

        CComparison() {}
        CComparison(std::function<bool(Dom)> const &eval) : eval{eval} {}

        // Binary operators
        inline CComparison<Dom, Ran> operator~() const {
            return CComparison<Dom, Ran>([old_eval = this->eval](Dom z) { return !old_eval(z); });
        }

        inline CComparison<Dom, Ran> operator|(CComparison<Dom, Ran> const &rhs) const {
            return CComparison<Dom, Ran>([lhs_eval = this->eval, rhs_eval = rhs.eval](Dom z) { return lhs_eval(z) || rhs_eval(z); });
        }

        inline CComparison<Dom, Ran> operator&(CComparison<Dom, Ran> const &rhs) const {
            return CComparison<Dom, Ran>([lhs_eval = this->eval, rhs_eval = rhs.eval](Dom z) { return lhs_eval(z) && rhs_eval(z); });
        }
    };
}
