#ifndef CFUNCTION_H
#define CFUNCTION_H
#include <iostream>
#include <complex>
#include <functional>

using namespace std::complex_literals;
using function = std::function<std::complex<double>(std::complex<double>)>;

namespace libcalculus {
    class CFunction {
    private:
        function f = [](std::complex<double> z) { return z; };
    public:
        CFunction() {}
        CFunction(function f) : f{f} {}
        std::complex<double> operator()(std::complex<double> z);
    };

    auto const identity = CFunction([](std::complex<double> z) { return z; });
    CFunction mulconst(std::complex<double> a) {
        return CFunction([a](std::complex<double> z) { return a * z; });
    }
}
#endif
