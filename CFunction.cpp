#include "CFunction.h"

namespace libcalculus {

    std::complex<double> CFunction::operator()(std::complex<double> z) const {
        return this->f(z);
    }

    CFunction CFunction::operator+(CFunction const &rhs) const noexcept {
        auto const old_f = this->f;
        return CFunction([=](std::complex<double> z) { return old_f(z) + rhs.f(z); });
    }

    CFunction CFunction::operator-(CFunction const &rhs) const noexcept {
        auto const old_f = this->f;
        return CFunction([=](std::complex<double> z) { return old_f(z) - rhs.f(z); });
    }

    CFunction CFunction::operator*(CFunction const &rhs) const noexcept {
        auto const old_f = this->f;
        return CFunction([=](std::complex<double> z) { return old_f(z) * rhs.f(z); });
    }

    CFunction CFunction::operator/(CFunction const &rhs) const noexcept {
        auto const old_f = this->f;
        return CFunction([=](std::complex<double> z) { return old_f(z) / rhs.f(z); });
    }

    CFunction CFunction::addconst(std::complex<double> a) const noexcept {
        auto const old_f = this->f;
        return CFunction([=](std::complex<double> z) { return a + old_f(z); });
    }

    CFunction CFunction::mulconst(std::complex<double> a) const noexcept {
        auto const old_f = this->f;
        return CFunction([=](std::complex<double> z) { return a * old_f(z); });
    }

    CFunction CFunction::ldivconst(std::complex<double> a) const {
        auto const old_f = this->f;
        return CFunction([=](std::complex<double> z) { return a / old_f(z); });
    }
}
