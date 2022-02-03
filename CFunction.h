#ifndef CFUNCTION_H
#define CFUNCTION_H
#include <iostream>
#include <complex>
#include <functional>

using namespace std::complex_literals;
using function = std::function<std::complex<double>(std::complex<double>)>;

namespace libcalculus {
    class CFunction {
    public:
        function f = [](std::complex<double> z) { return z; };

        CFunction() {}
        CFunction(function f) : f{f} {}
        CFunction(CFunction const &cf) : f{cf.f} {}
        std::complex<double> operator()(std::complex<double> z) const;

        CFunction operator+(CFunction const &rhs) const noexcept;
        CFunction operator-(CFunction const &rhs) const noexcept;
        CFunction operator*(CFunction const &rhs) const noexcept;
        CFunction operator/(CFunction const &rhs) const noexcept;
        CFunction reciprocal() const noexcept;

        CFunction addconst(std::complex<double> a) const noexcept;
        CFunction mulconst(std::complex<double> a) const noexcept;
    };
}
#endif
