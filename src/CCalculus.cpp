#pragma once
#include "CCalculus.h"

namespace libcalculus {
    template<>
    std::complex<double> Integrate(CFunction<std::complex<double>, std::complex<double>> const &f,
                                   CFunction<double, std::complex<double>> const &contour, double const start, double const end, double const tol) {
        std::complex<double> prev_result, result;
        size_t while_iters = 0, n = 1. / tol;
        while (while_iters < 2 || abs(result - prev_result) >= tol) {
            n *= 2;
            prev_result = result;
            result = 0.;
            std::complex<double> z, prev_z = contour(start);

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
}
