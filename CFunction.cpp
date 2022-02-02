#include "CFunction.h"

namespace libcalculus {
    std::complex<double> CFunction::operator()(std::complex<double> z) {
        return this->f(z);
    }
}
