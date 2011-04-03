#!python -u
# -*- coding: utf-8 -*-
# Code from matplotlib
import sys
import os
from os.path import join, abspath, dirname
from collections import namedtuple

from svgplotlib.Config import *
import svgplotlib.freetype as ft

def unichr_safe(index):
    """
    Return the Unicode character corresponding to the index,
    or the replacement character if this is a narrow build of Python
    and the requested character is outside the BMP.
    """
    try:
        return unichr(index)
    except ValueError:
        return unichr(0xFFFD)
        
class Font(ft.FT2Font):
    def __init__(self, fname):
        ft.FT2Font.__init__(self, fname)
        
        self._charmap = None
        self._glyphmap = None
        
    @property
    def charmap(self):
        if self._charmap is None:
            self._charmap = self.get_charmap()
        
        return self._charmap
    
    @property
    def glyphmap(self):
        if self._glyphmap is None:
            charmap = self.charmap
            self._glyphmap = dict(data[::-1] for data in charmap.iteritems())
        
        return self._glyphmap
    
    def get_offset(self, glyph, dpi):
        if self.postscript_name == 'Cmex10':
            return glyph.height/64./2. + 256./64. * dpi/72.
        
        return 0.
    
    def SVGDefID(self, c, fontsize):
        cmap = self.charmap
        family = self.family_name.replace(' ','')
        style = self.style_name.replace(' ','')
        
        ccode = ord(c)
        gind = cmap.get(ccode)
        if gind is None:
            ccode = ord('?')
        
        return "%s-%s-%dpx-%d" % (family, style, fontsize, ccode)
        
    def SVGGlyph(self, ccode, fontsize):
        '''
        Return SVG paths of glyp
        '''
        self.set_size(fontsize, 72)
        glyph = self.load_char(ccode)
        
        path_data = []
        append = path_data.append
        
        for step in glyph.path:
            code = step[0]

            if code == 0:   # MOVE_TO
                x, y = step[1:]
                append('M %g %g' % (x, -y))
                
            elif code == 1: # LINE_TO
                x, y = step[1:]
                append('L %g %g' % (x, -y))
                
            elif code == 2: # CURVE3
                x1, y1, x2, y2 = step[1:]
                append('Q %g %g %g %g' % (x1, -y1, x2, -y2))
                
            elif code == 3: # CURVE4
                x1, y1, x2, y2, x3, y3 = step[1:]
                append('C %g %g %g %g %g %g' % (x1, -y1, x2, -y2, x3, -y3))
                
            elif code == 4: # ENDPOLY
                append('Z')
            
        return " ".join(path_data)
            
        
# map from TEX font styles to Bakomac
fontAlias = {
    'cal' : 'cmsy10',
    'rm'  : 'cmr10',
    'tt'  : 'cmtt10',
    'it'  : 'cmmi10',
    'bf'  : 'cmb10',
    'sf'  : 'cmss10',
    'ex'  : 'cmex10'
}

Metrics = namedtuple('Metrics', 'advance height width xmin xmax ymin ymax iceberg slanted')
Result = namedtuple('Result', 'font fontsize postscript_name metrics symbol_name num glyph offset')

class BakomaFonts:
    """
    Use the Bakoma TrueType fonts for rendering.

    Symbols are strewn about a number of font files, each of which has
    its own proprietary 8-bit encoding.
    """
    def __init__(self):
        self.fontMap = {}
        self.glyphd = {}
        self.used_characters = {}
        
        # load fonts into dict
        for fontpath in DEFAULTTEXFONTS.split(';'):
            if not os.path.exists(fontpath):
                continue
            
            for filename in os.listdir(fontpath):
                name, ext = os.path.splitext(filename)
                
                if ext.lower() not in frozenset(('.ttf', '.otf')):
                    continue
                
                if not name.startswith('cm'):
                    continue
                
                path = os.path.join(fontpath, filename)
                self.fontMap[name] = Font(path)
    
    def get_glyph(self, fontname, sym):
        num = 0
        slanted = False
        symbolname = None
        
        if fontname in fontAlias:
            fontname = fontAlias[fontname]
        
        font = self.fontMap[fontname]
        
        if fontname in self.fontMap and sym in latex_to_bakoma:
            basename, num = latex_to_bakoma[sym]
            
            slanted = (basename == "cmmi10") or sym in slanted_symbols
            font = self.fontMap[basename]
            
            symbolname = font.get_glyph_name(num)
            num = font.glyphmap[num]
        
        elif len(sym) == 1:
            slanted = (fontname == "it")
            
            num = ord(sym)
            if num in font.charmap:
                symbolname = font.get_glyph_name(font.charmap[num])
            
        return font, num, symbolname, slanted
        
    def get_info(self, fontname, fontclass, sym, fontsize, dpi):
        key = (fontname, fontclass, sym, fontsize, dpi)
        if key in self.glyphd:
            return self.glyphd[key]
        
        font, num, symbolname, slanted = self.get_glyph(fontname, sym)
        
        font.set_size(fontsize, dpi)
        glyph = font.load_char(num, ft.LOAD_NO_HINTING)
        
        xmin, ymin, xmax, ymax = (val/64.0 for val in glyph.bbox)
        offset = font.get_offset(glyph, dpi)
        
        metrics = Metrics(
            advance = glyph.linearHoriAdvance/65536.,
            height  = glyph.height/64.,
            width   = glyph.width/64.,
            xmin    = xmin,
            xmax    = xmax,
            ymin    = ymin + offset,
            ymax    = ymax + offset,
            # iceberg is the equivalent of TeX's "height"
            iceberg = glyph.horiBearingY/64. + offset,
            slanted = slanted
        )
        
        result = self.glyphd[key] = Result(
            font            = font,
            fontsize        = fontsize,
            postscript_name = font.postscript_name,
            metrics         = metrics,
            symbol_name     = symbolname,
            num             = num,
            glyph           = glyph,
            offset          = offset
        )
        
        return result
    
    def get_xheight(self, fontname, fontsize, dpi):
        if fontname in fontAlias:
            fontname = fontAlias[fontname]
            
        font = self.fontMap[fontname]
        
        font.set_size(fontsize, dpi)
        pclt = font.get_sfnt_table('pclt')
        if pclt is None or pclt['xHeight'] == 0.:
            # Some fonts don't store the xHeight, so we do a poor man's xHeight
            metrics = self.get_metrics(fontname, 'it', 'x', fontsize, dpi)
            return metrics.iceberg
            
        xHeight = (pclt['xHeight'] / 64.) * (fontsize / 12.) * (dpi / 100.)
        return xHeight
        
    def get_underline_thickness(self, fontsize, dpi):
        # This function used to grab underline thickness from the font
        # metrics, but that information is just too un-reliable, so it
        # is now hardcoded.
        return ((.75 / 12.) * fontsize * dpi) / 72.
    
    def get_kern(self, font1, fontclass1, sym1, fontsize1,
                 font2, fontclass2, sym2, fontsize2, dpi):
        """
        Get the kerning distance for font between *sym1* and *sym2*.
        """
        if font1 == font2 and fontsize1 == fontsize2:
            info1 = self.get_info(font1, fontclass1, sym1, fontsize1, dpi)
            info2 = self.get_info(font2, fontclass2, sym2, fontsize2, dpi)
            font = info1.font
            
            return font.get_kerning(info1.num, info2.num) / 64.
            
        return 0.
    
    def get_metrics(self, *args):
        return self.get_info(*args).metrics
    
    def get_sized_alternatives_for_symbol(self, fontname, sym):
        return size_alternatives.get(sym, [(fontname, sym)])
        
slanted_symbols = set(("\int",  "\oint"))

# The Bakoma fonts contain many pre-sized alternatives for the
# delimiters.  The AutoSizedChar class will use these alternatives
# and select the best (closest sized) glyph.
size_alternatives = {
    '('          : [('rm', '('), ('ex', '\xa1'), ('ex', '\xb3'),
                    ('ex', '\xb5'), ('ex', '\xc3')],
    ')'          : [('rm', ')'), ('ex', '\xa2'), ('ex', '\xb4'),
                    ('ex', '\xb6'), ('ex', '\x21')],
    '{'          : [('cal', '{'), ('ex', '\xa9'), ('ex', '\x6e'),
                    ('ex', '\xbd'), ('ex', '\x28')],
    '}'          : [('cal', '}'), ('ex', '\xaa'), ('ex', '\x6f'),
                    ('ex', '\xbe'), ('ex', '\x29')],
    
    # The fourth size of '[' is mysteriously missing from the BaKoMa
    # font, so I've ommitted it for both '[' and ']'
    '['          : [('rm', '['), ('ex', '\xa3'), ('ex', '\x68'),
                    ('ex', '\x22')],
    ']'          : [('rm', ']'), ('ex', '\xa4'), ('ex', '\x69'),
                    ('ex', '\x23')],
    r'\lfloor'   : [('ex', '\xa5'), ('ex', '\x6a'),
                    ('ex', '\xb9'), ('ex', '\x24')],
    r'\rfloor'   : [('ex', '\xa6'), ('ex', '\x6b'),
                    ('ex', '\xba'), ('ex', '\x25')],
    r'\lceil'    : [('ex', '\xa7'), ('ex', '\x6c'),
                    ('ex', '\xbb'), ('ex', '\x26')],
    r'\rceil'    : [('ex', '\xa8'), ('ex', '\x6d'),
                    ('ex', '\xbc'), ('ex', '\x27')],
    r'\langle'   : [('ex', '\xad'), ('ex', '\x44'),
                    ('ex', '\xbf'), ('ex', '\x2a')],
    r'\rangle'   : [('ex', '\xae'), ('ex', '\x45'),
                    ('ex', '\xc0'), ('ex', '\x2b')],
    r'\__sqrt__' : [('ex', '\x70'), ('ex', '\x71'),
                    ('ex', '\x72'), ('ex', '\x73')],
    r'\backslash': [('ex', '\xb2'), ('ex', '\x2f'),
                    ('ex', '\xc2'), ('ex', '\x2d')],
    r'/'         : [('rm', '/'), ('ex', '\xb1'), ('ex', '\x2e'),
                    ('ex', '\xcb'), ('ex', '\x2c')],
    r'\widehat'  : [('rm', '\x5e'), ('ex', '\x62'), ('ex', '\x63'),
                    ('ex', '\x64')],
    r'\widetilde': [('rm', '\x7e'), ('ex', '\x65'), ('ex', '\x66'),
                    ('ex', '\x67')],
    r'<'         : [('cal', 'h'), ('ex', 'D')],
    r'>'         : [('cal', 'i'), ('ex', 'E')]
}

aliases = (
    ('\leftparen', '('),
    ('\rightparent', ')'),
    ('\leftbrace', '{'),
    ('\rightbrace', '}'),
    ('\leftbracket', '['),
    ('\rightbracket', ']')
)

for alias, target in aliases:
    size_alternatives[alias] = size_alternatives[target]

latex_to_bakoma = {
    r'\oint'                     : ('cmex10',  45),
    r'\bigodot'                  : ('cmex10',  50),
    r'\bigoplus'                 : ('cmex10',  55),
    r'\bigotimes'                : ('cmex10',  59),
    r'\sum'                      : ('cmex10',  51),
    r'\prod'                     : ('cmex10',  24),
    r'\int'                      : ('cmex10',  56),
    r'\bigcup'                   : ('cmex10',  28),
    r'\bigcap'                   : ('cmex10',  60),
    r'\biguplus'                 : ('cmex10',  32),
    r'\bigwedge'                 : ('cmex10',   4),
    r'\bigvee'                   : ('cmex10',  37),
    r'\coprod'                   : ('cmex10',  42),
    r'\__sqrt__'                 : ('cmex10',  48),
    r'\leftbrace'                : ('cmex10',  92),
    r'{'                         : ('cmex10',  92),
    r'\{'                        : ('cmex10',  92),
    r'\rightbrace'               : ('cmex10', 130),
    r'}'                         : ('cmex10', 130),
    r'\}'                        : ('cmex10', 130),
    r'\leftangle'                : ('cmex10',  97),
    r'\rightangle'               : ('cmex10',  64),
    r'\langle'                   : ('cmex10',  97),
    r'\rangle'                   : ('cmex10',  64),
    r'\widehat'                  : ('cmex10',  15),
    r'\widetilde'                : ('cmex10',  52),
    r'\widebar'                  : ('cmr10',  131),

    r'\omega'                    : ('cmmi10',  29),
    r'\varepsilon'               : ('cmmi10',  20),
    r'\vartheta'                 : ('cmmi10',  22),
    r'\varrho'                   : ('cmmi10',  61),
    r'\varsigma'                 : ('cmmi10',  41),
    r'\varphi'                   : ('cmmi10',   6),
    r'\leftharpoonup'            : ('cmmi10', 108),
    r'\leftharpoondown'          : ('cmmi10',  68),
    r'\rightharpoonup'           : ('cmmi10', 117),
    r'\rightharpoondown'         : ('cmmi10',  77),
    r'\triangleright'            : ('cmmi10', 130),
    r'\triangleleft'             : ('cmmi10',  89),
    r'.'                         : ('cmmi10',  51),
    r','                         : ('cmmi10',  44),
    r'<'                         : ('cmmi10',  99),
    r'/'                         : ('cmmi10',  98),
    r'>'                         : ('cmmi10', 107),
    r'\flat'                     : ('cmmi10', 131),
    r'\natural'                  : ('cmmi10',  90),
    r'\sharp'                    : ('cmmi10',  50),
    r'\smile'                    : ('cmmi10',  97),
    r'\frown'                    : ('cmmi10',  58),
    r'\ell'                      : ('cmmi10', 102),
    r'\imath'                    : ('cmmi10',   8),
    r'\jmath'                    : ('cmmi10',  65),
    r'\wp'                       : ('cmmi10',  14),
    r'\alpha'                    : ('cmmi10',  13),
    r'\beta'                     : ('cmmi10',  35),
    r'\gamma'                    : ('cmmi10',  24),
    r'\delta'                    : ('cmmi10',  38),
    r'\epsilon'                  : ('cmmi10',  54),
    r'\zeta'                     : ('cmmi10',  10),
    r'\eta'                      : ('cmmi10',   5),
    r'\theta'                    : ('cmmi10',  18),
    r'\iota'                     : ('cmmi10',  28),
    r'\lambda'                   : ('cmmi10',   9),
    r'\mu'                       : ('cmmi10',  32),
    r'\nu'                       : ('cmmi10',  34),
    r'\xi'                       : ('cmmi10',   7),
    r'\pi'                       : ('cmmi10',  36),
    r'\kappa'                    : ('cmmi10',  30),
    r'\rho'                      : ('cmmi10',  39),
    r'\sigma'                    : ('cmmi10',  21),
    r'\tau'                      : ('cmmi10',  43),
    r'\upsilon'                  : ('cmmi10',  25),
    r'\phi'                      : ('cmmi10',  42),
    r'\chi'                      : ('cmmi10',  17),
    r'\psi'                      : ('cmmi10',  31),
    r'|'                         : ('cmsy10',  47),
    r'\|'                        : ('cmsy10',  47),
    r'('                         : ('cmr10',  119),
    r'\leftparen'                : ('cmr10',  119),
    r'\rightparen'               : ('cmr10',   68),
    r')'                         : ('cmr10',   68),
    r'+'                         : ('cmr10',   76),
    r'0'                         : ('cmr10',   40),
    r'1'                         : ('cmr10',  100),
    r'2'                         : ('cmr10',   49),
    r'3'                         : ('cmr10',  110),
    r'4'                         : ('cmr10',   59),
    r'5'                         : ('cmr10',  120),
    r'6'                         : ('cmr10',   69),
    r'7'                         : ('cmr10',  127),
    r'8'                         : ('cmr10',   77),
    r'9'                         : ('cmr10',   22),
    r'                           :'                    : ('cmr10',   85),
    r';'                         : ('cmr10',   31),
    r'='                         : ('cmr10',   41),
    r'\leftbracket'              : ('cmr10',   62),
    r'['                         : ('cmr10',   62),
    r'\rightbracket'             : ('cmr10',   72),
    r']'                         : ('cmr10',   72),
    r'\%'                        : ('cmr10',   48),
    r'%'                         : ('cmr10',   48),
    r'\$'                        : ('cmr10',   99),
    r'@'                         : ('cmr10',  111),
    r'\#'                        : ('cmr10',   39),
    r'\_'                        : ('cmtt10', 79),
    r'\Gamma'                    : ('cmr10',  19),
    r'\Delta'                    : ('cmr10',   6),
    r'\Theta'                    : ('cmr10',   7),
    r'\Lambda'                   : ('cmr10',  14),
    r'\Xi'                       : ('cmr10',   3),
    r'\Pi'                       : ('cmr10',  17),
    r'\Sigma'                    : ('cmr10',  10),
    r'\Upsilon'                  : ('cmr10',  11),
    r'\Phi'                      : ('cmr10',   9),
    r'\Psi'                      : ('cmr10',  15),
    r'\Omega'                    : ('cmr10',  12),

    # these are mathml names, I think.  I'm just using them for the
    # tex methods noted
    r'\circumflexaccent'         : ('cmr10',   124), # for \hat
    r'\combiningbreve'           : ('cmr10',   81),  # for \breve
    r'\combiningoverline'        : ('cmr10',   131),  # for \bar
    r'\combininggraveaccent'     : ('cmr10', 114), # for \grave
    r'\combiningacuteaccent'     : ('cmr10', 63), # for \accute
    r'\combiningdiaeresis'       : ('cmr10', 91), # for \ddot
    r'\combiningtilde'           : ('cmr10', 75), # for \tilde
    r'\combiningrightarrowabove' : ('cmmi10', 110), # for \vec
    r'\combiningdotabove'        : ('cmr10', 26), # for \dot

    r'\leftarrow'                : ('cmsy10',  10),
    r'\uparrow'                  : ('cmsy10',  25),
    r'\downarrow'                : ('cmsy10',  28),
    r'\leftrightarrow'           : ('cmsy10',  24),
    r'\nearrow'                  : ('cmsy10',  99),
    r'\searrow'                  : ('cmsy10',  57),
    r'\simeq'                    : ('cmsy10', 108),
    r'\Leftarrow'                : ('cmsy10', 104),
    r'\Rightarrow'               : ('cmsy10', 112),
    r'\Uparrow'                  : ('cmsy10',  60),
    r'\Downarrow'                : ('cmsy10',  68),
    r'\Leftrightarrow'           : ('cmsy10',  51),
    r'\nwarrow'                  : ('cmsy10',  65),
    r'\swarrow'                  : ('cmsy10', 116),
    r'\propto'                   : ('cmsy10',  15),
    r'\prime'                    : ('cmsy10',  73),
    r"'"                         : ('cmsy10',  73),
    r'\infty'                    : ('cmsy10',  32),
    r'\in'                       : ('cmsy10',  59),
    r'\ni'                       : ('cmsy10', 122),
    r'\bigtriangleup'            : ('cmsy10',  80),
    r'\bigtriangledown'          : ('cmsy10', 132),
    r'\slash'                    : ('cmsy10',  87),
    r'\forall'                   : ('cmsy10',  21),
    r'\exists'                   : ('cmsy10',   5),
    r'\neg'                      : ('cmsy10',  20),
    r'\emptyset'                 : ('cmsy10',  33),
    r'\Re'                       : ('cmsy10',  95),
    r'\Im'                       : ('cmsy10',  52),
    r'\top'                      : ('cmsy10', 100),
    r'\bot'                      : ('cmsy10',  11),
    r'\aleph'                    : ('cmsy10',  26),
    r'\cup'                      : ('cmsy10',   6),
    r'\cap'                      : ('cmsy10',  19),
    r'\uplus'                    : ('cmsy10',  58),
    r'\wedge'                    : ('cmsy10',  43),
    r'\vee'                      : ('cmsy10',  96),
    r'\vdash'                    : ('cmsy10', 109),
    r'\dashv'                    : ('cmsy10',  66),
    r'\lfloor'                   : ('cmsy10', 117),
    r'\rfloor'                   : ('cmsy10',  74),
    r'\lceil'                    : ('cmsy10', 123),
    r'\rceil'                    : ('cmsy10',  81),
    r'\lbrace'                   : ('cmsy10',  92),
    r'\rbrace'                   : ('cmsy10', 105),
    r'\mid'                      : ('cmsy10',  47),
    r'\vert'                     : ('cmsy10',  47),
    r'\Vert'                     : ('cmsy10',  44),
    r'\updownarrow'              : ('cmsy10',  94),
    r'\Updownarrow'              : ('cmsy10',  53),
    r'\backslash'                : ('cmsy10', 126),
    r'\wr'                       : ('cmsy10', 101),
    r'\nabla'                    : ('cmsy10', 110),
    r'\sqcup'                    : ('cmsy10',  67),
    r'\sqcap'                    : ('cmsy10', 118),
    r'\sqsubseteq'               : ('cmsy10',  75),
    r'\sqsupseteq'               : ('cmsy10', 124),
    r'\S'                        : ('cmsy10', 129),
    r'\dag'                      : ('cmsy10',  71),
    r'\ddag'                     : ('cmsy10', 127),
    r'\P'                        : ('cmsy10', 130),
    r'\clubsuit'                 : ('cmsy10',  18),
    r'\diamondsuit'              : ('cmsy10',  34),
    r'\heartsuit'                : ('cmsy10',  22),
    r'-'                         : ('cmsy10',  17),
    r'\cdot'                     : ('cmsy10',  78),
    r'\times'                    : ('cmsy10',  13),
    r'*'                         : ('cmsy10',   9),
    r'\ast'                      : ('cmsy10',   9),
    r'\div'                      : ('cmsy10',  31),
    r'\diamond'                  : ('cmsy10',  48),
    r'\pm'                       : ('cmsy10',   8),
    r'\mp'                       : ('cmsy10',  98),
    r'\oplus'                    : ('cmsy10',  16),
    r'\ominus'                   : ('cmsy10',  56),
    r'\otimes'                   : ('cmsy10',  30),
    r'\oslash'                   : ('cmsy10', 107),
    r'\odot'                     : ('cmsy10',  64),
    r'\bigcirc'                  : ('cmsy10', 115),
    r'\circ'                     : ('cmsy10',  72),
    r'\bullet'                   : ('cmsy10',  84),
    r'\asymp'                    : ('cmsy10', 121),
    r'\equiv'                    : ('cmsy10',  35),
    r'\subseteq'                 : ('cmsy10', 103),
    r'\supseteq'                 : ('cmsy10',  42),
    r'\leq'                      : ('cmsy10',  14),
    r'\geq'                      : ('cmsy10',  29),
    r'\preceq'                   : ('cmsy10',  79),
    r'\succeq'                   : ('cmsy10', 131),
    r'\sim'                      : ('cmsy10',  27),
    r'\approx'                   : ('cmsy10',  23),
    r'\subset'                   : ('cmsy10',  50),
    r'\supset'                   : ('cmsy10',  86),
    r'\ll'                       : ('cmsy10',  85),
    r'\gg'                       : ('cmsy10',  40),
    r'\prec'                     : ('cmsy10',  93),
    r'\succ'                     : ('cmsy10',  49),
    r'\rightarrow'               : ('cmsy10',  12),
    r'\to'                       : ('cmsy10',  12),
    r'\spadesuit'                : ('cmsy10',   7),
}

if __name__ == '__main__':
    fonts = BakomaFonts()
    for name, font in fonts.fontMap.iteritems():
        print name, font
    
    '''
    info = fonts.get_info('cmex10', 'class', r'\oint', 12, 72.)
    print info
    
    xheight = fonts.get_xheight('cmex10', 12, 72.)
    print xheight
    
    print fonts.get_underline_thickness(12, 72.)
    '''