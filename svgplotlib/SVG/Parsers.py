#!/usr/bin/python
# -*- coding: utf-8 -*-
import re

class SVGParseError(Exception):
    pass
    
EOF = object()

class Lexer:
    """
    This style of implementation was inspired by this article:

        http://www.gooli.org/blog/a-simple-lexer-in-python/
    """
    Float = r'[-\+]?(?:(?:\d*\.\d+)|(?:\d+\.)|(?:\d+))(?:[Ee][-\+]?\d+)?'
    Int = r'[-\+]?\d+'
    
    lexicon = None
    ignore = None
    callbacks = None
    
    def __init__(self):
        lexicon = self.lexicon
        
        # create internal names for group matches
        groupnames = dict(('lexer_%d' % idx, item[0]) for idx,item in enumerate(lexicon))
        self.groupnames = groupnames
        
        # assemble regex parts to one regex
        igroupnames = dict((value,name) for name,value in groupnames.iteritems())
        
        regex_parts = ('(?P<%s>%s)' % (igroupnames[cls], regs) for cls,regs in lexicon)
        
        self.regex_string = '|'.join(regex_parts)
        self.regex = re.compile(self.regex_string)
    
    def lex(self, text):
        """
        Yield (token_type, data) tokens.
        The last token will be (EOF, None) where EOF
        """
        regex = self.regex
        groupnames = self.groupnames
        
        ignore = self.ignore or set()
        callbacks = self.callbacks or dict()
        
        position = 0
        size = len(text)
        
        while position < size: 
            match = regex.match(text, position)
            if match is None:
                raise SVGParseError('Unknown token at position %d' %  position)
            
            position = match.end()
            cls = groupnames[match.lastgroup]
            value = match.group(match.lastgroup)
            
            if cls in ignore:
                continue
                
            if cls in callbacks:
                value = callbacks[cls](self, value)
            
            yield (cls, value)
                
        yield (EOF, None)
        
# Parse SVG angle units
angle_pattern = \
r"""
    ^                           # match start of line                   
    \s*                         # ignore whitespace
    (?P<value>[-\+]?\d*\.?\d*([eE][-\+]?\d+)?)  # match float or int value
    (?P<unit>.+)?               # match any chars
    \s*                         # ignore whitespace
    $                           # match end of line
"""

angle_match = re.compile(angle_pattern, re.X).match

def parseAngle(angle):
    """
    Convert angle to degrees
    """
    SCALE = {
        "deg": 1, "grad": 1.11, "rad":57.30
    }
    
    match = length_match(angle)
    if match is None:
        raise SVGParseError("Not a valid angle unit: '%s'" % angle)
    
    value = match.group('value')
    if not value:
        raise SVGParseError("Not a valid angle unit: '%s'" % angle)
    
    value = float(value)
    
    unit = match.group('unit') or ''
    
    if not unit:
        return value
    elif unit in SCALE:
        return value * SCALE[unit]
    else:
        raise SVGParseError("Unknown unit '%s'" % unit)

# Parse SVG length units
length_pattern = \
r"""
    ^                           # match start of line                   
    \s*                         # ignore whitespace
    (?P<value>[-\+]?\d*\.?\d*([eE][-\+]?\d+)?)  # match float or int value
    (?P<unit>.+)?               # match any chars
    \s*                         # ignore whitespace
    $                           # match end of line
"""

length_match = re.compile(length_pattern, re.X).match

def parseLength(length):
    """
    Convert length to pixels.
    """
    SCALE = {
        "px": 1., "pt": 1.25, "pc": 15., 
        "mm": 3.543307, "cm": 35.43307,
        "in": 90., "i": 90.
    }
    match = length_match(str(length))
    if match is None:
        raise SVGParseError("Not a valid length unit: '%s'" % length)
    
    value = match.group('value')
    if not value:
        raise SVGParseError("Not a valid length unit: '%s'" % length)
    
    if value[0] == 'e' or value[0] == 'E':
        value = float('1' + value)
    else:
        value = float(value)
        
    unit = match.group('unit') or ''
    
    if not unit or unit in ('em', 'ex', '%'):
        # ignoring relative units
        return value
    elif unit in SCALE:
        return value * SCALE[unit]
    else:
        raise SVGParseError("Unknown unit '%s'" % unit)

def parseDashArray(array):
    return map(parseLength, re.split('[ ,]+', array))

def parseOpacity(value): 
    try:
        opacity = float(value)
    except ValueError:
        raise SVGParseError('expected float value')
    
    # clamp value
    opacity = min(max(opacity, 0.), 1.)
    
    return opacity

if __name__ == '__main__':
    print parseAngle('3.14253rad')
    print parseLength('10.5cm')
