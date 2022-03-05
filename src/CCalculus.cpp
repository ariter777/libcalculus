#pragma once
#include "CCalculus.h"

namespace libcalculus {
    template<>
    COMPLEX Integrate(CFunction<COMPLEX, COMPLEX> const &f,
                                   CFunction<REAL, COMPLEX> const &contour, REAL const start, REAL const end, REAL const tol) {
        COMPLEX prev_result, result = 0.;
        size_t while_iters = 0, n = INTEGRATION_SUBDIV_FACTOR / tol;
        while (while_iters < 2 || abs(result - prev_result) >= tol) {
            n *= 2;
            prev_result = result;
            result = 0.;
            COMPLEX z, prev_z = contour(start);

            #pragma omp simd
            for (size_t k = 1; k <= n; ++k) {
                z = contour(start + (end - start) * k / n);
                result += f(z) * (z - prev_z);
                prev_z = z;
            }
            ++while_iters;
        }
        return result;
    }

    template<>
    REAL Integrate(CFunction<REAL, REAL> const &f, CFunction<REAL, REAL> const &contour, REAL const start, REAL const end, REAL const tol) {
        REAL prev_result, result = 0.;
        size_t while_iters = 0, n = INTEGRATION_SUBDIV_FACTOR / tol;
        while (while_iters < 2 || abs(result - prev_result) >= tol) {
            n *= 2;
            prev_result = result;
            result = 0.;
            REAL z, prev_z = start;

            #pragma omp simd reduction(+:result)
            for (size_t k = 1; k <= n; ++k) {
                z = start + (end - start) * k / n;
                result += f(z) * (z - prev_z);
                prev_z = z;
            }
            ++while_iters;
        }
        return result;
    }
}
