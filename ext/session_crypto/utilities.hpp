#ifndef SESSION_CRYPTO_UTILITIES_HPP
#define SESSION_CRYPTO_UTILITIES_HPP

#include <iostream>
#include <random>
#include <chrono>
#include <climits>


// All credit for the contents of this file goes out to the PS Forever team:
// Original Github: https://github.com/psforever/psemu
// Fork: https://github.com/GeorgeKaraszi/psemu


uint8_t randomUnsignedChar() {
    std::random_device randomDevice;
    std::mt19937_64 generator(randomDevice());
    std::uniform_int_distribution<uint8_t> distribution(0, UCHAR_MAX);

    return distribution(generator);
}

std::size_t getTimeSeconds() {
    std::chrono::system_clock::time_point now = std::chrono::system_clock::now();
    std::chrono::system_clock::duration tp = now.time_since_epoch();
    return (size_t) std::chrono::duration_cast<std::chrono::seconds>(tp).count();
}


template<size_t arraySize>
std::string strHex(const std::array<uint8_t, arraySize>& data) {
    return strHex(data.begin(), data.end());
}

template<typename Iterator>
std::string strHex(Iterator first, Iterator last) {
    std::string result;
    result.reserve(static_cast<uint64_t>(std::distance(first, last) * 3));

    char buf[4];
    for (; first != last; ++first) {
        sprintf(buf, " %02X", *first);
        result += buf;
    }

    return result;
}

std::string strHex(const uint8_t* data, size_t len) {
    std::string result;
    result.reserve(len * 3);

    char buf[4];
    for (size_t i = 0; i < len; ++i) {
        sprintf(buf, " %02X", data[i]);
        result += buf;
    }

    return result;
}

std::string strHex(const std::vector<uint8_t>& data) {
    return strHex(data.begin(), data.end());
}

#endif //SESSION_CRYPTO_UTILITIES_HPP
