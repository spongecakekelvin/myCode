# -*- coding: utf-8 -*-
import sys
import os
import os.path
import re
from xml.etree import ElementTree

plist_filename = "planegame.plist"
png_filename = "planegame.png"

def tree_to_dict(tree):  
    d = {}  
    for index, item in enumerate(tree):  
        if item.tag == 'key':  
            if tree[index+1].tag == 'string':  
                d[item.text] = tree[index + 1].text  
            elif tree[index + 1].tag == 'true':  
                d[item.text] = True  
            elif tree[index + 1].tag == 'false':  
                d[item.text] = False  
            elif tree[index+1].tag == 'dict':  
                d[item.text] = tree_to_dict(tree[index+1])  
    print d
    return d

def parse_plist():
    root = ElementTree.fromstring(open(plist_filename, 'r').read()) 
    plist_dict = tree_to_dict(root[0])
    # print root
    # print plist_dict

def divide_png(list):
    pass

def main():
    infolist = parse_plist();
    divide_png(infolist);
    
if __name__ == '__main__':
    main()