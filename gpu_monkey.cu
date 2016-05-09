#include <stdio.h>
#include "gpu_monkey.h"
#include "/usr/local/cuda/include/curand.h"
#include "/usr/local/cuda/include/curand_kernel.h"

/**
    The monkey simulator that takes a string and repeatedly creates random
    strings of equal length, until it matches the input string.
*/

void generateMonkey(char* genInput, int wordc)
{
	
//	printf("words: %s\n", genInput);
	/* Device pointers */
	int* d_key;
	int* d_key2;
	int* d_toklen;

	/* Host pointers*/
	int toklen[wordc];
	int key[wordc];
	int key2[wordc];

	int x = 0;

	/* Initialiizing array to 0 for both arrays of keys */
	while(x < wordc)
	{
		key[x] = 0;
		key2[x] = 0;
		x++;
	}

	char* saveWord = genInput;
	int tokiter = 0;
	/* strtok_r is used to parse the input for each word */
	char* token = strtok_r(genInput, "\t\n ", &saveWord);
	while(token != NULL)
	{
		/* Storing length of the word*/
		toklen[tokiter] = static_cast< int > (strlen(token));

		int i = 0;
		
		while(i < toklen[tokiter])
		{
			/* Generate a key for each word, based upon character and
			   order that characters appears...
			   key = (character position + 1) * character + character */


			// Calculates the key value for every lower case letter,
			//	when given a lowercase letter
			if(token[i] >= 97  &&  token[i] < 123)
			{
				key[tokiter] += (i + 1) * token[i] + token[i];
				key2[tokiter] += token[i];
				i++;
			}
			// Calculates the key value for every lower case letter,
			//	when given an uppercase letter
			else if(token[i] >= 65  &&  token[i] < 91)
			{
				key[tokiter] += (i + 1) * (token[i] + 32) +  (token[i] + 32);
				key2[tokiter] += (token[i] + 32);
				i++;
			}

			// Handles the appearence of special characters
			else
			{
				//loops to eliminate the special character from the word, for matching purposes
				int j;
				for(j = i; j < toklen[tokiter]; j++)
				{
					token[i] = token[i+1];
				}
				toklen[tokiter] = toklen[tokiter] - 1;
			}
		}
		tokiter++;                             
		token = strtok_r(NULL, "\n ", &saveWord);  
	}                                          

	printf("Word Count: %d\n", wordc);

	/* Allocate and memcopy first key */
	if(cudaMalloc((void**)&d_key, sizeof(int) * wordc) != cudaSuccess)
	{
		printf("Couldn't allocate memory for d_key\n");
		return;
	}

	if(cudaMemcpy(d_key, key, sizeof(int) * wordc,  cudaMemcpyHostToDevice) != cudaSuccess)
	{
		printf("Couldn't allocate memory for d_key\n");
		return;
	}

	/* Allocate and memcopy second key */
	if(cudaMalloc((void**)&d_key2, sizeof(int) * wordc) != cudaSuccess)
	{
		printf("Couldn't allocate memory for d_key\n");
		return;
	}

	if(cudaMemcpy(d_key2, key2, sizeof(int) * wordc,  cudaMemcpyHostToDevice) != cudaSuccess)
	{
		printf("Couldn't allocate memory for d_key\n");
		return;
	}

	/* Allocate and memcopy length of word */
	if(cudaMalloc((void**)&d_toklen, sizeof(int) * wordc) != cudaSuccess)
	{
		printf("Couldn't allocate memory for d_key\n");
		return;
	}

	if(cudaMemcpy(d_toklen, toklen, sizeof(int) * wordc,  cudaMemcpyHostToDevice) != cudaSuccess)
	{
		printf("Couldn't allocate memory for d_toklen\n");
		return;
	}

	/* Runtime Params:	"wordc" for the amount of blocks needed 
	   					"32" for the ammount of threads for each block
	   Arguments: 		"toklen" for the length of a word
	   					"d_key" for the generated key to check against
						"d_key2" for the generated key to check against
						"seed" to seed our cudarand function
						"wordc" to get the word count
	*/	

	/* rand used to seed curand in the kernel */
	srand(time(NULL));
	unsigned int seed = rand();
	monkey<<<wordc, 32>>>(d_toklen, d_key, d_key2, seed, wordc);

	/* Checking for last error*/
	cudaError_t err = cudaGetLastError();
	if (err != cudaSuccess) 
		    printf("Error: %s\n", cudaGetErrorString(err));

	/* Freeing allocated memory from device */
	cudaFree(d_key);
	cudaFree(d_toklen);
	cudaFree(d_key2);
}

__global__ void monkey(int* toklen, int* d_key, int* d_key2, unsigned int seed, int wordc)
{

	int id = blockIdx.x * blockDim.x + threadIdx.x;

	/* Condition was to check if thread id was between the largest thread id of the last block 
	   and the length of the word */
	if(id < blockIdx.x * blockDim.x + toklen[blockIdx.x] && id >= blockIdx.x * blockDim.x)
	{
		/*

		    	match       = simulates a boolean value. becomes 1 when the monkey
							matches the original input.
				count       = counts the number of attempts the monkey made
				key			= the random string created by the monkey
				random      = the random number generated
							0-25 correspond to the 26 letters of the alphabet
							26 corresponds to the space on the keyboard	
																				*/
		curandState_t state;

		/* Seed for random number for each thread to
		   choose a unique key from the assigned character*/
		curand_init(seed*(id + 1),0,0,&state);
		
		/* Keygen is for the first array of keys
		   Keygen2 is for the second array of keys
		   cumalitivekey 1 and 2 are the summation of
		   keygen 1 and 2 respectively */
		__shared__ int keygen[32];
		__shared__ int keygen2[32];
		__shared__ int cumulativekey;
		__shared__ int cumulativekey2;
		__shared__ int match;

		/* Initializing both arrays of keys to 0 */
		if(id == (blockIdx.x * blockDim.x))
		{
			match = 0;
			for(int x = 0; x < 32; x++)
			{
				keygen[x] = 0;
				keygen2[x] = 0;
			}
		}

		int count = 0;
		int random;
			/*
		    	Following loop creates a random string of appropriate length.
				The way that the cascading IF statements are set up optimize the
				random choosing of a letter.
					-   It takes 5 "decisions" to choose a letter based on the random number
					-   This process if done linearly, could take up to 26 "decisions" */
		int i = 0;
		while(i++ < 1000000000)   // Loops until the all threads matches the original input
		{
			if(id == (blockIdx.x * blockDim.x))
			{
				cumulativekey2 = 0;
				cumulativekey =0;
				count++;
			}	

			__syncthreads();
				random = curand(&state) % 10000;

				if(random < 8998)
				{
					if(random < 6128)
					{
						if(random < 3478)
						{
							if(random < 1965)
							{
								if(random < 1116)
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 101 + 101;   //e
									keygen2[threadIdx.x] = 101;   //e
								}
								else
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 97 + 97;    //a
									keygen2[threadIdx.x] = 97;   //a
								}
							}
							else
							{
								if(random < 2723)
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 114 + 114;   //r
									keygen2[threadIdx.x] = 114;   //r
								}
								else
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 105 + 105;   //i
									keygen2[threadIdx.x] = 105;   //i
								}
							}
						}
						else
						{
							if(random < 4889)
							{
								if(random < 4194)
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 111 + 111;   //o
									keygen2[threadIdx.x] = 111;   //o
								}
								else
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 116 + 116;   //t
									keygen2[threadIdx.x] = 116;   //t
								}
							}
							else
							{
								if(random < 5555)
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 110 + 110;   //n
									keygen2[threadIdx.x] = 110;   //n
								}
								else
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 115 + 115;   //s
									keygen2[threadIdx.x] = 115;   //s
								}
							}
						}
					}
					else
					{
						if(random < 7832)
						{
							if(random < 7131)
							{
								if(random < 6677)
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 108 + 108;   //l
									keygen2[threadIdx.x] = 108;   //l
								}
								else
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 99 + 99;    //c
									keygen2[threadIdx.x] = 99;   //c
								}
							}
							else
							{
								if(random < 7494)
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 117 + 117;   //u
									keygen2[threadIdx.x] = 117;   //u
								}
								else
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 100 + 100;   //d
									keygen2[threadIdx.x] = 100;   //d
								}
							}
						}
						else
						{
							if(random < 8450)
							{
								if(random < 8149)
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 112 + 112;   //p
									keygen2[threadIdx.x] = 112;   //p
								}
								else
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 109 + 109;   //m
									keygen2[threadIdx.x] = 109;   //m
								}
							}
							else
							{
								if(random < 8751)
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 104 + 104;   //h
									keygen2[threadIdx.x] = 104;   //h
								}
								else
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 103 + 103;   //g
									keygen2[threadIdx.x] = 103;   //g
								}
							}
						}
					}
				}
				else
				{
					if(random < 9960)
					{
						if(random < 9693)
						{
							if(random < 9386)
							{
								if(random < 9206)
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 98 + 98;    //b
									keygen2[threadIdx.x] = 98;   //b
								}
								else
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 102 + 102;   //f
									keygen2[threadIdx.x] = 102;   //f
								}
							}
							else
							{
								if(random < 9564)
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 121 + 121;   //y
									keygen2[threadIdx.x] = 121;   //y
								}
								else
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 119 + 119;   //w
									keygen2[threadIdx.x] = 119;   //w
								}
							}
						}
						else
						{
							if(random < 9904)
							{
								if(random < 9803)
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 107 + 107;   //k
									keygen2[threadIdx.x] = 107;   //k
								}
								else
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 118 + 118;   //v
									keygen2[threadIdx.x] = 118;   //v
								}
							}
							else
							{
								if(random < 9933)
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 120 + 120;   //x
									keygen2[threadIdx.x] = 120;   //x
								}
								else
								{
									keygen[threadIdx.x] = (threadIdx.x + 1) * 122 + 122;   //z
									keygen2[threadIdx.x] = 122;   //z
								}
							}
						}
					}
					else
					{
						if(random < 9980)
						{
							keygen[threadIdx.x] = (threadIdx.x + 1) * 106 + 106;   //j
							keygen2[threadIdx.x] = 106;   //j
						}
						else
						{
							keygen[threadIdx.x] = (threadIdx.x + 1) * 113 + 113 ;   //q
							keygen2[threadIdx.x] = 113;   //q
						}
					}
				}
				__syncthreads();

				/* Summation of the keys accumulated above */
				if(id == (blockIdx.x * blockDim.x))
				{
					for(int s = 0; s < toklen[blockIdx.x]; s++)
					{
						cumulativekey = cumulativekey + keygen[s];
						cumulativekey2 += keygen2[s];
					}
				}

				// Compare the keygen with the original input
				if(cumulativekey == d_key[blockIdx.x] && cumulativekey2 == d_key2[blockIdx.x]
						&& id == (blockIdx.x * blockDim.x))
					match = 1;
				__syncthreads();

				/* match is set if word was found 
				   and block leaves loop*/
				if(match)
					break;
				__syncthreads();
			}
	__syncthreads();
	}
}

