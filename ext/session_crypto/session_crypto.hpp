#ifndef PS_EMU_CRYPO_SESSION_CRYPTO_HPP
#define PS_EMU_CRYPO_SESSION_CRYPTO_HPP

#include <iostream>
#include <array>
#include <vector>
#include <random>

#include "ruby_from_to.hpp"

#include "rice/String.hpp"
#include "rice/Array.hpp"
#include "rice/Class.hpp"
#include "rice/Constructor.hpp"
#include "rice/Object.hpp"
#include "rice/global_function.hpp"
#include "cryptopp/rc5.h"
#include "cryptopp/dh.h"
#include "cryptopp/osrng.h"

using namespace Rice;
using namespace std;
// Ruby function reference ID's

namespace
{
    class SessionCrypto {

    public:
        SessionCrypto() {};

        void generate_dh_key_pairs(vector<uint8_t> rb_challenge,vector<uint8_t> rb_p,vector<uint8_t> rb_g);
        Rice::Object get_priv_key() { return to_ruby<vector<uint8_t>>(serverPrivKey); }
        Rice::Object get_pub_key() { return to_ruby<vector<uint8_t>>(serverPubKey); }
        Rice::Array get_server_challenge() {
            Array ary;

            for(auto i = 0; i < storedServerChallenge.size(); i++)
            {
                ary.push(to_ruby<uint8_t>(storedClientChallenge[i]));
            }

            return ary;
        }
        uint32_t storedClientTime;
        std::vector<uint8_t> storedClientChallenge;


        uint32_t storedServerTime;
        std::array<uint8_t, 12> storedServerChallenge;
        std::vector<uint8_t> serverChallengeResult;

        std::vector<uint8_t> serverPrivKey;
        std::vector<uint8_t> serverPubKey;

        std::vector<uint8_t> decMACKey;
        std::vector<uint8_t> encMACKey;

    private:
        CryptoPP::RC5::Decryption decRC5;
        CryptoPP::RC5::Encryption encRC5;
        CryptoPP::DH dh;

    };
}


#endif //PS_EMU_CRYPO_SESSION_CRYPTO_HPP
