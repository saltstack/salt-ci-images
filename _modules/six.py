# -*- coding: utf-8 -*-
import sys


def __virtual__():
    return True


def delete(name):
    '''
    delete named module from sys.modules
    '''
    del sys.modules[name]
