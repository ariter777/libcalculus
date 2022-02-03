#include "CFunction.h"

namespace libcalculus {
    dtype CFunction::operator()(dtype z) const {
        return this->f(z);
    }

    CFunction CFunction::compose(CFunction const &rhs) const noexcept {
        auto const lhs_f = this->f, rhs_f = rhs.f;
        return CFunction([=](dtype z) { return lhs_f(rhs_f(z)); });
    }

    CFunction CFunction::operator+(CFunction const &rhs) const noexcept {
        auto const lhs_f = this->f, rhs_f = rhs.f;
        return CFunction([=](dtype z) { return lhs_f(z) + rhs_f(z); });
    }

    CFunction CFunction::operator-(CFunction const &rhs) const noexcept {
        auto const lhs_f = this->f, rhs_f = rhs.f;
        return CFunction([=](dtype z) { return lhs_f(z) - rhs_f(z); });
    }

    CFunction CFunction::operator*(CFunction const &rhs) const noexcept {
        auto const lhs_f = this->f, rhs_f = rhs.f;
        return CFunction([=](dtype z) { return lhs_f(z) * rhs_f(z); });
    }

    CFunction CFunction::operator/(CFunction const &rhs) const noexcept {
        auto const lhs_f = this->f, rhs_f = rhs.f;
        return CFunction([=](dtype z) { return lhs_f(z) / rhs_f(z); });
    }

    CFunction CFunction::pow(CFunction const &rhs) const noexcept {
        auto const lhs_f = this->f, rhs_f = rhs.f;
        return CFunction([=](dtype z) { return std::pow(lhs_f(z), rhs_f(z)); });
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

    CFunction CFunction::lpowconst(dtype a) const noexcept {
        auto const old_f = this->f;
        return CFunction([=](dtype z) { return std::pow(a, old_f(z)); });
    }
}
