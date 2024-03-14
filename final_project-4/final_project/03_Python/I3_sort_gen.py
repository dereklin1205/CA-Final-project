# import numpy as np

def sort(v, n):
    for i in range(n):
        for j in range(i-1,-1,-1):
            if v[j] > v[j+1]:
                v[j], v[j+1] = v[j+1], v[j]
    return v



if __name__ == '__main__':
    # Modify your test pattern here
    n = 30
    # v = [-1,-2,-3,5,7,8,-10,-5,10,11,12,50,-32,-14,-25]
    v = [-1,-2,-3,-5,20,19,18,17,16,15,-7,-10,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,0,-100,0]
    # print(v)

    with open('../00_TB/Pattern/I3/mem_D.dat', 'w') as f_data:
        f_data.write(f"{n:08x}\n")
        for ele in v:
            f_data.write(f"{ele:08x}\n")


    with open('../00_TB/Pattern/I3/golden.dat', 'w') as f_ans:
        f_ans.write('{:0>8x}\n'.format(n))
        for item in sort(v, n):
            f_ans.write('{:0>8x}\n'.format(item))