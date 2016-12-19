with open('in.txt', 'w') as f:
    for i in range(10000000):
        f.write('{:07}\n'.format(i));
