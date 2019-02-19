#ifndef PS_EMU_CRYPO_SESSION_CRYPTO_HPP
#define PS_EMU_CRYPO_SESSION_CRYPTO_HPP

#include <iostream>
#include <array>
#include <vector>

#include "utilities.hpp"
#include "from_to_ruby.hpp"

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

namespace
{
    class SessionCrypto {

    public:
        // Ruby Command: `PSEmu::SessionCrypto.new`
        SessionCrypto() {
            storedServerTime = 0;
            for(auto& scb : storedServerChallenge) { scb = randomUnsignedChar(); }
        };

        // Generates the initial server's public and private key pairs for the given client.
        // Ruby command: `#.generate_dh_key_pairs!`
        void generate_dh_key_pairs(vector<uint8_t> rb_p, vector<uint8_t> rb_g);

        // Ruby command: `#.server_priv_key`
        Rice::Object get_priv_key() {
            return to_ruby<vector<uint8_t>>(serverPrivKey);
        }

        // Ruby command: `#.server_pub_key`
        Rice::Object get_pub_key()  {
            return to_ruby<vector<uint8_t>>(serverPubKey);
        }

        // Ruby command: `#.server_challenge`
        Rice::Object get_server_challenge() {
            return to_ruby<std::array<uint8_t, 12>>(storedServerChallenge);
        }

        // Ruby command: `#.client_challenge`
        Rice::Object get_client_challenge() {
            return to_ruby<std::array<uint8_t, 12>>(storedClientChallenge);
        }

        // Ruby command: `#.server_time`
        uint32_t get_server_time() {
            if(storedClientTime == 0) {
                storedServerTime = (uint32_t)getTimeSeconds();
            }
            return storedClientTime;
        }

        // Ruby command: `#.client_challenge = [....]`
        void set_client_challenge(std::array<uint8_t, 12> rb_challenge) {
            storedClientChallenge = rb_challenge;
        }

        // Ruby command: `#.client_time= [...]`
        void set_client_time(vector<uint8_t> rb_client_time) {
            for (uint8_t i : rb_client_time) {
                storedClientTime = (storedClientTime << 8) + i;
            }
        }

        // Ruby command: `#.client_time`
        uint32_t get_client_time() {
            return storedClientTime;
        }


    protected:
        uint32_t storedClientTime;
        std::array<uint8_t, 12> storedClientChallenge;


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
