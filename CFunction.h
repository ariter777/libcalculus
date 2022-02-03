#ifndef CFUNCTION_H
#define CFUNCTION_H
#include <iostream>
#include <complex>
#include <functional>
#include <string>

namespace libcalculus {
    using namespace std::complex_literals;
    using dtype = std::complex<double>;
    using function = std::function<dtype(dtype)>;
    class CFunction {
    private:
        function _f = [](dtype z) { return z; };
        std::string _latex = "";
        char _last_op = 0;
    public:
        CFunction() {}
        CFunction(function f) : _f{f} {}
        CFunction(CFunction const &cf) : _f{cf._f} {}
        CFunction(CFunction const &cf, std::string const &latex, char last_op) : _f{cf._f}, _latex{latex}, _last_op{last_op} {}
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
