#pragma once
#include "CFunction.h"

namespace libcalculus {
    template<typename Dom, typename Ran, typename Cont>
    Ran Integrate(CFunction<Dom, Ran> const &f, CFunction<Cont, Dom> const &contour, double tol) = delete;
}
