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
        function f = [](std::complex<double> z) { return z + 5i; };
    public:
        CFunction() {}
        std::complex<double> operator()(std::complex<double> z);
    };
}
#endif
