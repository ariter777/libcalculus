#pragma once
#include "CFunction.h"

namespace libcalculus {
    template<typename Dom, typename Ran, typename ContDom>
    Ran Integrate(CFunction<Dom, Ran> const &f, CFunction<ContDom, Dom> const &contour, ContDom start, ContDom End, double tol) = delete;
}
