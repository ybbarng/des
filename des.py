from itertools import accumulate


# Initial Permutation
IP = [
    57, 49, 41, 33, 25, 17,  9,  1,
    59, 51, 43, 35, 27, 19, 11,  3,
    61, 53, 45, 37, 29, 21, 13,  5,
    63, 55, 47, 39, 31, 23, 15,  7,
    56, 48, 40, 32, 24, 16,  8,  0,
    58, 50, 42, 34, 26, 18, 10,  2,
    60, 52, 44, 36, 28, 20, 12,  4,
    62, 54, 46, 38, 30, 22, 14,  6
]

# Final Permutation
FP = [
    39,  7, 47, 15, 55, 23, 63, 31,
    38,  6, 46, 14, 54, 22, 62, 30,
    37,  5, 45, 13, 53, 21, 61, 29,
    36,  4, 44, 12, 52, 20, 60, 28,
    35,  3, 43, 11, 51, 19, 59, 27,
    34,  2, 42, 10, 50, 18, 58, 26,
    33,  1, 41,  9, 49, 17, 57, 25,
    32,  0, 40,  8, 48, 16, 56, 24
]

# Expansion Function: from 32 bit to 48 bit
E = [
    31,  0,  1,  2,  3,  4,
     3,  4,  5,  6,  7,  8,
     7,  8,  9, 10, 11, 12,
    11, 12, 13, 14, 15, 16,
    15, 16, 17, 18, 19, 20,
    19, 20, 21, 22, 23, 24,
    23, 24, 25, 26, 27, 28,
    27, 28, 29, 30, 31,  0
]

# Permutation
P = [
    15,  6, 19, 20, 28, 11, 27, 16,
     0, 14, 22, 25,  4, 17, 30,  9,
     1,  7, 23, 13, 31, 26,  2,  8,
    18, 12, 29,  5, 21, 10,  3, 24
]

PC1_LEFT = [
    56, 48, 40, 32, 24, 16,  8,
     0, 57, 49, 41, 33, 25, 17,
     9,  1, 58, 50, 42, 34, 26,
    18, 10,  2, 59, 51, 43, 35,
]

PC1_RIGHT = [
    62, 54, 46, 38, 30, 22, 14,
     6, 61, 53, 45, 37, 29, 21,
    13,  5, 60, 52, 44, 36, 28,
    20, 12,  4, 27, 19, 11,  3
]

PC2 = [
    13, 16, 10, 23,  0,  4,
     2, 27, 14,  5, 20,  9,
    22, 18, 11,  3, 25,  7,
    15,  6, 26, 19, 12,  1,
    40, 51, 30, 36, 46, 54,
    29, 39, 50, 44, 32, 47,
    43, 48, 38, 55, 33, 52,
    45, 41, 49, 35, 28, 31
]

Rotations = [1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1]

# Substitution Boxes
SBox = [
    # S1
    [
        14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7,
        0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8,
        4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0,
        15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13
    ],

    # S2
    [
        15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10,
        3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5,
        0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15,
        13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9
    ],

    # S3
    [
        10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8,
        13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1,
        13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7,
        1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12
    ],

    # S4
    [
        7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 4, 15,
        13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9,
        10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4,
        3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14
    ],

    # S5
    [
        2, 12, 4, 1, 7, 10, 11, 6, 8, 5, 3, 15, 13, 0, 14, 9,
        14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6,
        4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14,
        11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3
    ],

    # S6
    [
        12, 1, 10, 15, 9, 2, 6, 8, 0, 13, 3, 4, 14, 7, 5, 11,
        10, 15, 4, 2, 7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8,
        9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6,
        4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13
    ],

    # S7
    [
        4, 11, 2, 14, 15, 0, 8, 13, 3, 12, 9, 7, 5, 10, 6, 1,
        13, 0, 11, 7, 4, 9, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6,
        1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2,
        6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12
    ],

    # S8
    [
        13, 2, 8, 4, 6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7,
        1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2,
        7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8,
        2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11
    ]
]


def DES(decrypt, MD, keys):
    sub_keys = generate_sub_keys(keys)
    data = permutation(MD, IP)
    left = data[:32]
    right = data[32:]
    if decrypt:
        sub_keys = reversed(sub_keys)
    for sub_key in sub_keys:
        left, right = right, xor(left, F(right, sub_key))
    data = permutation(right + left, FP)
    return data


def F(c, key):
    new_c = expansion(c)
    mixed_data = key_mixing(new_c, key)
    s_box_result = substitution(mixed_data)
    return permutation(s_box_result)


def generate_sub_keys(keys):
    left = permutation(keys, PC1_LEFT)
    right = permutation(keys, PC1_RIGHT)
    sub_keys = []
    for i in accumulate(Rotations):
        sub_keys.append(permutation(left[i:] + left[:i] + right[i:] + right[:i], PC2))
    return sub_keys


def expansion(c):
    return permutation(c, E)


def permutation(data, table=P):
    return [data[i] for i in table]


def key_mixing(data, key):
    return xor(data, key)


def xor(data1, data2):
    return [d1 ^ d2 for d1, d2 in zip(data1, data2)]


def substitution(data):
    '''
        data: 48 bit
    '''
    box_size = 6
    boxes = [data[i:i + box_size] for i in range(0, 48, box_size)]
    result = []
    for box, s_box in zip(boxes, SBox):
        outer = (box[0] << 1) + box[5]
        inner = (box[1] << 3) + (box[2] << 2) + (box [3] << 1) + box[4]
        value = s_box[(outer << 4) + inner]
        for i in range(3, -1, -1):
            result.append((value & 2**i) >> i)
    return result


def string_to_bitlist(data):
    result = []
    for ch in data:
        for i in range(7, -1, -1):
            result.append(1 if ord(ch) & (1 << i) != 0 else 0)
    return result


def hex_to_bitlist(data):
    result = []
    for ch in data:
        int(ch, 16)
        for i in range(3, -1, -1):
            result.append(1 if int(ch, 16) & (1 << i) != 0 else 0)
    return result


def bitlist_to_hex(data):
    result = []
    buf = 0
    for i, value in enumerate(data):
        buf = (buf << 1) + value
        if i % 4 == 3:
            result.append(hex(buf)[2:])
            buf = 0
    return ''.join(result)


def binary_to_bitlist(data):
    return hex_to_bitlist(''.join('{:02x}'.format(ch) for ch in data))


def bitlist_to_binary(data):
    return bytearray.fromhex(bitlist_to_hex(data))


def des_with_file(decrypt, in_file, out_file, key):
    with open(in_file, 'rb') as f:
        data = f.read()
    result = DES(decrypt, binary_to_bitlist(data), string_to_bitlist(key))
    with open(out_file, 'wb') as f:
        f.write(bitlist_to_binary(result))


def encryption(in_file, out_file, key):
    des_with_file(False, in_file, out_file, key)


def decryption(in_file, out_file, key):
    des_with_file(True, in_file, out_file, key)


def test():
    key = string_to_bitlist('TESTTEST')
    # plain = string_to_bitlist('DESTESTT')
    plain = hex_to_bitlist('4445535445535454') # DESTESTT
    encrypt = hex_to_bitlist('01ecf0428c98db57')
    data = DES(False, plain, key)
    print(encrypt == data)
    new_data = DES(True, data, key)
    print(new_data == plain)


if __name__ == '__main__':
    from sys import argv

    modes = {
        'e': encryption,
        'd': decryption
    }
    if argv[1] not in modes:
        print('mode must be \'e\' or \'d\'')
    else:
        modes[argv[1]](*argv[2:])

