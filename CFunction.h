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

        CFunction operator+(CFunction const &rhs) noexcept;
        CFunction operator-(CFunction const &rhs) noexcept;
        CFunction operator*(CFunction const &rhs) noexcept;
        CFunction operator/(CFunction const &rhs) noexcept;

        void addconst(std::complex<double> a) noexcept;
        void subconst(std::complex<double> a) noexcept;
        void lsubconst(std::complex<double> a) noexcept;
        void mulconst(std::complex<double> a) noexcept;
        void divconst(std::complex<double> a);
        void ldivconst(std::complex<double> a);
    };
}
#endif
