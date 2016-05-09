#include <stdio.h>
#include <stdlib.h>
#include <time.h>       // for the random number generator
#include "gpu_monkey.h"
#include <string.h>

#define MAX_INPUT_BUFF 100   // the max number of characters for input

void monkey(char input[] , int length);
/**
    The main function that takes user input
    and tells Caesar to get to work
*/

using namespace std;
int main()
{
    /*
        genInput    =   input array with size equal to MAX_INPUT
        inputSize   =   length of the user-input string
        input       =   custom fit array for the user input
    */

    clock_t start, end;     // define the start and stop times of the program
    double cpu_time_used;   // for the final time calculation
    int num_words = 0;
    char* token;	    // pointer to input text words


	int a = 6;
	int b = 8;
	int c;

	addc(a, b, &c);

    printf("Enter a string --> ");

    char genInput[MAX_INPUT_BUFF];
	char* saveWord = genInput;

    fgets(genInput , MAX_INPUT_BUFF , stdin);

	start = clock();

	token = strtok_r(genInput, "\n ", &saveWord);
	while(token != NULL){

   	monkey(token, strlen(token));
	
	token = strtok_r(NULL, "\n ", &saveWord);
	}

    end = clock();  // time at end of program run
    cpu_time_used = ((double) (end - start))  / CLOCKS_PER_SEC;

    int cpu_int = (int)cpu_time_used;
    double cpu_dec = cpu_time_used - cpu_int;

    int minutes = cpu_time_used / 60;
    double seconds = (int)(cpu_time_used) % 60;
    seconds = seconds + cpu_dec;

    printf("Total Time: %d min, %.3f sec\n" , minutes, seconds);

    return 1;
}
void monkey(char input[],int length)
{
	/*
        match       = simulates a boolean value. becomes 1 when the monkey
                        matches the original input.
        count       = counts the number of attempts the monkey made
        possibility = the random string created by the monkey
        random      = the random number generated
                        0-25 correspond to the 26 letters of the alphabet
                        26 corresponds to the space on the keyboard
    */
    srand(time(NULL));

    int random;
    int match = 0;
    int count = 0;
    char possibility[length];

    while(!match)   // Loops until the monkey matches the original input
    {
        count++;
        if(count % 1000000 == 0)
        {
            printf("Count = %d Million\n" , count / 1000000);
        }
        int i;
    
        /*
            Following loop creates a random string of appropriate length.
            The way that the cascading IF statements are set up optimize the
            random choosing of a letter.
                -   It takes 5 "decisions" to choose a letter based on the random number
                -   This process if done linearly, could take up to 26 "decisions"
        */

        for(i = 0; i< length ; i++)
        {

            random = rand() % 10000;

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
                                possibility[i] = 101;   //e
                            }
                            else
                            {
                                possibility[i] = 97;    //a
                            }
                        }
                        else
                        {
                            if(random < 2723)
                            {
                                possibility[i] = 114;   //r
                            }
                            else
                            {
                                possibility[i] = 105;   //i
                            }
                        }
                    }
                    else
                    {
                        if(random < 4889)
                        {
                            if(random < 4194)
                            {
                                possibility[i] = 111;   //o
                            }
                            else
                            {
                                possibility[i] = 116;   //t
                            }
                        }
                        else
                        {
                            if(random < 5555)
                            {
                                possibility[i] = 110;   //n
                            }
                            else
                            {
                                possibility[i] = 115;   //s
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
                                possibility[i] = 108;   //l
                            }
                            else
                            {
                                possibility[i] = 99;    //c
                            }
                        }
                        else
                        {
                            if(random < 7494)
                            {
                                possibility[i] = 117;   //u
                            }
                            else
                            {
                                possibility[i] = 100;   //d
                            }
                        }
                    }
                    else
                    {
                        if(random < 8450)
                        {
                            if(random < 8149)
                            {
                                possibility[i] = 112;   //p
                            }
                            else
                            {
                                possibility[i] = 109;   //m
                            }
                        }
                        else
                        {
                            if(random < 8751)
                            {
                                possibility[i] = 104;   //h
                            }
                            else
                            {
                                possibility[i] = 103;   //g
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
                                possibility[i] = 98;    //b
                            }
                            else
                            {
                                possibility[i] = 102;   //f
                            }
                        }
                        else
                        {
                            if(random < 9564)
                            {
                                possibility[i] = 121;   //y
                            }
                            else
                            {
                                possibility[i] = 119;   //w
                            }
                        }
                    }
                    else
                    {
                        if(random < 9904)
                        {
                            if(random < 9803)
                            {
                                possibility[i] = 107;   //k
                            }
                            else
                            {
                                possibility[i] = 118;   //v
                            }
                        }
                        else
                        {
                            if(random < 9933)
                            {
                                possibility[i] = 120;   //x
                            }
                            else
                            {
                                possibility[i] = 122;   //z
                            }
                        }
                    }
                }
                else
                {
                    if(random < 9980)
                    {
                        possibility[i] = 106;   //j
                    }
                    else
                    {
                        possibility[i] = 113;   //q
                    }
                }
            }

        }
        // Compare the possibility with the original input
        for(i = 0; i < length; i++)
        {
            if(possibility[i] != input[i])
            {
                match = 0;
                break;
            }
            else
            {
                match = 1;
            }
        }
    }

    if(count == 1)
    {
        printf("It took the Caesar 1 try to match your input!\n");
    }
    else
    {
        printf("It took the Caesar %d tries to match your input!\n" , count);
    }

	int x;
	for(x = 0; x < length; x++)
		printf("%c", possibility[x]);
    return;
}

