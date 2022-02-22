#pragma once
#include <functional>
#include <type_traits>
#include "CFunction.h"

namespace libcalculus {
    template<typename T>
    struct Traits {
        static constexpr REAL tol = [] {
            if constexpr (std::is_same<T, REAL>::value)
                return 1e-6;
            else if constexpr (std::is_same<T, COMPLEX>::value)
                return 1e-6;
        }();
    };

    template<typename Dom, typename Ran>
    class CComparison {
    public:
        std::string latex;
        std::function<bool(Dom)> eval = [](Dom z) { return true; };

        CComparison() {}
        CComparison(std::function<bool(Dom)> const &eval, std::string const &latex) : latex{latex}, eval{eval} {}

        // Binary operators
        CComparison<Dom, Ran> operator~() const;
        CComparison<Dom, Ran> operator|(CComparison<Dom, Ran> const &rhs) const;
        CComparison<Dom, Ran> operator&(CComparison<Dom, Ran> const &rhs) const;
    };
}
