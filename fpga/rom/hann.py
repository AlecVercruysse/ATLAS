# Alec Vercruysse
# 2021-11-14
# generate N-point q-bit two's complement integer hann windowing
import numpy as np


def int2bin(integer, digits):
    if integer >= 0:
        return bin(integer)[2:].zfill(digits)
    else:
        return bin(2**digits + integer)[2:]


i2b = np.vectorize(int2bin)

N = 2048
q = 11  # q - 5 (to account for bit growth during operation). TODO more needed?    # 24 max

n = np.arange(N)
hann = np.sin(np.pi*n/N)**2
hann = (hann * (2**(q-1) - 1)).astype('uint') # discretize
with open("hann.vectors", 'w') as f:
    for i in range(len(hann)):
        f.write(int2bin(hann[i], q) + "\n")
        #f.write(f"{hann[i]:024b}"[-q:] + "\n")
