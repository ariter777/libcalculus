#pragma once
#include <string>

namespace libcalculus {
    using REAL = double;
    using COMPLEX = std::complex<double>;

    namespace Latex {
        std::string _parenthesize(std::string const &expr);
        std::string parenthesize_if(std::string const &expr, char new_op, char last_op);

        template<typename T> std::string fmt_const(T a, bool parenthesize = false);
    }
}
