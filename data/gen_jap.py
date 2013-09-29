#!/usr/bin/env python
# -*- coding: utf-8 -*-

if __name__ == '__main__':
    with open("./names.txt") as f_names:
        with open("./dos.txt") as f_dos:
            l_names = f_names.readlines()
            l_dos = f_dos.readlines()
            for l_name1 in l_names:
                for l_name2 in l_names:
                    for l_do in l_dos:
                        print("%sと%s%s" % (l_name1[:-1], l_name2[:-1], l_do[:-1]))
