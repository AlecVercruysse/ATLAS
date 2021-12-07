import librosa as lb
import numpy as np

# based on the int2bin fn in /fpga/rom/twiddle.py
def int2hex(integer, digits):
    if integer >= 0:
        return hex(integer)[2:].zfill(digits)
    else:
        return hex(2**(4*digits) + integer)[2:]

i2h = np.vectorize(int2hex)


sr = int(12e6/256) # ~44 kHz
song, sr = lb.load("do_it_to_it.mp3", sr=sr)
song = (song*(2**23-1)).astype('int32') # discretize to 24-bit samples
song_hex = i2h(song, 6)

with open("../fpga/simulation/modelsim/rom/toplevel_test_in.memh", "w") as f:
    for sample in song_hex:
        f.write(sample + "\n");
