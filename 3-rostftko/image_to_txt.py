"""image_to_txt.py
"""

import numpy as np
import matplotlib.pyplot as plt

from scipy import misc


def data_reduction(X, num_filt):
    f = np.arange(X.shape[0])
    f_edges = np.linspace(f[0], f[-1], num_filt+2)

    lo = f_edges[:-2,None]
    hi = f_edges[2:,None]
    w  = np.diff(f_edges)[:,None]

    mx = 2/(hi-lo) * np.maximum(0, np.minimum(
        (f - lo)/w[:-1], (hi - f)/w[1:]))

    return np.dot(mx, X)

def image_to_txt(fname, rows):
    # reads in the jpg
    X = misc.imread(fname)
    X = X[:, :, 0] + X[:, :, 1] + X[:, :, 2]

    # standardize
    X = (X - np.mean(X)) / np.std(X)
    # normalize
    # X = X/np.max(X)

    X = data_reduction(X, rows)
    X = X[::-1]
    # X = np.vstack((X[::-1], X))

    # creates the header so ChucK knows what the shape is
    head = str(X.shape[0]) + " " + str(X.shape[1])

    saveas = fname.split('.')[0] + '.txt'
    np.savetxt(saveas, X.T, header=head)
    #txt = np.loadtxt(saveas)
    #plt.imshow(txt, interpolation='nearest', aspect='auto', origin='lower')
    #plt.show()


size = 1024
image_to_txt('orange_l.jpg', size)
image_to_txt('orange_r.jpg', size)
# image_to_txt('red_l.jpg', size)
# image_to_txt('red_r.jpg', size)
# image_to_txt('blue_l.jpg', size)
# image_to_txt('blue_r.jpg', size)
