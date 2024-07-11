import ast

def file_reader(glue_file, base_cases_file, prior_cases_file):
    glue_file = open(glue_file, 'r')
    read_glue = glue_file.read().splitlines()

    odd_glue = [read_glue[1::8], read_glue[2::8]]
    even_glue = [read_glue[5::8], read_glue[6::8]]

    base_cases_file = open(base_cases_file, 'r')
    read_base_cases = base_cases_file.read().splitlines()

    base_cases = [read_base_cases[1::4], read_base_cases[2::4]]

    prior_cases_file = open(prior_cases_file, 'r')
    read_prior_cases = prior_cases_file.read().splitlines()

    prior_case_number = read_prior_cases[0::3]
    prior_case_path = read_prior_cases[1::3]

    prior_cases = dict()
    for i in range(len(prior_case_number)):
        prior_cases[int(prior_case_number[i])] = ast.literal_eval(prior_case_path[int(i)])

    s = ''
    i = 0
    while True:
        if read_glue[0][i] != 'n':
            s += read_glue[0][i]
            i += 1
        else:
            break
    square = int(s)
    residue_start = (square - 1) / 2

    beginning_length = floor(len(ast.literal_eval(odd_glue[0][0])) / square)
    base_case_start = int(read_base_cases[0])
    base_case_end = len(read_base_cases) / 4 + base_case_start

    return [odd_glue, even_glue, base_cases, square, residue_start, beginning_length, base_case_start, base_case_end, prior_cases]

def shift_sequence(seq, c, square, beginning_length):
    seq2 = []
    for i in range(len(seq)):
        seq2.append(seq[i] * square + c * (-1)**i)
    return seq2[beginning_length - 1:]

def build_new_sequence(seq1, seq2, glue, square, beginning_length):
    new_seq = []
    for ele in glue:
        if type(ele) == int or type(ele) == sage.rings.integer.Integer:
            new_seq.append(ele)
        else:
            if 'R' in ele:
                c = int(ele[2:])
                if ele[1] == 'T':
                    shift = shift_sequence(seq1, c, square, beginning_length)
                    shift.reverse()
                else:
                    shift = shift_sequence(seq2, c, square, beginning_length)
                    shift.reverse()
            else:
                c = int(ele[1:])
                if ele[0] == 'T':
                    shift = shift_sequence(seq1, c, square, beginning_length)
                else:
                    shift = shift_sequence(seq2, c, square, beginning_length)
            new_seq = new_seq + shift

    return new_seq

def previous_case(n, square, residue_start):
    a = floor(n / square)
    b = n % square
    if b < residue_start:
        return [a-1, b + square]
    else:
        return [a, b]

def generate_path_pair(n, read_file):
    odd_glue = read_file[0]
    even_glue = read_file[1]
    base_cases = read_file[2]
    square = read_file[3]
    residue_start = read_file[4]
    beginning_length = read_file[5]
    base_case_start = read_file[6]
    base_case_end = read_file[7]

    if n < base_case_end:
        return [ast.literal_eval(base_cases[0][n - base_case_start]), ast.literal_eval(base_cases[1][n - base_case_start])]

    else:
        small_n = previous_case(n, square, residue_start)
        small_seq = generate_path_pair(small_n[0], read_file)

        even = len(small_seq[0]) % 2 == 0
        if even == True:

            glue1 = ast.literal_eval(even_glue[0][small_n[1] - residue_start])
            glue2 = ast.literal_eval(even_glue[1][small_n[1] - residue_start])

        else:

            glue1 = ast.literal_eval(odd_glue[0][small_n[1] - residue_start])
            glue2 = ast.literal_eval(odd_glue[1][small_n[1] - residue_start])


        pair1 = build_new_sequence(small_seq[0], small_seq[1], glue1, square, beginning_length)
        pair2 = build_new_sequence(small_seq[0], small_seq[1], glue2, square, beginning_length)

        return [pair1, pair2]

def generate_path(n, read_file):
    odd_glue = read_file[0]
    even_glue = read_file[1]
    base_cases = read_file[2]
    square = read_file[3]
    residue_start = read_file[4]
    beginning_length = read_file[5]
    base_case_start = read_file[6]
    base_case_end = read_file[7]
    prior_cases = read_file[8]

    if n < base_case_start:
        if n in prior_cases:
            return prior_cases[n]
        else:
            return 'There is no path'

    if n < base_case_end:
        return ast.literal_eval(base_cases[0][n - base_case_start])

    else:
        small_n = previous_case(n, square, residue_start)
        small_seq = generate_path_pair(small_n[0], read_file)

        even = len(small_seq[0]) % 2 == 0
        if even == True:
            glue = ast.literal_eval(even_glue[0][small_n[1] - residue_start])

        else:
            glue = ast.literal_eval(odd_glue[0][small_n[1] - residue_start])

        sequence = build_new_sequence(small_seq[0], small_seq[1], glue, square, beginning_length)

        return sequence

def read_files_and_generate_path(n, glue_file, base_cases_file, prior_cases_file):
    read_file = file_reader(glue_file, base_cases_file, prior_cases_file)
    path = generate_path(n, read_file)
    return path

#file_reader: takes the text files that were created and translates them into an easily readable format for the other functions
    #inputs
        #glue_file (string): name of the glue text file
        #base_cases_file (string): name of the base cases text file
        #prior_cases_file (string): name of the prior cases text file
    #output
        #a list of information contained within the three text files

#generate_path_pair: finds a nice pair for any large enough n
    #inputs
        #n (integer): the length of the desired sequence
        #read_file (list): the list created from the file_reader function
    #output
        #a list containing two sequences that form a nice pair

#generate_path: gives a viable path for the given n value if it exists
    #inputs
        #n (integer): the length of the desired sequence
        #read_file (list): the list created from the file_reader function
    #output
        #a sequence for the given n stored as a list

#read_files_and_generate_path: combines the file reader and generate_path functions into one
    #inputs
        #n (integer): the length of the desired sequence
        #glue_file (string): name of the glue text file
        #base_cases_file (string): name of the base cases text file
        #prior_cases_file (string): name of the prior cases text file
    #output
        #a sequence for the given n stored as a list









