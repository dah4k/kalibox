from Crypto.Util.number import bytes_to_long, getPrime, GCD
from Crypto.Util.Padding import pad
from secret import FLAG

WELCOME = '''Welcome to my custom PSA cryptosystem!
In this cryptosystem, the message is PKCS#7 padded and then encrypted with RSA.
They say padding makes encryption more secure, right? ;)'''

MENU = '''
[1] Encrypt the flag
[2] Exit
'''


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


def main():
    psa = PSA()
    print(WELCOME)
    while True:
        try:
            print(MENU)
            opt = input('> ')
            if opt == '1':
                enc, modulus = psa.encrypt(FLAG)
                print(f"\n{hex(enc)}\n{hex(modulus)}")
            elif opt == '2':
                print('Bye.')
                exit(1)
            else:
                print('\nInvalid option!')
        except:
            print('\n\nSomething went wrong.')
            exit(1)


if __name__ == '__main__':
    main()
