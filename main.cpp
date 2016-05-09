#include <stdio.h>
#include <stdlib.h>
#include <time.h>       // for the random number generator
#include "gpu_monkey.h"
#include <string.h>

#define MAX_INPUT_BUFF 4096// the max number of characters for input

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
    int wordc = 1;
	char* tmp;
	FILE * fp;
	
	if((fp = fopen("string.txt", "r")) == NULL)
	{
		printf("couldn't open file\n");
		return 0;
	}


    char genInput[MAX_INPUT_BUFF];
	char incpy[MAX_INPUT_BUFF];
	char c = 0;

	// Choose input from file or stdin 
	printf("Read from file or stdin? [f/s]\n:");
	while(c == 0)
	{
		c = getchar();
		if(c == 'f')
			fgets(genInput , MAX_INPUT_BUFF , fp);
		else if(c == 's')
		{
			while ((c = getchar()) != '\n' && c != EOF);
   			printf("Enter a string --> ");
			fgets(genInput , MAX_INPUT_BUFF , stdin);
		}
		else
			c = 0;
	}

	strcpy(incpy, genInput);
	
	//find number of words
	char* word = strtok(incpy, "\t\n ");

	while((word = strtok(NULL, "\t\n ")) != NULL)
		wordc++;
	
	printf("Word Count: %d\n", wordc);

	start = clock();

	generateMonkey(genInput, wordc);

    end = clock();  // time at end of program run
    cpu_time_used = ((double) (end - start))  / CLOCKS_PER_SEC;

    int cpu_int = (int)cpu_time_used;
    double cpu_dec = cpu_time_used - cpu_int;

    int minutes = cpu_time_used / 60;
    double seconds = (int)(cpu_time_used) % 60;
    seconds = seconds + cpu_dec;

    printf("Total Time: %d min, %.3f sec\n" , minutes, seconds);



    /*
    start = clock();        // time at start of program run
    monkey(input, inputSize);   // Calls Cesar to get to work

    end = clock();  // time at end of program run
    cpu_time_used = ((double) (end - start))  / CLOCKS_PER_SEC;

    int cpu_int = (int)cpu_time_used;
    double cpu_dec = cpu_time_used - cpu_int;

    int minutes = cpu_time_used / 60;
    double seconds = (int)(cpu_time_used) % 60;
    seconds = seconds + cpu_dec;

    printf("Total Time: %d min, %.3f sec\n" , minutes, seconds);

    */
    return 1;
}
