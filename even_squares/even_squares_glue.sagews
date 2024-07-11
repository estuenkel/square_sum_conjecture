import math
from sage.graphs.generic_graph_pyx import find_hamiltonian

def square_sum(a, b):
    s = a + b
    if math.sqrt(s) % 1 == 0:
        return True
    else:
        return False

def integers_list(beginning, square, gap, start):
    l = []
    for i in range(start, start * square + gap / 2 * (1 - square), gap):
        l.append(i)

    for i in range(len(beginning) - 1):
        for j in range(gap / 2 * (1 - square), gap / 2 * (square - 1) + 1, gap):
            l.append(beginning[i] * square + j)

    for i in range(len(beginning) - 1):
        l.remove(beginning[i])

    return l

def sequence_list(even, residue, beginning, end, square, gap, start):
    l = []
    long = residue - len(list(range(start, start * square + gap / 2 * (1 - square), gap)))

    if even == True:
        for i in range(gap / 2 * (1 - square), gap / 2 * (square - 1) + 1, gap):
            if long != 0:
                l.append(['L' + str(i), beginning[-1] * square - i * (-1)**len(beginning), end[0] * square + i])
                long += -1
            else:
                l.append(['T' + str(i), beginning[-1] * square - i * (-1)**len(beginning), end[1] * square - i])
    else:
        for i in range(gap / 2 * (square - 1), gap / 2 * (1 - square) - 1, -gap):
            if long != 0:
                l.append(['L' + str(i), beginning[-1] * square - i * (-1)**len(beginning), end[1] * square - i])
                long += -1
            else:
                l.append(['T' + str(i), beginning[-1] * square - i * (-1)**len(beginning), end[0] * square + i])

    return l

def path_dictionary(even, residue, beginning, end, square, gap, start):
    int_list = integers_list(beginning, square, gap, start)
    seq_list = sequence_list(even, residue, beginning, end, square, gap, start)

    d = dict()

    even_residue = residue % 2 == 0
    if even == True and even_residue == True:
        ending = end[1]
    elif even == False and even_residue == False:
        ending = end[1]
    else:
        ending = end[0]

    for ele in int_list:
        l = []

        for integer in int_list:
            if square_sum(ele, integer) == True and ele != integer:
                l.append(integer)

        for seq in seq_list:
            if square_sum(ele, seq[1]) == True:
                l.append(seq[1])
            if square_sum(ele, seq[2]) == True:
                l.append(seq[2])

        if ele == beginning[-1]:
            if len(beginning) == 1:
                l.append('start')
            else:
                l.append(beginning[-2])
                d[beginning[0]] = ['start', beginning[1]]
        elif ele == ending:
            l.append('end')

        d[ele] = l

    for i in range(1, len(beginning) - 1):
        d[beginning[i]] = [beginning[i - 1], beginning[i + 1]]

    d['start'] = [beginning[0]]
    d['end'] = [ending]

    for ele in seq_list:
        l1 = []
        l2 = []

        for integer in int_list:
            if square_sum(ele[1], integer) == True:
                l1.append(integer)
            if square_sum(ele[2], integer) == True:
                l2.append(integer)

        for seq in seq_list:
            if ele != seq:
                if square_sum(ele[1], seq[1]) == True:
                    l1.append(seq[1])
                if square_sum(ele[1], seq[2]) == True:
                    l1.append(seq[2])

                if square_sum(ele[2], seq[1]) == True:
                    l2.append(seq[1])
                if square_sum(ele[2], seq[2]) == True:
                    l2.append(seq[2])

        l1.append(ele[0])
        l2.append(ele[0])

        d[ele[1]] = l1
        d[ele[2]] = l2

        d[ele[0]] = [ele[1], ele[2]]

    return d

def new_parity(even, ele, parity, beginning):
    beginning_parity = len(beginning) % 2 == 0

    if even == True and beginning_parity == True:
        if 'T' in ele:
            return not parity
        else:
            return parity
    elif even == False and beginning_parity == False:
        if 'T' in ele:
            return not parity
        else:
            return parity
    else:
        if 'T' in ele:
            return parity
        else:
            return not parity

def parity_dictionary(path, even, residue, beginning, end, square, gap, start):
    parity = False
    d = dict()
    for ele in path:
        if type(ele) == int or type(ele) == sage.rings.integer.Integer:
            d[ele] = parity
            parity = not parity
        else:
            parity = new_parity(even, ele, parity, beginning)

    old_seq = sequence_list(even, residue, beginning, end, square, gap, start)
    new_seq = sequence_list(even, residue + 1, beginning, end, square, gap, start)

    for i in range(len(old_seq)):
        if old_seq[i] != new_seq[i]:
            old_int = new_seq[i][1]
            new_int = new_seq[i][2]

    parity = d[old_int]
    beginning_parity = len(beginning) % 2 == 0

    if even == True and beginning_parity == True:
        d[new_int] = not parity
    elif even == False and beginning_parity == False:
        d[new_int] = not parity
    else:
        d[new_int] = parity

    return d

def pair_dictionary(even, residue, beginning, end, parity_dict, square, gap, start):
    int_list = integers_list(beginning, square, gap, start)
    seq_list = sequence_list(even, residue, beginning, end, square, gap, start)

    d = dict()

    even_residue = residue % 2 == 0
    if even == True and even_residue == True:
        ending = end[1]
    elif even == False and even_residue == False:
        ending = end[1]
    else:
        ending = end[0]

    for ele in int_list:
        l = []

        for integer in int_list:
            if square_sum(ele, integer) == True and ele != integer and parity_dict[ele] != parity_dict[integer]:
                l.append(integer)

        for seq in seq_list:
            if square_sum(ele, seq[1]) == True and parity_dict[ele] != parity_dict[seq[1]]:
                l.append(seq[1])
            if square_sum(ele, seq[2]) == True and parity_dict[ele] != parity_dict[seq[2]]:
                l.append(seq[2])

        if ele == beginning[-1]:
            if len(beginning) == 1:
                l.append('start')
            else:
                l.append(beginning[-2])
                d[beginning[0]] = ['start', beginning[1]]
        elif ele == ending:
            l.append('end')

        d[ele] = l

    for i in range(1, len(beginning) - 1):
        d[beginning[i]] = [beginning[i - 1], beginning[i + 1]]

    d['start'] = [beginning[0]]
    d['end'] = [ending]

    for ele in seq_list:
        l1 = []
        l2 = []

        for integer in int_list:
            if square_sum(ele[1], integer) == True and parity_dict[ele[1]] != parity_dict[integer]:
                l1.append(integer)
            if square_sum(ele[2], integer) == True and parity_dict[ele[2]] != parity_dict[integer]:
                l2.append(integer)

        for seq in seq_list:
            if ele != seq:
                if square_sum(ele[1], seq[1]) == True and parity_dict[ele[1]] != parity_dict[seq[1]]:
                    l1.append(seq[1])
                if square_sum(ele[1], seq[2]) == True and parity_dict[ele[1]] != parity_dict[seq[2]]:
                    l1.append(seq[2])

                if square_sum(ele[2], seq[1]) == True and parity_dict[ele[1]] != parity_dict[seq[1]]:
                    l2.append(seq[1])
                if square_sum(ele[2], seq[2]) == True and parity_dict[ele[1]] != parity_dict[seq[2]]:
                    l2.append(seq[2])

        l1.append(ele[0])
        l2.append(ele[0])

        d[ele[1]] = l1
        d[ele[2]] = l2

        d[ele[0]] = [ele[1], ele[2]]

    return d

def detect_reverse(integer, beginning, square, gap):
    l = []
    for i in range(gap / 2 * (1 - square), gap / 2 * (square - 1) + 1):
        l.append(beginning * square + i)

    if integer in l:
        return False
    else:
        return True

def reformat_glue(path, beginning, square, gap):
    l = []
    for i in range(len(path)):
        if type(path[i]) == str:
            if detect_reverse(path[i - 1], beginning, square, gap) == True:
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

def generate_pair(even, residue, beginning, end, square, gap, start):
    d = path_dictionary(even, residue, beginning, end, square, gap, start)
    graph = Graph(d)
    while True:
        path = find_hamiltonian(graph, find_path = True)
        if path[0] != False:
            path = path[1][1:-1]
            if path[0] != beginning[0]:
                path.reverse()
            parity_dict = parity_dictionary(path, even, residue, beginning, end, square, gap, start)

            d2 = pair_dictionary(even, residue + 1, beginning, end, parity_dict, square, gap, start)
            graph2 = Graph(d2)
            path2 = find_hamiltonian(graph2, find_path = True)
            if path2[0] != False:
                path2 = path2[1][1:-1]
                if path2[0] != beginning[0]:
                    path2.reverse()

                path_reformat = reformat_glue(path, beginning[-1], square, gap)
                path2_reformat = reformat_glue(path2, beginning[-1], square, gap)
                return [path_reformat, path2_reformat]

def create_text_file(file_name, residue_start, beginning, end, square, gap, start):
    file = open(file_name, 'w')

    for i in range(residue_start, residue_start + square):

        glue_pair = generate_pair(False, i, beginning, end, square, gap, start)
        txt = str(square) + 'n+' + str(i) + ' for an odd number of integers of the form ' + str(gap) + 'k+' + str(start) + ':\n'
        txt = txt + str(glue_pair[0]) + '\n' + str(glue_pair[1]) + '\n\n'
        file.write(txt)

        glue_pair = generate_pair(True, i, beginning, end, square, gap, start)
        txt = str(square) + 'n+' + str(i) + ' for an even number of integers of the form ' + str(gap) + 'k+' + str(start) + ':\n'
        txt = txt + str(glue_pair[0]) + '\n' + str(glue_pair[1]) + '\n\n'
        file.write(txt)

    file.close()

#generate_pair: finds a pair of glue with the given parameters if it exists
    #inputs
        #even (boolean): whether or not the input sequence is of odd or even length
        #resiude (integer): which integer will be used in the residue system
        #beginning (list): what the starting sequence will be
        #end (list): a two element list containing the ending integer if the sequence is of odd length followed by the ending integer if the sequence is of even length
        #square (integer): what square is to be used (input 9 to use 3 squared)
        #gap (integer): the gap from one integer to the next one
        #start (integer): the lowest integer in the set
    #outputs
        #a list containing the glue for the given residue and glue for a nice pair with the correct gap and start

#create_text_file: creates a glue text file that can read by the other provided files
    #inputs
        #file_name (string): what the name of the text file should be
        #beginning (list): what the starting sequence will be
        #end (list): a two element list containing the ending integer if the sequence is of odd length followed by the ending integer if the sequence is of even length
        #square (integer): what square is to be used (input 9 to use 3 squared)
        #gap (integer): the gap from one integer to the next one
        #start (integer): the lowest integer in the set
    #outputs
        #a text file in the current directory









