#pragma once
#include "CCalculus.h"

namespace libcalculus {
    template<>
    std::complex<double> Integrate(CFunction<std::complex<double>, std::complex<double>> const &f,
                                   CFunction<double, std::complex<double>> const &contour, double start, double end, double tol) {
        std::complex<double> prev_result = NAN, result = NAN;
        double n = 1 / tol;
        while (isnanc(prev_result) || isnanc(result) || abs(result - prev_result) >= tol) {
            n *= 2;
            prev_result = result;
            result = 0.;
            std::complex<double> z, prev_z = contour(start);
            for (double t = start + 1. / n; t <= end; t += 1. / n) {
                z = contour(t);
                result += f(z) * (z - prev_z);
                prev_z = z;
            }
        }
        return result;
    }
}
