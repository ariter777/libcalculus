#ifndef CFUNCTION_H
#define CFUNCTION_H
#include <iostream>
#include <complex>
#include <functional>

namespace libcalculus {
    using namespace std::complex_literals;
    using dtype = std::complex<double>;
    using function = std::function<dtype(dtype)>;
    class CFunction {
    public:
        function f = [](dtype z) { return z; };

        CFunction() {}
        CFunction(function f) : f{f} {}
        CFunction(CFunction const &cf) : f{cf.f} {}
        dtype operator()(dtype z) const;
        CFunction compose(CFunction const &rhs) const noexcept;

        CFunction operator+(CFunction const &rhs) const noexcept;
        CFunction operator-(CFunction const &rhs) const noexcept;
        CFunction operator*(CFunction const &rhs) const noexcept;
        CFunction operator/(CFunction const &rhs) const noexcept;
        CFunction pow(CFunction const &rhs) const noexcept;
        CFunction reciprocal() const noexcept;

        CFunction addconst(dtype a) const noexcept;
        CFunction mulconst(dtype a) const noexcept;
        CFunction powconst(dtype a) const noexcept;
        CFunction lpowconst(dtype a) const noexcept;

        static CFunction Exp() { return CFunction([](dtype z) { return std::exp(z); }); }
        static CFunction Sin() { return CFunction([](dtype z) { return std::sin(z); }); }
        static CFunction Cos() { return CFunction([](dtype z) { return std::cos(z); }); }
        static CFunction Tan() { return CFunction([](dtype z) { return std::tan(z); }); }
    };
}
#endif
