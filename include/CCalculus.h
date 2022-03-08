#pragma once
#include "CFunction.h"

namespace libcalculus {
    template<typename Dom, typename Ran>
    CFunction<Dom, Ran> Derivative(CFunction<Dom, Ran> const &f, REAL const tol, REAL const radius);

    template<typename Dom, typename Ran, typename ContDom>
    Ran Integrate(CFunction<Dom, Ran> const &f, CFunction<ContDom, Dom> const &contour, ContDom const start, ContDom const end, REAL const tol);

    inline size_t factorial(size_t n) noexcept {
        size_t result = 1;
        for (; n > 0; --n) result *= n;
        return result;
    }
}
