#!/usr/bin/python
# -*- coding: utf-8 -*-
from svgplotlib.SVG.Parsers import Lexer, EOF

class ParseStyleError(Exception):
    pass
    
class Style(Lexer):
    """
    Break SVG inline style into tokens
    """
    name = object()
    value = object()
    delimiter = object()
    comment = object()
    
    lexicon = ( \
        (delimiter   , r'[ :;\n]'),
        (comment     , r'/\*.+\*/'),
        (name        , r'[\w\-#]+?(?=:)'),
        (value       , r'[\w\-#\.\(\)%,][\w \-#\.\(\)%,]*?(?=[;])'),
    )
    
    ignore = frozenset((delimiter,comment))
    
    def __init__(self):
        Lexer.__init__(self)
    
    def parse(self, text):
        """
        Parse a string of SVG <path> data.
        """
        if not text:
            return {}
            
        next = self.lex(text + ';').next
        styles = {}
        
        while True:
            token, value = next()
            if token == EOF:
                break
            
            name = value.rstrip(':')
            
            token, value = next()
            
            if token == EOF:
                raise ParseStyleError('expected value in style definition')
            
            if name in styles:
                raise ParseStyleError('style redefined')
            
            styles[name] = value
        
        return styles
            

parseStyle = Style()

if __name__ == '__main__':
    print parseStyle.parse("fill:white;stroke:black;stroke-width:0.5")
