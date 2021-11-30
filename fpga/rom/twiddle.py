# Alec Vercruysse
# 2021-11-16
# generate N-point q-bit two's complement integer twiddle bits

# this is generated using Slade as a refernce, so note the sign of the twiddle exponent is positive.
# this matches table II in slade for the most part, except in some small instances where it seems that his binary representations are a bit off the real numbers.

import numpy as np


# required since we need signed represntation
# https://stackoverflow.com/questions/699866/python-int-to-binary-string

def int2bin(integer, digits):
    if integer >= 0:
        return bin(integer)[2:].zfill(digits)
    else:
        return bin(2**digits + integer)[2:]


i2b = np.vectorize(int2bin)

N = 32
q = 16

n = np.arange(N/2)
#wi = np.exp(1j * np.pi*2/N)
#w = np.power(wi, n)

#w_re = np.real(w)
w_re = np.cos(2*np.pi*n/N)
w_re = (w_re * (2**(q-1) - 1)).astype('int')
w_re = i2b(w_re, q)

# w_im = np.imag(w)
w_im = -np.sin(2*np.pi*n/N)
w_im = (w_im * (2**(q-1) - 1)).astype('int')
w_im = i2b(w_im, q)

with open("twiddle.vectors", 'w') as f:
    for i in range(len(w_re)):
        f.write(w_re[i] + "" + w_im[i] + "\n")

with open("../simulation/modelsim/rom/twiddle.vectors", 'w') as f:
    for i in range(len(w_re)):
        f.write(w_re[i] + "" + w_im[i] + "\n")

