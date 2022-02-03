#pragma once
#include "CFunction.h"

namespace libcalculus {
    inline bool isnanc(std::complex<double> z) { return std::isnan(std::real(z)); }

    template<typename Dom, typename Ran, typename ContDom>
    Ran Integrate(CFunction<Dom, Ran> const &f, CFunction<ContDom, Dom> const &contour, ContDom start, ContDom End, double tol) = delete;
}
