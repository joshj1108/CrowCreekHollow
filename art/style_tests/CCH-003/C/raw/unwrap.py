"""Some create_image_pro candidates come back cyclically shifted (the object wraps round the canvas edges).
unwrap() rolls the image so the longest empty run of rows and of columns sits at the edges."""
import numpy as np


def _shift(occ):
    n = len(occ)
    best, best_end = 0, None
    for start in range(n):
        if occ[start]:
            continue
        k = 0
        while k < n and not occ[(start + k) % n]:
            k += 1
        if k > best:
            best, best_end = k, (start + k) % n
    return 0 if best_end is None else -best_end


def unwrap(a):
    al = a[..., 3] > 0
    a = np.roll(a, _shift(al.any(1)), axis=0)
    al = a[..., 3] > 0
    return np.roll(a, _shift(al.any(0)), axis=1)
