#pragma once
#include <functional>
#include <type_traits>
#include "Definitions.h"

namespace libcalculus {
    template<typename T>
    struct Traits {
    public:
        static constexpr REAL tol = [] {
            if constexpr (std::is_same<T, REAL>::value)
                return 1e-6;
            else if constexpr (std::is_same<T, COMPLEX>::value)
                return 1e-6;
        }();

        inline static bool close(T const a, T const b) noexcept { return std::abs(a - b) < Traits<T>::tol; }
    };

    template<typename Dom>
    class CComparison {
    public:
        std::string latex;
        std::function<bool(Dom)> eval = [](Dom z) { return true; };

        CComparison() {}
        CComparison(std::function<bool(Dom)> const &eval, std::string const &latex) : latex{latex}, eval{eval} {}

        // Unary operators
        CComparison<Dom> operator~() const;

        // Binary operators
        CComparison<Dom> operator|(CComparison<Dom> const &rhs) const;
        CComparison<Dom> operator&(CComparison<Dom> const &rhs) const;

        // In-place binary operators
        CComparison<Dom> &operator|=(CComparison<Dom> const &rhs);
        CComparison<Dom> &operator&=(CComparison<Dom> const &rhs);
    };
}
