import re

try:
    from collections import OrderedDict as Odict
except ImportError:
    class Odict(dict):
        """Python < v2.7 has no OrderedDict.
        CSS that requires specific ordering to render correctly
        will therefore not work without an OrderedDict implementation.
        To do?"""
        pass

class CSS(Odict):
    def __init__(self, *args, **kwargs):
        super(CSS,self).__init__()
        self.update(*args, **kwargs)
    def __repr__(self):
        return '\n'.join( \
                ['{0} {1}'.format(*item) for item in self.items()] )

        string = ''
        for style in self.iterkeys():
            string = '{0}\n{1} {2}\n'.format(string,style, self[style])

    def __setitem__(self, key, value):
        super(CSS, self).__setitem__(key, CSSStyle(value))

    def setdefault(self, key, value=None):
        if key not in self:
            self[key] = value
        return self[key]

    def update(self, *args, **kwargs):
        if len(args) > 1:
            raise TypeError("update expected at most 1 arguments, got %d" % len(args))
        elif args:
            arg = args[0]
            print arg
            raise
        for selector, styles in kwargs.items():
            # call __setitem__ to turn styles into a CSSStyle dict
            self[selector] = styles

quotes = re.compile(r'[\'"]')

class CSSStyle(Odict):
    """Just an ordered dict with a custom repr method.
    Prints out CSS formatted styles. This object is 
    intended to store just key:value styles."""
    mangle = re.compile( '\_' )
    def __repr__(self):
        sub = self.mangle.sub
        return '{{\n{0};\n}}'.format( \
                    ';\n'.join( \
                        ['{0}:{1}'.format(sub('-',item[0]), item[1] ) \
                            for item in self.items() ] ) )


if __name__ == '__main__':
    cssdict =  { '#boxId' : { 'border_color' : 'blue',
                              'border'       : '1px solid' } }
    print CSS(**cssdict)
