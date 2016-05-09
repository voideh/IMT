#ifndef __GPU_MONKEY_H__
#define __GPU_MONKEY_H__

#include <stdio.h>
#include "/usr/local/cuda/include/cuda.h"
#include "/usr/local/cuda/include/cuda_runtime_api.h"
#include "/usr/local/cuda/include/device_launch_parameters.h"

void generateMonkey(char* getInput, int wordc);

__global__ void monkey(int* toklen, int* d_key, int* d_key2, unsigned int seed, int wordc);

#endif
