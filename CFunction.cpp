#include "CFunction.h"

namespace libcalculus {
    dtype CFunction::operator()(dtype z) const {
        return this->f(z);
    }

    CFunction CFunction::operator+(CFunction const &rhs) const noexcept {
        auto const old_f = this->f;
        return CFunction([=](dtype z) { return old_f(z) + rhs.f(z); });
    }

    CFunction CFunction::operator-(CFunction const &rhs) const noexcept {
        auto const old_f = this->f;
        return CFunction([=](dtype z) { return old_f(z) - rhs.f(z); });
    }

    CFunction CFunction::operator*(CFunction const &rhs) const noexcept {
        auto const old_f = this->f;
        return CFunction([=](dtype z) { return old_f(z) * rhs.f(z); });
    }

    CFunction CFunction::operator/(CFunction const &rhs) const noexcept {
        auto const old_f = this->f;
        return CFunction([=](dtype z) { return old_f(z) / rhs.f(z); });
    }

    CFunction CFunction::reciprocal() const noexcept {
        auto const old_f  = this->f;
        return CFunction([=](dtype z) { return 1. / old_f(z); });
    }

    CFunction CFunction::addconst(dtype a) const noexcept {
        auto const old_f = this->f;
        return CFunction([=](dtype z) { return a + old_f(z); });
    }

    CFunction CFunction::mulconst(dtype a) const noexcept {
        auto const old_f = this->f;
        return CFunction([=](dtype z) { return a * old_f(z); });
    }

    CFunction CFunction::powconst(dtype a) const noexcept {
        auto const old_f = this->f;
        return CFunction([=](dtype z) { return std::pow(old_f(z), a); });
    }
}
