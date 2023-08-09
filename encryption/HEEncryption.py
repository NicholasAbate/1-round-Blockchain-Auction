#### TO BE RUN IN ALL CASES ######

from phe import paillier

def generate_paillier_keypair():
    public_key, private_key = paillier.generate_paillier_keypair()

    to_be_shared_pub_key = {}
    to_be_shared_pub_key['public_key'] = { 'g':public_key.g, 'n':public_key.n}

    print(to_be_shared_pub_key)
    return (to_be_shared_pub_key['public_key'], private_key)


# Returns an encrypted number object
def encrypt_value (public_key, number):
    public_key_rec = paillier.PaillierPublicKey(n=int(public_key['n']))
    your_encrypted_number = public_key_rec.encrypt(number)
    enc_with_pub_key = {}
    enc_with_pub_key['public_key'] = { 'g':public_key_rec.g, 'n':public_key_rec.n}
    enc_with_pub_key['enc_value'] = (str(your_encrypted_number.ciphertext()),your_encrypted_number.exponent)
    pk = enc_with_pub_key['public_key']
    public_key_rec = paillier.PaillierPublicKey(n=int(pk['n']))
    return paillier.EncryptedNumber(public_key_rec, int(enc_with_pub_key['enc_value'][0]), int(enc_with_pub_key['enc_value'][1]))

# Decrypts an encrypted number object, including difference and addition of encrypted numbers
def decrypt_value (private_key, public_key, ciphertext):
    public_key_rec = paillier.PaillierPublicKey(n=int(public_key['n']))
    enc_with_pub_key = {}
    enc_with_pub_key['public_key'] = { 'g':public_key_rec.g, 'n':public_key_rec.n}
    enc_with_pub_key['enc_value'] = (str(ciphertext.ciphertext()),ciphertext.exponent)
    enc_with_pub_key['private_key'] = { 'p':private_key.p, 'q':private_key.q}
    pri_key = enc_with_pub_key['private_key'] 
    private_key_rec = paillier.PaillierPrivateKey(public_key=public_key_rec, p=int(pri_key['p']), q=int(pri_key['q']))

    return(private_key_rec.decrypt(ciphertext))



if __name__ == '__main__':
    public_key, private_key = generate_paillier_keypair()
    number1 = 10
    number2 = 15
    number3 = 50
    encrypted_values = [encrypt_value(public_key, number1), encrypt_value(public_key, number2), encrypt_value(public_key, number3)]
    diff = encrypted_values[0] + encrypted_values[1] - encrypted_values[2] #should be 10 + 15 - 50 = -25
    
    print(decrypt_value(private_key, public_key, diff))