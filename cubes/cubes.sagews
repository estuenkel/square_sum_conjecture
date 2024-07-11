import math
from sage.graphs.generic_graph_pyx import find_hamiltonian
import ast

def cube_sum(a, b):
    s = a + b
    for i in range(math.floor(math.cbrt(s)), math.ceil(math.cbrt(s)) + 1):
        if i**3 == s:
            return True
    return False

def integers_list(beginning, cube):
    l = list(range(1, (cube - 1) / 2 + 1))

    for i in range(len(beginning) - 1):
        for j in range((1 - cube) / 2, (cube - 1) / 2 + 1):
            l.append(beginning[i] * cube + j)

    for i in range(len(beginning) - 1):
        l.remove(beginning[i])

    return l

def sequence_list(even, beginning, end, cube):
    l = []

    if even == True:
        for i in range((1 - cube) / 2, (cube - 1) / 2 + 1):
            l.append(['T' + str(i), beginning[-1] * cube - i * (-1)**len(beginning), end * cube - i])
    else:
        for i in range((1 - cube) / 2, (cube - 1) / 2 + 1):
            l.append(['T' + str(i), beginning[-1] * cube - i * (-1)**len(beginning), end * cube + i])
    return l

def path_dictionary_glue(even, beginning, end, cube):
    int_list = integers_list(beginning, cube)
    seq_list = sequence_list(even, beginning, end, cube)

    d = dict()

    for ele in int_list:
        l = []

        for integer in int_list:
            if cube_sum(ele, integer) == True and ele != integer:
                l.append(integer)

        for seq in seq_list:
            if cube_sum(ele, seq[1]) == True:
                l.append(seq[1])
            if cube_sum(ele, seq[2]) == True:
                l.append(seq[2])

        if ele == beginning[-1]:
            if len(beginning) == 1:
                l.append('start')
            else:
                l.append(beginning[-2])
                d[beginning[0]] = ['start', beginning[1]]
        elif ele == end:
            l.append('end')

        d[ele] = l

    for i in range(1, len(beginning) - 1):
        d[beginning[i]] = [beginning[i - 1], beginning[i + 1]]

    d['start'] = [beginning[0]]
    d['end'] = [end]

    for ele in seq_list:
        l1 = []
        l2 = []

        for integer in int_list:
            if cube_sum(ele[1], integer) == True:
                l1.append(integer)
            if cube_sum(ele[2], integer) == True:
                l2.append(integer)

        for seq in seq_list:
            if ele != seq:
                if cube_sum(ele[1], seq[1]) == True:
                    l1.append(seq[1])
                if cube_sum(ele[1], seq[2]) == True:
                    l1.append(seq[2])

                if cube_sum(ele[2], seq[1]) == True:
                    l2.append(seq[1])
                if cube_sum(ele[2], seq[2]) == True:
                    l2.append(seq[2])

        l1.append(ele[0])
        l2.append(ele[0])

        d[ele[1]] = l1
        d[ele[2]] = l2

        d[ele[0]] = [ele[1], ele[2]]

    return d

def detect_reverse(integer, beginning, cube):
    l = []
    for i in range((1 - cube) / 2, (cube - 1) / 2 + 1):
        l.append(beginning * cube + i)

    if integer in l:
        return False
    else:
        return True

def reformat_glue(path, beginning, cube):
    l = []
    for i in range(len(path)):
        if type(path[i]) == str:
            if detect_reverse(path[i - 1], beginning, cube) == True:
                l.append('R' + path[i])
            else:
                l.append(path[i])
        else:
            if i == 0:
                l.append(path[i])
            elif i == len(path) - 1:
                l.append(path[i])
            elif type(path[i - 1]) != str and type(path[i + 1]) != str:
                l.append(path[i])
    return l

def generate_glue(even, beginning, end, cube):
    d = path_dictionary_glue(even, beginning, end, cube)
    graph = Graph(d)
    while True:
        path = find_hamiltonian(graph, find_path = True)
        if path[0] != False:
            path = path[1][1:-1]
            if path[0] != beginning[0]:
                path.reverse()
            path_reformat = reformat_glue(path, beginning[-1], cube)
            return path_reformat

def path_dictionary_base_cases(n, beginning, end):
    d = dict()

    integers = list(range(1, n + 1))
    for i in range(len(beginning) - 1):
        integers.remove(beginning[i])

    for i in integers:
        l = []

        for j in integers:
            if cube_sum(i, j) == True and i != j:
                l.append(j)

        if i == beginning[-1]:
            if len(beginning) == 1:
                l.append('start')
            else:
                l.append(beginning[-2])
                d[beginning[0]] = ['start', beginning[1]]
        elif i == end:
            l.append('end')

        d[i] = l

    for i in range(1, len(beginning) - 1):
        d[beginning[i]] = [beginning[i - 1], beginning[i + 1]]

    d['start'] = [beginning[0]]
    d['end'] = [end]

    return d

def find_base_case(even, beginning, end):
    if even == True:
        i = 2
    else:
        i = 1
    while True:
        d = path_dictionary_base_cases(i, beginning, end)
        graph = Graph(d)

        for j in range(100):
            path = find_hamiltonian(graph, find_path = True)
            if path[0] != False:
                path = path[1][1:-1]
                if path[0] != beginning[0]:
                    path.reverse()
                return path
        i += 2

def create_text_file(file_name, even, beginning, end, cube):
    file = open(file_name, 'w')

    base_case = find_base_case(even, beginning, end)
    file.write('Base Case:\n' + str(base_case) + '\n\n')

    glue = generate_glue(even, beginning, end, cube)
    file.write(str(cube) + 'n+' + str((cube - 1) / 2) + ' glue:\n' + str(glue))

    file.close()

def shift_sequence(seq, c, cube, beginning_length):
    seq2 = []
    for i in range(len(seq)):
        seq2.append(seq[i] * cube + c * (-1)**i)
    return seq2[beginning_length - 1:]

def build_new_sequence(seq, glue, cube, beginning_length):
    new_seq = []

    for ele in glue:
        if type(ele) == int or type(ele) == sage.rings.integer.Integer:
            new_seq.append(ele)
        else:
            if 'R' in ele:
                c = int(ele[2:])
                shift = shift_sequence(seq, c, cube, beginning_length)
                shift.reverse()

            else:
                c = int(ele[1:])
                shift = shift_sequence(seq, c, cube, beginning_length)

            new_seq = new_seq + shift

    return new_seq

def generate_sequence(text_file, level):
    file = open(text_file, 'r')
    read_file = file.read().splitlines()

    seq = ast.literal_eval(read_file[1])
    glue = ast.literal_eval(read_file[4])

    s = ''
    i = 0
    while True:
        if read_file[3][i] != 'n':
            s += read_file[3][i]
            i += 1
        else:
            break
    cube = int(s)
    beginning_length = floor(len(glue) / cube)

    for i in range(level):
        seq = build_new_sequence(seq, glue, cube, beginning_length)
    return seq
    
#generate_glue: finds a viable glue to be used
    #inputs
        #even (boolean): whether or not the input sequence is of odd or even length
        #beginning (list): what the starting sequence will be
        #end (list): a two element list containing the ending integer if the sequence is of odd length followed by the ending integer if the sequence is of even length
        #cube (integer): what cube is to be used (input 8 for 2 cubed)
    #output
        #a viable glue with the given parameters as a list
    
#find_base_case: finds a viable base case to be used
    #inputs
        #even (boolean): whether or not the input sequence is of odd or even length
        #beginning (list): what the starting sequence will be
        #end (list): a two element list containing the ending integer if the sequence is of odd length followed by the ending integer if the sequence is of even length
    #output
        #a viable path with the given parameters as a list
    
#create_text_file: creates a text file with a corresponding base case and glue
    #inputs
        #file_name (string): what the name of the text file should be
        #even (boolean): whether or not the input sequence is of odd or even length
        #beginning (list): what the starting sequence will be
        #end (list): a two element list containing the ending integer if the sequence is of odd length followed by the ending integer if the sequence is of even length
        #cube (integer): what cube is to be used (input 8 for 2 cubed)
    #output
        #a text file in the current directory
    
#generate_sequence: reuses the base and glue to create infinitely many sequences
    #inputs
        #text_file (string): name of the text file created using the create_text_file function
        #level (integer): how many times to use base case and glue (the base case is treated as level 0)
    #output
        #a viable sequence for the given level as a list









