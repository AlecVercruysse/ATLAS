# run `tail -f /dev/ttyACM0 > /tmp/ser_out`

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import time

# https://stackoverflow.com/questions/6727875/hex-string-to-signed-int-in-python-3-2
def to_int(hexstr, bits):
    value = int(hexstr, 16)
    if value & (1 << (bits - 1)):
        value -= 1 << bits
    return value


def plot_complex(X, ax, title):
    re = ax.plot(np.real(X), 'x-', label='real')
    im = ax.plot(np.imag(X), 'x-', label='imag')
    ax.legend()
    ax.set_title(title)
    return re, im


fig = plt.figure(figsize=(5,4))
ax = plt.subplot(frameon=False)

def get_last_sample():
    fname = "/tmp/ser_out"
    tmp = "/tmp/current_sample_e155"
    with open(fname, "r", encoding="latin-1") as f:
        text = f.read()
        last_sample = text.split("--done--")[-2]
        last_sample = "\n".join(last_sample.split("\n")[3:])
        with open(tmp, 'w') as out:
            out.write(last_sample)
            
    out = np.loadtxt(tmp,
                 dtype='complex',
                 converters={0:lambda s: to_int(s[0:4], 16) + 1j*to_int(s[4:8], 16)})
    return out


X = get_last_sample()
# re, im = plot_complex(X, ax, "spectrum")
lines = ax.plot(np.arange(16), np.abs(X[0:16]), 'x-')
ax.set_ylim([0, 1000])
plt.draw()
plt.pause(1)

def update(*args):
    out = get_last_sample()
    lines[0].set_ydata(np.abs(out[0:16]))
    # print(out)
    # re[0].set_ydata(np.real(out))
    # im[0].set_ydata(np.imag(out))
    
    return lines

# anim = animation.FuncAnimation(fig, update, frames=1000)

for i in range(0, 1000):
    update()
    # fig.canvas.draw()
    plt.draw()
    plt.pause(0.2)
    # time.sleep(1)
