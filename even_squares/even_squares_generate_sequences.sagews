import ast

def file_reader(glue_file, base_cases_file):
    glue_file = open(glue_file, 'r')
    read_glue = glue_file.read().splitlines()

    odd_glue = [read_glue[1::8], read_glue[2::8]]
    even_glue = [read_glue[5::8], read_glue[6::8]]

    base_case_file = open(base_cases_file, 'r')
    read_base_cases = base_case_file.read().splitlines()

    base_cases = [read_base_cases[1::4], read_base_cases[2::4]]

    s = ''
    i = 0
    while True:
        if read_glue[0][i] != 'n':
            s += read_glue[0][i]
            i += 1
        else:
            break
    square = int(s)

    s = ''
    i += 1
    while True:
        if read_glue[0][i] != ' ':
            s += read_glue[0][i]
            i += 1
        else:
            break
    residue_start = int(s)

    beginning_length = floor(len(ast.literal_eval(odd_glue[0][0])) / square)
    base_case_start = int(read_base_cases[0])
    base_case_end = len(read_base_cases) / 4 + base_case_start

    return [odd_glue, even_glue, base_cases, square, residue_start, beginning_length, base_case_start, base_case_end]

def prior_cases_file_reader(prior_cases_file):
    prior_cases_file = open(prior_cases_file, 'r')
    read_prior_cases = prior_cases_file.read().splitlines()
    
    prior_case_number = read_prior_cases[0::3]
    prior_case_path = read_prior_cases[1::3]
    
    prior_cases = dict()
    for i in range(len(prior_case_number)):
        prior_cases[int(prior_case_number[i])] = ast.literal_eval(prior_case_path[int(i)])
    return [int(prior_case_number[-1]), prior_cases]

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
    
def combine_sequences(n, file_2k_1, file1_4k_2, file2_4k_2, file1_4k, file2_4k):
    number_2k_1 = ceil(n / 2)
    number_4k_2 = floor((n + 2) / 4)
    number_4k = floor(n / 4)

    sequence_2k_1 = generate_path(number_2k_1, file_2k_1)

    if number_4k_2 % 2 == 0:
        sequence_4k_2 = generate_path(number_4k_2, file2_4k_2)
    else:
        sequence_4k_2 = generate_path(number_4k_2, file1_4k_2)

    if number_4k % 2 == 0:
        sequence_4k = generate_path(number_4k, file2_4k)
    else:
        sequence_4k = generate_path(number_4k, file1_4k)

    if number_2k_1 % 2 == 0:
        sequence = sequence_4k + sequence_2k_1 + sequence_4k_2
    else:
        sequence = sequence_4k_2 + sequence_2k_1[1:] + sequence_4k + [1]

    return sequence

def load_text_files():
    file_2k_1 = file_reader('2k+1_glue.txt', '2k+1_base_cases.txt')
    file1_4k_2 = file_reader('4k+2_6_endpoint_odd_glue.txt', '4k+2_6_endpoint_odd_base_cases.txt')
    file2_4k_2 = file_reader('4k+2_6_endpoint_even_glue.txt', '4k+2_6_endpoint_even_base_cases.txt')
    file1_4k = file_reader('4k_8_endpoint_odd_glue.txt', '4k_8_endpoint_odd_base_cases.txt')
    file2_4k = file_reader('4k_8_endpoint_even_glue.txt', '4k_8_endpoint_even_base_cases.txt')
    prior_cases_file = prior_cases_file_reader('even_squares_prior_cases.txt')

    return [file_2k_1, file1_4k_2, file2_4k_2, file1_4k, file2_4k, prior_cases_file]

def generate_sequence(n):
    files = load_text_files()
    
    if n <= files[5][0]:
        if n in files[5][1]:
            return files[5][1][n]
        else:
            return 'There is no path'
    else:
        return combine_sequences(n, files[0], files[1], files[2], files[3], files[4])

#file_reader: takes some of the text files that were created and translates them into an easily readable format for the other functions
    #inputs
        #glue_file (string): name of the glue text file
        #base_cases_file (string): name of the base cases text file
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

#combine_sequences: takes several files that have been read and combines them into one sequence that only uses one odd square
    #inputs
        #n (intger): the length of the desired sequence
        #file_2k_1 (list): read file of integers of the form 2k+1
        #file1_4k_2 (list): read file of integers of the form 4k+2 where 6 is in an odd position
        #file2_4k_2 (list): read file of integers of the form 4k+2 where 6 is in an even position
        #file1_4k (list): read file of integers of the form 4k where 8 is in an odd position
        #file2_4k (list): read file of integers of the form 4k where 8 is in an even position
    #outputs
        #a valid sequence that only uses one odd pair
        
#generate_sequence: loads the provided text files to generate a sequence for any given n using only 9 as the only odd square
    #inputs
        #n (integer): the length of the desired sequence
    #outputs
        #a sequence that uses 9 as the only odd square if it exists









