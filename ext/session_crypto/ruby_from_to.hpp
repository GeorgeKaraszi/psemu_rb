//
// Created by George Karaszi on 2019-02-16.
//

#ifndef SESSION_CRYPTO_RUBY_FROM_TO_HPP
#define SESSION_CRYPTO_RUBY_FROM_TO_HPP

#include <vector>
#include "rice/Object.hpp"
#include "rice/Array.hpp"

namespace Rice {
    namespace detail {
        template<typename T>
        struct from_ruby_<std::vector<T> >
        {
            typedef std::vector<T> Retval_T;

            static std::vector<T> convert(Rice::Object x) {
                Rice::Array a(x);
                std::vector<T> result;
                result.reserve(a.size());
                for (Rice::Array::iterator it = a.begin(); it != a.end(); ++it) {
                    result.push_back(from_ruby<T>(*it));
                }
                return result;
            }
        };

        template<typename T>
        struct to_ruby_<std::vector<T> >
        {
            static Rice::Object convert(std::vector<T> const & x) {
                return Rice::Array(x.begin(), x.end());
            }
        };
    }
}

#endif //SESSION_CRYPTO_RUBY_FROM_TO_HPP
