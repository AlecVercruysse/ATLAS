# Alec Vercruysse
# 2021-11-14
# generate N-point q-bit two's complement integer hann windowing
import numpy as np

N = 2048
q = 16    # 24 max

n = np.arange(N)
hann = np.sin(np.pi*n/N)**2
hann = (hann * (2**(q-1) - 1)).astype('uint') # discretize
with open("hann.vectors", 'w') as f:
    for i in range(len(hann)):
        f.write(f"{hann[i]:024b}"[-q:] + "\n")
