#!/usr/bin/env python3
from Crypto.Util.number import bytes_to_long, getPrime, GCD
from Crypto.Util.Padding import pad
from pprint import pformat
from secret import FLAG

class PSA:
    def __init__(self):
        self.bit_size = 512
        self.e = 11

    def gen_modulus(self):
        while True:
            p = getPrime(self.bit_size // 2)
            q = getPrime(self.bit_size // 2)
            if GCD(self.e, (p - 1) * (q - 1)) == 1:
                break
        return p * q

    def encrypt(self, msg):
        m = bytes_to_long(pad(msg, 16))
        n = self.gen_modulus()
        c = pow(m, self.e, n)
        return c, n

    def encrypt_no_pad(self, msg):
        m = bytes_to_long(msg)
        n = self.gen_modulus()
        c = pow(m, self.e, n)
        return c, n

def main():
    psa = PSA()
    C = []
    N = []
    for x in range(0, psa.e):
        c, n = psa.encrypt(FLAG)
        C.append(hex(c))
        N.append(hex(n))
    print("# Moduli\nN =", pformat(N).replace("'", ""))
    print("\n# Public exponent\ne =", psa.e )
    print("\n# Ciphertexts\nC =", pformat(C).replace("'", ""))

if __name__ == '__main__':
    main()
