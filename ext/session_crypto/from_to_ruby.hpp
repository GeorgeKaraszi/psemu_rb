#ifndef SESSION_CRYPTO_FROM_TO_RUBY_HPP
#define SESSION_CRYPTO_FROM_TO_RUBY_HPP
#include <array>
#include <vector>
#include <iterator>
#include "rice/Object.hpp"
#include "rice/Array.hpp"

// This file contains additional helpers for converting data to and from the Ruby VM.
// The following are not generically supplied from the Rice library.
//
//  Usage example:
//
//  std::vector<uint8_t> some_value_with_data;
//
//  return Rice::to_ruby<std::vector<uint8_t>>(some_value_with_data);
//      #=> !< Rice::Array ...>

namespace Rice {
    namespace detail {
        //---------------------------------------------------------------------
        // Handel the conversation of CPP std::vector types

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


        //---------------------------------------------------------------------
        // Handel the conversation of CPP std::array types


        template<typename T, int N>
        struct from_ruby_<std::array<T, N> >
        {
            typedef std::array<T, N> Retval_T;

            static std::array<T, N> convert(Rice::Object x) {
                Rice::Array a(x);
                std::array<T, N> result;

                for(int i = 0; i < N; i++) {
                    result[i] = from_ruby<T>(a[i]);
                }

                return result;
            }
        };

        template<typename T, int N>
        struct to_ruby_<std::array<T, N>>
        {
            static Rice::Object convert(std::array<T, N> const & x) {
                return Rice::Array(x.begin(), x.end());
            }
        };
    }
}

#endif //SESSION_CRYPTO_FROM_TO_RUBY_HPP
