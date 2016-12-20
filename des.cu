#include <stdio.h>
#include <stdlib.h>
#include <time.h>

__device__ int IP[64];
__device__ int FP[64];
__device__ int E[48];
__device__ int P[32];
__device__ int SBox[8][64];


// Initial Permutation
int host_IP[64] = {
    57, 49, 41, 33, 25, 17,  9,  1,
    59, 51, 43, 35, 27, 19, 11,  3,
    61, 53, 45, 37, 29, 21, 13,  5,
    63, 55, 47, 39, 31, 23, 15,  7,
    56, 48, 40, 32, 24, 16,  8,  0,
    58, 50, 42, 34, 26, 18, 10,  2,
    60, 52, 44, 36, 28, 20, 12,  4,
    62, 54, 46, 38, 30, 22, 14,  6
};

// Final Permutation
int host_FP[64] = {
    39,  7, 47, 15, 55, 23, 63, 31,
    38,  6, 46, 14, 54, 22, 62, 30,
    37,  5, 45, 13, 53, 21, 61, 29,
    36,  4, 44, 12, 52, 20, 60, 28,
    35,  3, 43, 11, 51, 19, 59, 27,
    34,  2, 42, 10, 50, 18, 58, 26,
    33,  1, 41,  9, 49, 17, 57, 25,
    32,  0, 40,  8, 48, 16, 56, 24
};

// Expansion Function: from 32 bit to 48 bit
int host_E[48] = {
    31,  0,  1,  2,  3,  4,
     3,  4,  5,  6,  7,  8,
     7,  8,  9, 10, 11, 12,
    11, 12, 13, 14, 15, 16,
    15, 16, 17, 18, 19, 20,
    19, 20, 21, 22, 23, 24,
    23, 24, 25, 26, 27, 28,
    27, 28, 29, 30, 31,  0
};

// Permutation
int host_P[32] = {
    15,  6, 19, 20, 28, 11, 27, 16,
     0, 14, 22, 25,  4, 17, 30,  9,
     1,  7, 23, 13, 31, 26,  2,  8,
    18, 12, 29,  5, 21, 10,  3, 24
};

int PC1_LEFT[28] = {
    56, 48, 40, 32, 24, 16,  8,
     0, 57, 49, 41, 33, 25, 17,
     9,  1, 58, 50, 42, 34, 26,
    18, 10,  2, 59, 51, 43, 35,
};

int PC1_RIGHT[28] = {
    62, 54, 46, 38, 30, 22, 14,
     6, 61, 53, 45, 37, 29, 21,
    13,  5, 60, 52, 44, 36, 28,
    20, 12,  4, 27, 19, 11,  3
};

int PC2[48] = {
    13, 16, 10, 23,  0,  4,
     2, 27, 14,  5, 20,  9,
    22, 18, 11,  3, 25,  7,
    15,  6, 26, 19, 12,  1,
    40, 51, 30, 36, 46, 54,
    29, 39, 50, 44, 32, 47,
    43, 48, 38, 55, 33, 52,
    45, 41, 49, 35, 28, 31
};

int Rotations[16] = {1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1};

// Substitution Boxes
int host_SBox[8][64] = {
    // S1
    {
        14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7,
        0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8,
        4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0,
        15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13
    },

    // S2
    {
        15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10,
        3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5,
        0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15,
        13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9
    },

    // S3
    {
        10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8,
        13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1,
        13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7,
        1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12
    },

    // S4
    {
        7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 4, 15,
        13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9,
        10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4,
        3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14
    },

    // S5
    {
        2, 12, 4, 1, 7, 10, 11, 6, 8, 5, 3, 15, 13, 0, 14, 9,
        14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6,
        4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14,
        11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3
    },

    // S6
    {
        12, 1, 10, 15, 9, 2, 6, 8, 0, 13, 3, 4, 14, 7, 5, 11,
        10, 15, 4, 2, 7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8,
        9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6,
        4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13
    },

    // S7
    {
        4, 11, 2, 14, 15, 0, 8, 13, 3, 12, 9, 7, 5, 10, 6, 1,
        13, 0, 11, 7, 4, 9, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6,
        1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2,
        6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12
    },

    // S8
    {
        13, 2, 8, 4, 6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7,
        1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2,
        7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8,
        2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11
    }
};

__device__
__host__
long long int permutation(long long int data, int data_size, int *table, int table_size) {
    long long int result = 0;
    int i = 0;
    for (; i < table_size; i++) {
        result = (result << 1) + ((data >> (data_size - 1 - table[i])) & 0x1);
    }
    return result;
}

long long int *generate_sub_keys(long long int key, int decrypt) {
    int n_keys = 16;
    long long int *sub_keys = (long long int *) malloc(sizeof(long long int) * n_keys);
    int half_key_length = 28;
    long long int left = permutation(key, 64, PC1_LEFT, half_key_length);
    long long int right = permutation(key, 64, PC1_RIGHT, half_key_length);
    int i = 0;
    for (; i < n_keys; i++) {
        int rotation = Rotations[i];
        left = (((left << rotation) | (left >> (half_key_length - rotation))) & 0xFFFFFFF);
        right = (((right << rotation) | (right >> (half_key_length - rotation))) & 0xFFFFFFF);
        long long int new_key = (left << half_key_length) | right;
        int sub_key_index = (decrypt ? 15 - i : i);
        sub_keys[sub_key_index] = permutation(new_key, half_key_length * 2, PC2, 48);
    }
    return sub_keys;
}

__device__
long long int substitution(long long int data) {
    // data: 48 bit
    long long int result = 0;
    int i = 0;
    for (; i < 8; i++) {
        unsigned int box = data >> (6 * (7 - i)) & 0x3F;
        int outer = ((box & 0x20) >> 4) | (box & 0x1);
        int inner = (box & 0x1E) >> 1;
        result = (result << 4) + SBox[i][(outer << 4) + inner];
    }
    return result;
}

__device__
long int F(unsigned int c, long long int key) {
    long long int lc = c;
    long long int new_c = permutation(lc, 32, E, 48);
    long long int mixed_data = new_c ^ key;
    long long int s_box_result = substitution(mixed_data);
    return permutation(s_box_result, 32, P, 32);
}

__device__
void DES(int index, long long int *MD, long long int *keys) {
    long long int data = permutation(MD[index], 64, IP, 64);
    unsigned int left = data >> 32;
    unsigned int right = (int) data;
    int i = 0;
    for (; i < 16; i++) {
        unsigned int buf = left ^ F(right, keys[i]);
        left = right;
        right = buf;
    }
    data = right;
    data = (data << 32) + left;
    MD[index] = permutation(data, 64, FP, 64);
}

__global__
void kernel_DES(unsigned int quota, unsigned int n_blocks, long long int *MD, long long int *keys) {
    int start_index = (blockIdx.x * blockDim.x + threadIdx.x) * quota;
    int end_index = start_index + quota;
    int i;
    for (i = start_index; i < end_index; i++) {
        if (i >= n_blocks) {
        return;
        }
        DES(i, MD, keys);
    }
}

void runDESCuda(unsigned int n_blocks, long long int *host_MD, long long int *host_sub_keys, int n_cuda_blocks, int n_cuda_threads) {
    unsigned int max_n_threads = 512;
    if (n_cuda_blocks == -1 && n_cuda_threads == -1) {
        n_cuda_threads = max_n_threads;
        n_cuda_blocks = (n_blocks + max_n_threads - 1) / max_n_threads;
    }
    if (n_cuda_threads > max_n_threads) {
        printf("Maximum value of the number of threads is 512. You entered : %d\n", n_cuda_threads);
        return;
    }
    cudaMemcpyToSymbol(IP, host_IP, sizeof(host_IP));
    cudaMemcpyToSymbol(FP, host_FP, sizeof(host_FP));
    cudaMemcpyToSymbol(E, host_E, sizeof(host_E));
    cudaMemcpyToSymbol(P, host_P, sizeof(host_P));
    cudaMemcpyToSymbol(SBox, host_SBox, sizeof(host_SBox));

    long long int *MD, *sub_keys;
    cudaMalloc((void **) &MD, sizeof(long long int) * n_blocks);
    cudaMemcpy(MD, host_MD, sizeof(long long int) * n_blocks, cudaMemcpyHostToDevice);
    cudaMalloc((void **) &sub_keys, sizeof(long long int) * 16);
    cudaMemcpy(sub_keys, host_sub_keys, sizeof(long long int) * 16, cudaMemcpyHostToDevice);
    unsigned int quota = n_blocks / (n_cuda_blocks * n_cuda_threads) + 1;
    printf("%u bytes per threads.\n", quota * 64);
    kernel_DES<<<n_cuda_blocks, n_cuda_threads>>>(quota, n_blocks, MD, sub_keys);
    cudaMemcpy(host_MD, MD, sizeof(long long int) * n_blocks, cudaMemcpyDeviceToHost);

    cudaFree(IP);
    cudaFree(FP);
    cudaFree(E);
    cudaFree(P);
    cudaFree(SBox);
    cudaFree(MD);
    cudaFree(sub_keys);
}

unsigned int n_blocks = 0;
void des_with_file(int decrypt, char *in, char *out, char *key, int n_cuda_blocks, int n_cuda_threads) {
    int buf_size = 8 * n_blocks;
    char *buf = (char *) malloc(sizeof(char) * buf_size);
    FILE *in_fp = fopen(in, "rb");
    if (in_fp == NULL) {
        printf("Can't open the in file :%s\n", in);
        return;
    }
    fread(buf, buf_size, 1, in_fp);
    fclose(in_fp);

    long long int *MD = (long long int *) malloc(sizeof(long long int) * n_blocks);
    int i = 0;
    int j = 0;
    for (i = 0; i < n_blocks; i++) {
        long long int block = 0;
        for (j = 0; j < 8; j++) {
            block = (block << 8) + (buf[(i * 8) + j] & 0xFF);
        }
        MD[i] = block;
    }
    long long int binary_key = 0;
    for (i = 0; i < 8; i++) {
        binary_key = (binary_key << 8) + (key[i] & 0xFF);
    }

    long long int *sub_keys = generate_sub_keys(binary_key, decrypt);
    clock_t begin = clock();
    runDESCuda(n_blocks, MD, sub_keys, n_cuda_blocks, n_cuda_threads);
    clock_t end = clock();
    double time_spent = (double) (end - begin) / CLOCKS_PER_SEC;
    printf("CUDA time: %f\n", time_spent);
    free(sub_keys);

    for (i = 0; i < n_blocks; i++) {
        for (j = 0; j < 8; j++) {
            buf[(i * 8) + (7 - j)] = ((MD[i] >> (j * 8)) & 0xFF);
        }
    }
    FILE *out_fp = fopen(out, "wb");
    if (out_fp == NULL) {
        printf("Can't open the out file :%s\n", out);
        return;
    }
    fwrite(buf, buf_size, 1, out_fp);
    fclose(out_fp);
    free(buf);
    free(MD);
}

void encryption(char *in, char *out, char *key, int n_cuda_blocks, int n_cuda_threads) {
    des_with_file(0, in, out, key, n_cuda_blocks, n_cuda_threads);
}

void decryption(char *in, char *out, char *key, int n_cuda_blocks, int n_cuda_threads) {
    des_with_file(1, in, out, key, n_cuda_blocks, n_cuda_threads);
}

int main(int argc, char** argv) {
    if (argc < 6) {
        printf("usage) ./des.out [e|d] <input_file> <output_file> <n_des_block_size> <n_cuda_blocks> <n_cuda_threads>\n");
        printf("example) ./des.out e in.txt out.txt 1\n");
        return -1;
    }
    int n_cuda_blocks;
    int n_cuda_threads;
    sscanf(argv[5], "%d", &n_blocks);
    sscanf(argv[6], "%d", &n_cuda_blocks);
    sscanf(argv[7], "%d", &n_cuda_threads);
    switch(argv[1][0]) {
        case 'e':
            printf("encryption\n");
            encryption(argv[2], argv[3], argv[4], n_cuda_blocks, n_cuda_threads);
            break;
        case 'd':
            printf("decryption\n");
            decryption(argv[2], argv[3], argv[4], n_cuda_blocks, n_cuda_threads);
            break;
        default:
            printf("mode must be 'e' or 'd'\n");
    }
}
