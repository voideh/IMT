# IMT
Relatively small CUDA implementation of a slightly altered version of the Infinite Monkey Theorem. 
Using heuristics of letter occurrences in English text to give some letters a higher probability of being selected.  

  - cpu_main is the non-Cuda implementation of the program to compare run-time
  - Cuda verion is 3 files: main.cpp, gpu_monkey.cu and gpu_monkey.h


  Changes To Be Made
-------------------------------------------------
  - The key generation needs to change
  - Cascading ifs need to go away...
  - Some sort of reduction should be implemented 
      the for key summation 
  
