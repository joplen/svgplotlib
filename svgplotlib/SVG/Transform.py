#!/usr/bin/python
# -*- coding: utf-8 -*-
from svgplotlib.SVG.Parsers import Lexer, EOF

class ParseTransformError(Exception):
    pass

class Transform(Lexer):
    """
    Break SVG transform into tokens.
    """
    numfloat = object()
    numint = object()
    string = object()
    skip = object()
    
    numbers = frozenset((numfloat, numint))
    
    lexicon = ( \
        (numfloat   , Lexer.Float),
        (numint     , Lexer.Int),
        (string     , r'\w+'),
        (skip       , r'[\(\), \n]'),
    )
    
    ignore = frozenset((skip,))
    
    callbacks = {
        numfloat    : lambda self,value: float(value),
        numint      : lambda self,value: float(value)
    }
    
    def __init__(self):
        Lexer.__init__(self)
    
    def assertion(self, condition, msg = ''):
        if not condition:
            raise ParseTransformError(msg)
            
    def iterparse(self, text):
        """
        Parse a string of SVG transform data.
        """
        assertion = self.assertion
        next = self.lex(text).next
        numbers = self.numbers
        string = self.string
        
        token, value = next()
        while token != EOF:
            assertion(token is string, 'Expected string')
            
            transform = value
        
            if transform == 'matrix':
                token, a = next()
                assertion(token in numbers, 'Expected number')
                    
                token, b = next()
                assertion(token in numbers, 'Expected number')
                
                token, c = next()
                assertion(token in numbers, 'Expected number')
                
                token, d = next()
                assertion(token in numbers, 'Expected number')
                
                token, e = next()
                assertion(token in numbers, 'Expected number')
                
                token, f = next()
                assertion(token in numbers, 'Expected number')
                
                yield (transform, (a,b,c,d,e,f))
            
            elif transform == 'translate':
                token, tx = next()
                assertion(token in numbers, 'Expected number')
                
                token, value = next()
                ty = value
                if not token in numbers:
                    ty = 0.
                
                yield (transform, (tx, ty))
                
                if not token in numbers:
                    continue
                    
            elif transform == 'scale':
                token, sx = next()
                assertion(token in numbers, 'Expected number')
                
                token, value = next()
                sy = value
                if not token in numbers:
                    sy = sx
                
                yield (transform, (sx, sy))
                
                if not token in numbers:
                    continue
                
            elif transform == 'rotate':
                token, angle = next()
                assertion(token in numbers, 'Expected number')
                
                token, value = next()
                cx = value
                
                if token in numbers:
                    token, value = next()
                    assertion(token in numbers, 'Expected number')
                    
                    cy = value
                                        
                    yield (transform, (angle,(cx,cy)))
                    
                else:
                    yield (transform, (angle,None))
                    continue
                
            elif transform == 'skewX' or transform == 'skewY':
                token, value = next()
                angle = value
                assertion(token in numbers, 'Expected number')
                
                yield (transform, (angle,))
            
            else:
                raise ParseTransformError("unknown transform '%s'" % transform)
            
            # fetch next token
            token, value = next()
            
parseTransform = Transform()

if __name__ == '__main__':
    print tuple(parseTransform.iterparse("scale(1.8) translate(0, -150)"))
