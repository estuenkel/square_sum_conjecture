import math
from sage.graphs.generic_graph_pyx import find_hamiltonian

def valid_sum(a, b, multiples):
    s = a + b

    for i in multiples:
        n = s / i
        for j in range(math.floor(math.log(n, 3)), math.ceil(math.log(n, 3)) + 1):
            if 3**j == n:
                return True
    return False

def integers_list(beginning, power_of_3):
    l = list(range(1, (power_of_3 - 1) / 2 + 1))

    for i in range(len(beginning) - 1):
        for j in range((1 - power_of_3) / 2, (power_of_3 - 1) / 2 + 1):
            l.append(beginning[i] * power_of_3 + j)

    for i in range(len(beginning) - 1):
        l.remove(beginning[i])

    return l

def sequence_list(even, residue, beginning, end, power_of_3):
    l = []
    long = residue - (power_of_3 - 1) / 2

    if even == True:
        for i in range((1 - power_of_3) / 2, (power_of_3 - 1) / 2 + 1):
            if long != 0:
                l.append(['L' + str(i), beginning[-1] * power_of_3 - i * (-1)**len(beginning), end[0] * power_of_3 + i])
                long += -1
            else:
                l.append(['T' + str(i), beginning[-1] * power_of_3 - i * (-1)**len(beginning), end[1] * power_of_3 - i])
    else:
        for i in range((power_of_3 - 1) / 2, (1 - power_of_3) / 2 - 1, -1):
            if long != 0:
                l.append(['L' + str(i), beginning[-1] * power_of_3 - i * (-1)**len(beginning), end[1] * power_of_3 - i])
                long += -1
            else:
                l.append(['T' + str(i), beginning[-1] * power_of_3 - i * (-1)**len(beginning), end[0] * power_of_3 + i])

    return l

def path_dictionary(even, residue, beginning, end, power_of_3, multiples):
    int_list = integers_list(beginning, power_of_3)
    seq_list = sequence_list(even, residue, beginning, end, power_of_3)

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
            if valid_sum(ele, integer, multiples) == True and ele != integer:
                l.append(integer)

        for seq in seq_list:
            if valid_sum(ele, seq[1], multiples) == True:
                l.append(seq[1])
            if valid_sum(ele, seq[2], multiples) == True:
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
            if valid_sum(ele[1], integer, multiples) == True:
                l1.append(integer)
            if valid_sum(ele[2], integer, multiples) == True:
                l2.append(integer)

        for seq in seq_list:
            if ele != seq:
                if valid_sum(ele[1], seq[1], multiples) == True:
                    l1.append(seq[1])
                if valid_sum(ele[1], seq[2], multiples) == True:
                    l1.append(seq[2])

                if valid_sum(ele[2], seq[1], multiples) == True:
                    l2.append(seq[1])
                if valid_sum(ele[2], seq[2], multiples) == True:
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

def parity_dictionary(path, even, residue, beginning, end, power_of_3):
    parity = False
    d = dict()
    for ele in path:
        if type(ele) == int or type(ele) == sage.rings.integer.Integer:
            d[ele] = parity
            parity = not parity
        else:
            parity = new_parity(even, ele, parity, beginning)

    old_seq = sequence_list(even, residue, beginning, end, power_of_3)
    new_seq = sequence_list(even, residue + 1, beginning, end, power_of_3)

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

def pair_dictionary(even, residue, beginning, end, parity_dict, power_of_3, multiples):
    int_list = integers_list(beginning, power_of_3)
    seq_list = sequence_list(even, residue, beginning, end, power_of_3)

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
            if valid_sum(ele, integer, multiples) == True and ele != integer and parity_dict[ele] != parity_dict[integer]:
                l.append(integer)

        for seq in seq_list:
            if valid_sum(ele, seq[1], multiples) == True and parity_dict[ele] != parity_dict[seq[1]]:
                l.append(seq[1])
            if valid_sum(ele, seq[2], multiples) == True and parity_dict[ele] != parity_dict[seq[2]]:
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
            if valid_sum(ele[1], integer, multiples) == True and parity_dict[ele[1]] != parity_dict[integer]:
                l1.append(integer)
            if valid_sum(ele[2], integer, multiples) == True and parity_dict[ele[2]] != parity_dict[integer]:
                l2.append(integer)

        for seq in seq_list:
            if ele != seq:
                if valid_sum(ele[1], seq[1], multiples) == True and parity_dict[ele[1]] != parity_dict[seq[1]]:
                    l1.append(seq[1])
                if valid_sum(ele[1], seq[2], multiples) == True and parity_dict[ele[1]] != parity_dict[seq[2]]:
                    l1.append(seq[2])

                if valid_sum(ele[2], seq[1], multiples) == True and parity_dict[ele[1]] != parity_dict[seq[1]]:
                    l2.append(seq[1])
                if valid_sum(ele[2], seq[2], multiples) == True and parity_dict[ele[1]] != parity_dict[seq[2]]:
                    l2.append(seq[2])

        l1.append(ele[0])
        l2.append(ele[0])

        d[ele[1]] = l1
        d[ele[2]] = l2

        d[ele[0]] = [ele[1], ele[2]]

    return d

def detect_reverse(integer, beginning, power_of_3):
    l = []
    for i in range((1 - power_of_3) / 2, (power_of_3 - 1) / 2 + 1):
        l.append(beginning * power_of_3 + i)

    if integer in l:
        return False
    else:
        return True

def reformat_glue(path, beginning, power_of_3):
    l = []
    for i in range(len(path)):
        if type(path[i]) == str:
            if detect_reverse(path[i - 1], beginning, power_of_3) == True:
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

def generate_pair(even, residue, beginning, end, power_of_3, multiples):
    d = path_dictionary(even, residue, beginning, end, power_of_3, multiples)
    graph = Graph(d)
    while True:
        path = find_hamiltonian(graph, find_path = True)
        if path[0] != False:
            path = path[1][1:-1]
            if path[0] != beginning[0]:
                path.reverse()
            parity_dict = parity_dictionary(path, even, residue, beginning, end, power_of_3)

            d2 = pair_dictionary(even, residue + 1, beginning, end, parity_dict, power_of_3, multiples)
            graph2 = Graph(d2)
            path2 = find_hamiltonian(graph2, find_path = True)
            if path2[0] != False:
                path2 = path2[1][1:-1]
                if path2[0] != beginning[0]:
                    path2.reverse()

                path_reformat = reformat_glue(path, beginning[-1], power_of_3)
                path2_reformat = reformat_glue(path2, beginning[-1], power_of_3)
                return [path_reformat, path2_reformat]

def create_text_file(file_name, beginning, end, power_of_3, multiples):
    file = open(file_name, 'w')

    for i in range((power_of_3 - 1) / 2, (power_of_3 - 1) / 2 + power_of_3):

        glue_pair = generate_pair(False, i, beginning, end, power_of_3, multiples)
        txt = str(power_of_3) + 'n+' + str(i) + ' for odd n:\n' + str(glue_pair[0]) + '\n' + str(glue_pair[1]) + '\n\n'
        file.write(txt)

        glue_pair = generate_pair(True, i, beginning, end, power_of_3, multiples)
        txt = str(power_of_3) + 'n+' + str(i) + ' for even n:\n' + str(glue_pair[0]) + '\n' + str(glue_pair[1]) + '\n\n'
        file.write(txt)

    file.close()

#generate_pair: finds a pair of glue with the given parameters if it exists
    #inputs
        #even (boolean): whether or not the input sequence is of odd or even length
        #resiude (integer): which integer will be used in the residue system
        #beginning (list): what the starting sequence will be
        #end (list): a two element list containing the ending integer if the sequence is of odd length followed by the ending integer if the sequence is of even length
        #power_of_3 (integer): what power of 3 is to be used (if you want to use 3 to the third power, input 27)
        #multiples (list): which multiples of a power of 3 are allowed
    #outputs
        #list containing the glue for the given residue and glue for a nice pair for that residue

#create_text_file: creates a glue text file that can read by the other provided files
    #inputs
        #file_name (string): what the name of the text file should be
        #beginning (list): what the starting sequence will be
        #end (list): a two element list containing the ending integer if the sequence is of odd length followed by the ending integer if the sequence is of even length
        #power_of_3 (integer): what power of 3 is to be used (if you want to use 3 to the third power, input 27)
        #multiples (list): which multiples of a power of 3 are allowed
    #outputs
        #a text file in the current directory









