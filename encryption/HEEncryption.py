#### TO BE RUN IN ALL CASES ######

import phe
from phe import paillier
import json

def generate_paillier_keypair():
    public_key, private_key = paillier.generate_paillier_keypair()

    to_be_shared_pub_key = {}
    to_be_shared_pub_key['public_key'] = { 'g':public_key.g, 'n':public_key.n}

    print(to_be_shared_pub_key)
    return to_be_shared_pub_key['public_key']



def encrypt_value (public_key, number):
    public_key_rec = paillier.PaillierPublicKey(n=int(public_key['n']))
    your_encrypted_number = public_key_rec.encrypt(number)
    enc_with_pub_key = {}
    enc_with_pub_key['public_key'] = { 'g':public_key_rec.g, 'n':public_key_rec.n}
    enc_with_pub_key['enc_value'] = (str(your_encrypted_number.ciphertext()),your_encrypted_number.exponent)
    serialised = json.dumps(enc_with_pub_key)
    print(serialised)
    return serialised




if __name__ == '__main__':
    public_key = generate_paillier_keypair()
    number = 10
    encrypt_value(public_key, number)