#!/usr/bin/python
# -*- coding: utf-8 -*-
from svgplotlib.SVG.Parsers import Lexer, EOF

class ParsePathError(Exception):
    pass
    

class Path(Lexer):
    """
    Break SVG path data into tokens.
    
    The SVG spec requires that tokens are greedy.
    This lexer relies on Python's regexes defaulting to greediness.
    """
    numfloat = object()
    numint = object()
    numexp = object()
    string = object()
    skip = object
    
    lexicon = ( \
        (numfloat   , Lexer.Float),
        (numint     , Lexer.Int),
        (numexp     , r'(?:[Ee][-\+]?\d+)'),
        (string     , r'[AaCcHhLlMmQqSsTtVvZz]'),
        (skip       , r'[, \n]'),
    )
    
    ignore = frozenset((skip,))
    
    callbacks = {
        numfloat    : lambda self,value: float(value),
        numint      : lambda self,value: float(value),
        numexp      : lambda self,value: float('1.'+value)
    }
    
    numbers = frozenset((numfloat, numint, numexp))
    
    def __init__(self):
        Lexer.__init__(self)
    
    def assertion(self, condition, msg = ''):
        if not condition:
            raise ParsePathError(msg)
            
    def iterparse(self, text):
        """
        Parse a string of SVG <path> data.
        """
        assertion = self.assertion
        numbers = self.numbers
        string = self.string
        
        next = self.lex(text).next
        
        token, value = next()
        while token != EOF:
            assertion(token is string, 'Expected string in path data')
            cmd = value
            CMD = value.upper()
            
            # closePath
            if CMD in 'Z':
                token, value = next()
                yield (cmd, (None,))
            
            # moveTo, lineTo, curve, smoothQuadraticBezier, quadraticBezier, smoothCurve
            elif CMD in 'CMLTQS':
                coords = []
                token, value = next()
                while token in numbers:
                    last = value
                    coords.append(last)
                    
                    token, value = next() 
                    assertion(token in numbers, 'Expected number in path data')
                    
                    coords.append(value)
                    
                    token, value = next()
                
                if CMD == 'C':
                    assertion(len(coords) % 3 == 0, 'Expected coordinate triplets in path data')
                
                yield (cmd, tuple(coords))
            
            # horizontalLine or verticalLine
            elif CMD in 'HV':
                coords = []
                token, value = next()
                assertion(token in numbers, 'Expected number')
                
                while token in numbers:
                    coords.append(value)
                    token, value = next()
                    
                yield (cmd, tuple(coords))
            
            # ellipticalArc
            elif CMD == 'A':
                coords = []
                token, value = next()
                assertion(token in numbers and value > 0, 'expected positive number in path data')
                
                while token in numbers:
                    rx = value
                    coords.append(rx)
                    
                    token, ry = next()
                    assertion(token in numbers and ry > 0, 'expected positive number in path data')
                    coords.append(ry)
                    
                    token, rotation = next()
                    assertion(token in numbers, 'expected number in path data')
                    coords.append(rotation)
                    
                    token, largearc = next()
                    assertion(token in numbers, 'expected 0 or 1 in path data')
                    coords.append(largearc)
                    
                    token, sweeparc = next()
                    assertion(token in numbers, 'expected 0 or 1 in path data')
                    coords.append(sweeparc)
                    
                    token, x = next()
                    assertion(token in numbers, 'expected number in path data')
                    coords.append(x)
                    
                    token, y = next()
                    assertion(token in numbers, 'expected number in path data')
                    coords.append(y)
                    
                    token, value = next()
                    
                yield (cmd, coords)
                
            else:
                raise ParsePathError("cmd '%s' in path data not supported" % cmd)

parsePath = Path()

if __name__ == '__main__':
    print tuple(parsePath.iterparse("M250,150 L150,350 L350,350 Z"))