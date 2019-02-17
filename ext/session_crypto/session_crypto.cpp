#include <utility>


#include <iostream>
#include "session_crypto.hpp"

ID ps_emu_bytes_id;

uint8_t randomUnsignedChar() {
    std::random_device randomDevice;
    std::mt19937_64 generator(randomDevice());
    std::uniform_int_distribution<uint32_t> distribution(0, UCHAR_MAX);

    return (uint8_t) distribution(generator);
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

std::string strHex(const std::vector<uint8_t>& data);

std::string strHex(const uint8_t* data, size_t len);

template<typename Iterator>
std::string strHex(Iterator first, Iterator last) {
    std::string result;
    result.reserve(std::distance(first, last) * 3);

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


void SessionCrypto::generate_dh_key_pairs(vector<uint8_t> rb_challenge, vector<uint8_t> rb_p, vector<uint8_t> rb_g)
{
    storedServerTime      = (uint32_t)getTimeSeconds();
    storedClientChallenge = std::move(rb_challenge);

    CryptoPP::Integer p(rb_p.data(), rb_p.size());
    CryptoPP::Integer g(rb_g.data(), rb_g.size());
    CryptoPP::AutoSeededRandomPool rnd;

    dh.AccessGroupParameters().Initialize(p, g);
    serverPrivKey.resize(dh.PrivateKeyLength());
    serverPubKey.resize(dh.PublicKeyLength());
    dh.GenerateKeyPair(rnd, serverPrivKey.data(), serverPubKey.data());

    std::cout << "Priv: " << strHex(serverPrivKey) << std::endl;
    std::cout << "PUB: "  << strHex(serverPubKey) << std::endl;

    for(auto& scb : storedServerChallenge) { scb = randomUnsignedChar(); }

}


extern "C"
void Init_session_crypto()
{

    Data_Type<SessionCrypto> rb_cTestClass =
            define_class<SessionCrypto>("SessionCrypto")
                    .define_constructor(Constructor<SessionCrypto>())
                    .define_method("generate_dh_key_pairs!", &SessionCrypto::generate_dh_key_pairs)
                    .define_method("server_priv_key", &SessionCrypto::get_priv_key)
                    .define_method("server_pub_key", &SessionCrypto::get_pub_key)
                    .define_method("server_challenge", &SessionCrypto::get_server_challenge)
                    ;
}
