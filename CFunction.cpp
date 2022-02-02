#include "CFunction.h"

namespace libcalculus {

    std::complex<double> CFunction::operator()(std::complex<double> z) const {
        return this->f(z);
    }

    void CFunction::addconst(std::complex<double> a) noexcept {
        auto const old_f = this->f;
        this->f = [&](std::complex<double> z) { return a + old_f(z); };
    }

    void CFunction::subconst(std::complex<double> a) noexcept {
        auto const old_f = this->f;
        this->f = [&](std::complex<double> z) { return old_f(z) - a; };
    }

    void CFunction::lsubconst(std::complex<double> a) noexcept {
        auto const old_f = this->f;
        this->f = [&](std::complex<double> z) { return a - old_f(z); };
    }

    void CFunction::mulconst(std::complex<double> a) noexcept {
        auto const old_f = this->f;
        this->f = [&](std::complex<double> z) { return a * old_f(z); };
    }

    void CFunction::divconst(std::complex<double> a) {
        auto const old_f = this->f;
        this->f = [&](std::complex<double> z) { return old_f(z) / a; };
    }

    void CFunction::ldivconst(std::complex<double> a) {
        auto const old_f = this->f;
        this->f = [&](std::complex<double> z) { return a / old_f(z); };
    }
}
