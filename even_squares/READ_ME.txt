This folder contains all of the files necessary for proving that 9 is the only odd square needed to prove the square sum conjecture.

"even_squares_glue.sagews" is dedicated to finding glue and then creating a text file that can be read later.
"even_squares_base_cases.sagews" is dedicated to finding base cases for whatever glue is found and creating a text file that can be read later.
"even_squares_generate_sequences.sagews" is dedicated to creating sequences of any length using the text files created for glue and base cases.

The provided text files are sufficient to prove that it is always possible to find a Hamiltonian path on the integers from 1 to n where there is an edge between them if they sum to an even square or 9. They are also sufficient to prove that there is always a path using only integers of the form 4k, using only integers of the form 4k+2, and using only odd integers.