import random
import math

# Generate a random prime number of a given bit length
def generate_prime(bit_length):
    while True:
        num = random.getrandbits(bit_length)
        print(num)
        if is_prime(num):
            return num

# Check if a number is prime
def is_prime(n):
    if n <= 1:
        return False
    for i in range(2, int(math.sqrt(n)) + 1):
        if n % i == 0:
            return False
    return True

# Extended Euclidean Algorithm to find modular inverse
def extended_gcd(a, b):
    if a == 0:
        return b, 0, 1
    g, y, x = extended_gcd(b % a, a)
    return g, x - (b // a) * y, y

# Modular inverse using Extended Euclidean Algorithm
def mod_inverse(a, m):
    g, x, y = extended_gcd(a, m)
    if g != 1:
        raise ValueError("Modular inverse does not exist")
    return x % m

# ElGamal key generation
def key_generation(bit_length):
    p = generate_prime(bit_length)
    g = random.randint(2, p - 1)
    x = random.randint(1, p - 1)
    h = pow(g, x, p)
    public_key = (p, g, h)
    private_key = x
    return public_key, private_key

# ElGamal encryption
def encryption(public_key, plaintext):
    p, g, h = public_key
    r = random.randint(1, p - 1)
    c1 = pow(g, r, p)
    s = pow(h, r, p)
    c2 = (plaintext * s) % p
    return c1, c2

# ElGamal decryption
def decryption(public_key, private_key, ciphertext):
    p, _, _ = public_key
    c1, c2 = ciphertext
    s = pow(c1, private_key, p)
    plaintext = (c2 * mod_inverse(s, p)) % p
    return plaintext

# Homomorphic addition of encrypted values
def add_encrypted_values(public_key, ciphertext1, ciphertext2):
    c1_1, c2_1 = ciphertext1
    c1_2, c2_2 = ciphertext2
    c1_sum = (c1_1 * c1_2) % public_key[0]
    c2_sum = (c2_1 * c2_2) % public_key[0]
    return c1_sum, c2_sum

# Homomorphic subtraction of encrypted values
def subtract_encrypted_values(public_key, ciphertext1, ciphertext2):
    c1_1, c2_1 = ciphertext1
    c1_2, c2_2 = ciphertext2
    c1_diff = (c1_1 * mod_inverse(c1_2, public_key[0])) % public_key[0]
    c2_diff = (c2_1 * mod_inverse(c2_2, public_key[0])) % public_key[0]
    return c1_diff, c2_diff

# Example usage
if __name__ == "__main__":
    # Key generation (bit_length should be chosen carefully)
    bit_length = 256
    public_key, private_key = key_generation(bit_length)

    # Plaintext values (integers)
    plaintext1 = 42
    plaintext2 = 18

    # ElGamal encryption
    ciphertext1 = encryption(public_key, plaintext1)
    ciphertext2 = encryption(public_key, plaintext2)

    # Homomorphic addition and subtraction
    added_ciphertext = add_encrypted_values(public_key, ciphertext1, ciphertext2)
    subtracted_ciphertext = subtract_encrypted_values(public_key, ciphertext1, ciphertext2)

    # ElGamal decryption of the homomorphically added and subtracted ciphertexts
    added_decrypted = decryption(public_key, private_key, added_ciphertext)
    subtracted_decrypted = decryption(public_key, private_key, subtracted_ciphertext)

    print(f"Plaintext 1: {plaintext1}")
    print(f"Plaintext 2: {plaintext2}")
    print(f"Ciphertext 1: {ciphertext1}")
    print(f"Ciphertext 2: {ciphertext2}")
    print(f"Added Ciphertext: {added_ciphertext}")
    print(f"Added Decrypted: {added_decrypted}")
    print(f"Subtracted Ciphertext: {subtracted_ciphertext}")
    print(f"Subtracted Decrypted: {subtracted_decrypted}")
