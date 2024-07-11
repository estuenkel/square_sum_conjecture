import math
from sage.graphs.generic_graph_pyx import find_hamiltonian

def square_sum(a, b):
    s = a + b
    if math.sqrt(s) % 1 == 0:
        return True
    else:
        return False

def general_path(n):
    if n == 1:
        return [1]

    d = dict()
    integers = list(range(1, n + 1))

    for i in integers:
        l = []
        for j in integers:
            if square_sum(i, j) == True and i != j:
                l.append(j)
        d[i] = l

    graph = Graph(d)

    for i in range(100):
        path = find_hamiltonian(graph, find_path = True)
        if path[0] != False:
            return path[1]
    return False

def prior_cases(stop):
    d = dict()
    for i in range(1, stop + 1):
        path = general_path(i)
        if path != False:
            d[i] = path
    return d

def path_dictionary(n, beginning, end):
    d = dict()

    if n % 2 == 0:
        ending = end[1]
    else:
        ending = end[0]

    integers = list(range(1, n + 1))
    for i in range(len(beginning) - 1):
        integers.remove(beginning[i])

    for i in integers:
        l = []

        for j in integers:
            if square_sum(i, j) == True and i != j:
                l.append(j)

        if i == beginning[-1]:
            if len(beginning) == 1:
                l.append('start')
            else:
                l.append(beginning[-2])
                d[beginning[0]] = ['start', beginning[1]]
        elif i == ending:
            l.append('end')

        d[i] = l

    for i in range(1, len(beginning) - 1):
        d[beginning[i]] = [beginning[i - 1], beginning[i + 1]]

    d['start'] = [beginning[0]]
    d['end'] = [ending]

    return d

def parity_dictionary(path):
    parity = False
    d = dict()

    for i in path:
            d[i] = parity
            parity = not parity

    if len(path) % 2 == 0:
        d[len(path) + 1] = False
    else:
        d[len(path) + 1] = True

    return d

def pair_dictionary(n, beginning, end, parity_dict):
    d = dict()

    if n % 2 == 0:
        ending = end[1]
    else:
        ending = end[0]

    integers = list(range(1, n + 1))
    for i in range(len(beginning) - 1):
        integers.remove(beginning[i])

    for i in integers:
        l = []
        for j in integers:
            if square_sum(i, j) == True and i != j and parity_dict[i] != parity_dict[j]:
                l.append(j)

        if i == beginning[-1]:
            if len(beginning) == 1:
                l.append('start')
            else:
                l.append(beginning[-2])
                d[beginning[0]] = ['start', beginning[1]]
        elif i == ending:
            l.append('end')

        d[i] = l

    for i in range(1, len(beginning) - 1):
        d[beginning[i]] = [beginning[i - 1], beginning[i + 1]]

    d['start'] = [beginning[0]]
    d['end'] = [ending]

    return d

def generate_pair(n, beginning, end):
    d = path_dictionary(n, beginning, end)
    graph = Graph(d)
    while True:
        path = find_hamiltonian(graph, find_path = True)
        if path[0] != False:
            path = path[1][1:-1]
            if path[0] != beginning[0]:
                path.reverse()
            parity_dict = parity_dictionary(path)

            d2 = pair_dictionary(n + 1, beginning, end, parity_dict)
            graph2 = Graph(d2)
            path2 = find_hamiltonian(graph2, find_path = True)
            if path2[0] != False:
                path2 = path2[1][1:-1]
                if path2[0] != beginning[0]:
                    path2.reverse()
                return [path, path2]

def create_base_cases_text_file(file_name, base_case_start, base_case_end, beginning, end):
    file = open(file_name, 'w')

    for i in range(base_case_start, base_case_end + 1):
        base_case_pair = generate_pair(i, beginning, end)
        txt = str(i) + '\n' + str(base_case_pair[0]) + '\n' + str(base_case_pair[1]) + '\n\n'
        file.write(txt)

    file.close()

def create_prior_cases_text_file(file_name, stop):
    file = open(file_name, 'w')

    prior_dict = prior_cases(stop)
    for i in prior_dict:
        txt = str(i) + '\n' + str(prior_dict[i]) + '\n\n'
        file.write(txt)

    file.close()

#generate_pair: returns a nice pair for the given value of n
    #inputs
        #n (integer): the length of the desired sequence
        #beginning (list): what the starting sequence will be
        #end (list): a two element list containing the ending integer if the sequence is of odd length followed by the ending integer if the sequence is of even length
    #output
        #a list containing a viable path of length n and a nice pair

#create_base_cases_text_file: creates a base cases text file that can read by the other provided files
    #inputs
        #file_name (string): what the name of the text file should be
        #base_case_start (integer): when the base cases begin
        #base_case_end (integer): when the base cases end
        #beginning (list): what the starting sequence will be
        #end (list): a two element list containing the ending integer if the sequence is of odd length followed by the ending integer if the sequence is of even length
    #output
        #a text file in the current directory

#create_prior_cases_text_file: finds general paths up until a specified stop point and puts them into a text file
    #inputs
        #file_name (string): what the name of the text file should be
        #stop (integer): the last path to look for
    #output
        #a text file in the current directory









