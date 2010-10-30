#!python -u
# -*- coding: utf-8 -*-
# Copyright © 2007 by Runar Tenfjord, Tenko.
import re

def isTEX(s):
    """Check if string is a TEX string"""
    if re.match(r'.*\$.+\$.*', s, re.MULTILINE | re.DOTALL):
        return True
        
    return False