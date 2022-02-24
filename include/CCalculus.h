#pragma once
#include "CFunction.h"

namespace libcalculus {
    template<typename Dom, typename Ran, typename ContDom>
    Ran Integrate(CFunction<Dom, Ran> const &f, CFunction<ContDom, Dom> const &contour, ContDom start, ContDom End, double tol) = delete;

    inline size_t factorial(size_t n) noexcept {
        size_t result = 1;
        for (; n > 0; --n) result *= n;
        return result;
    }
}