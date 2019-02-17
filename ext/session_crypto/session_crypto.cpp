#include <utility>
#include <iostream>
#include "session_crypto.hpp"


void SessionCrypto::generate_dh_key_pairs(const vector<uint8_t> rb_p, const vector<uint8_t> rb_g
)
{
    CryptoPP::AutoSeededRandomPool rnd;
    CryptoPP::Integer p(rb_p.data(), rb_p.size());
    CryptoPP::Integer g(rb_g.data(), rb_g.size());

    dh.AccessGroupParameters().Initialize(p, g);
    serverPrivKey.resize(dh.PrivateKeyLength());
    serverPubKey.resize(dh.PublicKeyLength());
    dh.GenerateKeyPair(rnd, serverPrivKey.data(), serverPubKey.data());
}


extern "C"
void Init_session_crypto()
{
    Module rb_cPSEmuModule = define_module("PSEmu");

    Data_Type<SessionCrypto> rb_cTestClass =
            define_class_under<SessionCrypto>(rb_cPSEmuModule, "SessionCrypto")
                    .define_constructor(Constructor<SessionCrypto>())
                    .define_method("generate_dh_key_pairs!", &SessionCrypto::generate_dh_key_pairs)
                    .define_method("server_priv_key", &SessionCrypto::get_priv_key)
                    .define_method("server_pub_key", &SessionCrypto::get_pub_key)
                    .define_method("server_challenge", &SessionCrypto::get_server_challenge)
                    .define_method("client_challenge", &SessionCrypto::get_client_challenge)
                    .define_method("client_challenge=", &SessionCrypto::set_client_challenge)
                    .define_method("client_time", &SessionCrypto::get_client_time)
                    .define_method("client_time=", &SessionCrypto::set_client_time)
                    .define_method("server_time", &SessionCrypto::get_server_time)
                    ;
}
