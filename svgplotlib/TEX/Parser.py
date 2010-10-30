#!/usr/bin/python
# -*- coding: utf-8 -*-
# Code from matplotlib
from pyparsing import (Combine, Group, Optional, Forward,
    Literal, OneOrMore, ZeroOrMore, ParseException, Empty,
    ParseResults, Suppress, oneOf, StringEnd, ParseFatalException,
    FollowedBy, Regex, ParserElement)

from svgplotlib.TEX.Model import *

# Enable packrat parsing
ParserElement.enablePackrat()

def Error(msg):
    """
    Helper class to raise parser errors.
    """
    def raise_error(s, loc, toks):
        raise ParseFatalException(msg + "\n" + s)

    empty = Empty()
    empty.setParseAction(raise_error)
    return empty

class Parser:
    """
    This is the pyparsing-based parser for math expressions.  It
    actually parses full strings *containing* math expressions, in
    that raw text may also appear outside of pairs of ``$``.

    The grammar is based directly on that in TeX, though it cuts a few
    corners.
    """
    _binary_operators = set(r'''
      + *
      \pm             \sqcap                   \rhd
      \mp             \sqcup                   \unlhd
      \times          \vee                     \unrhd
      \div            \wedge                   \oplus
      \ast            \setminus                \ominus
      \star           \wr                      \otimes
      \circ           \diamond                 \oslash
      \bullet         \bigtriangleup           \odot
      \cdot           \bigtriangledown         \bigcirc
      \cap            \triangleleft            \dagger
      \cup            \triangleright           \ddagger
      \uplus          \lhd                     \amalg'''.split())

    _relation_symbols = set(r'''
      = < > :
      \leq            \geq             \equiv           \models
      \prec           \succ            \sim             \perp
      \preceq         \succeq          \simeq           \mid
      \ll             \gg              \asymp           \parallel
      \subset         \supset          \approx          \bowtie
      \subseteq       \supseteq        \cong            \Join
      \sqsubset       \sqsupset        \neq             \smile
      \sqsubseteq     \sqsupseteq      \doteq           \frown
      \in             \ni              \propto
      \vdash          \dashv           \dots'''.split())

    _arrow_symbols = set(r'''
      \leftarrow              \longleftarrow           \uparrow
      \Leftarrow              \Longleftarrow           \Uparrow
      \rightarrow             \longrightarrow          \downarrow
      \Rightarrow             \Longrightarrow          \Downarrow
      \leftrightarrow         \longleftrightarrow      \updownarrow
      \Leftrightarrow         \Longleftrightarrow      \Updownarrow
      \mapsto                 \longmapsto              \nearrow
      \hookleftarrow          \hookrightarrow          \searrow
      \leftharpoonup          \rightharpoonup          \swarrow
      \leftharpoondown        \rightharpoondown        \nwarrow
      \rightleftharpoons      \leadsto'''.split())

    _spaced_symbols = _binary_operators | _relation_symbols | _arrow_symbols

    _punctuation_symbols = set(r', ; . ! \ldotp \cdotp'.split())

    _overunder_symbols = set(r'''
       \sum \prod \coprod \bigcap \bigcup \bigsqcup \bigvee
       \bigwedge \bigodot \bigotimes \bigoplus \biguplus
       '''.split())

    _overunder_functions = set(
        r"lim liminf limsup sup max min".split())

    _dropsub_symbols = set(r'''\int \oint'''.split())

    _fontnames = set("rm cal it tt sf bf default bb frak circled scr regular".split())

    _function_names = set("""
      arccos csc ker min arcsin deg lg Pr arctan det lim sec arg dim
      liminf sin cos exp limsup sinh cosh gcd ln sup cot hom log tan
      coth inf max tanh""".split())

    _ambiDelim = set(r"""
      | \| / \backslash \uparrow \downarrow \updownarrow \Uparrow
      \Downarrow \Updownarrow .""".split())

    _leftDelim = set(r"( [ { < \lfloor \langle \lceil".split())

    _rightDelim = set(r") ] } > \rfloor \rangle \rceil".split())

    def __init__(self):
        # All forward declarations are here
        font = Forward().setParseAction(self.font).setName("font")
        latexfont = Forward()
        subsuper = Forward().setParseAction(self.subsuperscript).setName("subsuper")
        placeable = Forward().setName("placeable")
        simple = Forward().setName("simple")
        autoDelim = Forward().setParseAction(self.auto_sized_delimiter)
        self._expression = Forward().setParseAction(self.finish).setName("finish")

        float        = Regex(r"[-+]?([0-9]+\.?[0-9]*|\.[0-9]+)")

        lbrace       = Literal('{').suppress()
        rbrace       = Literal('}').suppress()
        start_group  = (Optional(latexfont) - lbrace)
        start_group.setParseAction(self.start_group)
        end_group    = rbrace.copy()
        end_group.setParseAction(self.end_group)

        bslash       = Literal('\\')

        accent       = oneOf(self._accent_map.keys() +
                             list(self._wide_accents))

        function     = oneOf(list(self._function_names))

        fontname     = oneOf(list(self._fontnames))
        latex2efont  = oneOf(['math' + x for x in self._fontnames])

        space        =(FollowedBy(bslash)
                     + oneOf([r'\ ',
                              r'\/',
                              r'\,',
                              r'\;',
                              r'\quad',
                              r'\qquad',
                              r'\!'])
                      ).setParseAction(self.space).setName('space')

        customspace  =(Literal(r'\hspace')
                     - (( lbrace
                        - float
                        - rbrace
                       ) | Error(r"Expected \hspace{n}"))
                     ).setParseAction(self.customspace).setName('customspace')

        unicode_range = u"\U00000080-\U0001ffff"
        symbol       =(Regex(UR"([a-zA-Z0-9 +\-*/<>=:,.;!'@()\[\]|%s])|(\\[%%${}\[\]_|])" % unicode_range)
                     | (Combine(
                         bslash
                       + oneOf(tex2uni.keys())
                       ) + FollowedBy(Regex("[^a-zA-Z]")))
                     ).setParseAction(self.symbol).leaveWhitespace()

        c_over_c     =(Suppress(bslash)
                     + oneOf(self._char_over_chars.keys())
                     ).setParseAction(self.char_over_chars)

        accent       = Group(
                         Suppress(bslash)
                       + accent
                       - placeable
                     ).setParseAction(self.accent).setName("accent")

        function     =(Suppress(bslash)
                     + function
                     ).setParseAction(self.function).setName("function")

        group        = Group(
                         start_group
                       + ZeroOrMore(
                           autoDelim
                         ^ simple)
                       - end_group
                     ).setParseAction(self.group).setName("group")

        font        <<(Suppress(bslash)
                     + fontname)

        latexfont   <<(Suppress(bslash)
                     + latex2efont)

        frac         = Group(
                       Suppress(Literal(r"\frac"))
                     + ((group + group)
                        | Error(r"Expected \frac{num}{den}"))
                     ).setParseAction(self.frac).setName("frac")

        stackrel     = Group(
                       Suppress(Literal(r"\stackrel"))
                     + ((group + group)
                        | Error(r"Expected \stackrel{num}{den}"))
                     ).setParseAction(self.stackrel).setName("stackrel")


        binom        = Group(
                       Suppress(Literal(r"\binom"))
                     + ((group + group)
                        | Error(r"Expected \binom{num}{den}"))
                     ).setParseAction(self.binom).setName("binom")

        ambiDelim    = oneOf(list(self._ambiDelim))
        leftDelim    = oneOf(list(self._leftDelim))
        rightDelim   = oneOf(list(self._rightDelim))
        rightDelimSafe = oneOf(list(self._rightDelim - set(['}'])))
        genfrac      = Group(
                       Suppress(Literal(r"\genfrac"))
                     + ((Suppress(Literal('{')) +
                         oneOf(list(self._ambiDelim | self._leftDelim | set(['']))) +
                         Suppress(Literal('}')) +
                         Suppress(Literal('{')) +
                         oneOf(list(self._ambiDelim |
                                    (self._rightDelim - set(['}'])) |
                                    set(['', r'\}']))) +
                         Suppress(Literal('}')) +
                         Suppress(Literal('{')) +
                         Regex("[0-9]*(\.?[0-9]*)?") +
                         Suppress(Literal('}')) +
                         group + group + group)
                        | Error(r"Expected \genfrac{ldelim}{rdelim}{rulesize}{style}{num}{den}"))
                     ).setParseAction(self.genfrac).setName("genfrac")


        sqrt         = Group(
                       Suppress(Literal(r"\sqrt"))
                     + Optional(
                         Suppress(Literal("["))
                       - Regex("[0-9]+")
                       - Suppress(Literal("]")),
                         default = None
                       )
                     + (group | Error("Expected \sqrt{value}"))
                     ).setParseAction(self.sqrt).setName("sqrt")

        placeable   <<(function
                     ^ (c_over_c | symbol)
                     ^ accent
                     ^ group
                     ^ frac
                     ^ stackrel
                     ^ binom
                     ^ genfrac
                     ^ sqrt
                     )

        simple      <<(space
                     | customspace
                     | font
                     | subsuper
                     )

        subsuperop   = oneOf(["_", "^"])

        subsuper    << Group(
                         ( Optional(placeable)
                         + OneOrMore(
                             subsuperop
                           - placeable
                           )
                         )
                       | placeable
                     )

        autoDelim   <<(Suppress(Literal(r"\left"))
                     + ((leftDelim | ambiDelim) | Error("Expected a delimiter"))
                     + Group(
                         OneOrMore(
                            autoDelim
                          ^ simple))
                     + Suppress(Literal(r"\right"))
                     + ((rightDelim | ambiDelim) | Error("Expected a delimiter"))
                     )

        math         = OneOrMore(
                       autoDelim
                     ^ simple
                     ).setParseAction(self.math).setName("math")

        math_delim   = ~bslash + Literal('$')

        non_math     = Regex(r"(?:(?:\\[$])|[^$])*"
                     ).setParseAction(self.non_math).setName("non_math").leaveWhitespace()

        self._expression << (
            non_math
          + ZeroOrMore(
                Suppress(math_delim)
              + Optional(math)
              + (Suppress(math_delim)
                 | Error("Expected end of math '$'"))
              + non_math
            )
          ) + StringEnd()

        self.clear()

    def clear(self):
        """
        Clear any state before parsing.
        """
        self._expr = None
        self._state_stack = None
        self._em_width_cache = {}

    def parse(self, s, fonts_object, fontsize, dpi):
        """
        Parse expression *s* using the given *fonts_object* for
        output, at the given *fontsize* and *dpi*.

        Returns the parse tree of :class:`Node` instances.
        """
        self._state_stack = [self.State(fonts_object, 'cmr10', 'rm', fontsize, dpi)]
        try:
            self._expression.parseString(s)
        except ParseException, err:
            raise ValueError("\n".join([
                        "",
                        err.line,
                        " " * (err.column - 1) + "^",
                        str(err)]))
        return self._expr

    # The state of the parser is maintained in a stack.  Upon
    # entering and leaving a group { } or math/non-math, the stack
    # is pushed and popped accordingly.  The current state always
    # exists in the top element of the stack.
    class State:
        """
        Stores the state of the parser.

        States are pushed and popped from a stack as necessary, and
        the "current" state is always at the top of the stack.
        """
        def __init__(self, font_output, font, font_class, fontsize, dpi):
            self.font_output = font_output
            self._font = font
            self.font_class = font_class
            self.fontsize = fontsize
            self.dpi = dpi

        def copy(self):
            return Parser.State(
                self.font_output,
                self.font,
                self.font_class,
                self.fontsize,
                self.dpi)

        def _get_font(self):
            return self._font
            
        def _set_font(self, name):
            if name in ('rm', 'it', 'bf'):
                self.font_class = name
            self._font = name
            
        font = property(_get_font, _set_font)

    def get_state(self):
        """
        Get the current :class:`State` of the parser.
        """
        return self._state_stack[-1]

    def pop_state(self):
        """
        Pop a :class:`State` off of the stack.
        """
        self._state_stack.pop()

    def push_state(self):
        """
        Push a new :class:`State` onto the stack which is just a copy
        of the current state.
        """
        self._state_stack.append(self.get_state().copy())

    def finish(self, s, loc, toks):
        #~ print "finish", toks
        self._expr = Hlist(toks)
        return [self._expr]

    def math(self, s, loc, toks):
        #~ print "math", toks
        hlist = Hlist(toks)
        self.pop_state()
        return [hlist]

    def non_math(self, s, loc, toks):
        #~ print "non_math", toks
        s = toks[0].replace(r'\$', '$')
        symbols = [Char(c, self.get_state()) for c in s]
        hlist = Hlist(symbols)
        # We're going into math now, so set font to 'it'
        self.push_state()
        self.get_state().font = 'it'
        return [hlist]

    def _make_space(self, percentage):
        # All spaces are relative to em width
        state = self.get_state()
        key = (state.font, state.fontsize, state.dpi)
        width = self._em_width_cache.get(key)
        if width is None:
            metrics = state.font_output.get_metrics(
                state.font, 'it', 'm', state.fontsize, state.dpi)
            width = metrics.advance
            self._em_width_cache[key] = width
        return Kern(width * percentage)

    _space_widths = { r'\ '      : 0.3,
                      r'\,'      : 0.4,
                      r'\;'      : 0.8,
                      r'\quad'   : 1.6,
                      r'\qquad'  : 3.2,
                      r'\!'      : -0.4,
                      r'\/'      : 0.4 }
                      
    def space(self, s, loc, toks):
        assert(len(toks)==1)
        num = self._space_widths[toks[0]]
        box = self._make_space(num)
        return [box]

    def customspace(self, s, loc, toks):
        return [self._make_space(float(toks[1]))]

    def symbol(self, s, loc, toks):
        # print "symbol", toks
        c = toks[0]
        try:
            char = Char(c, self.get_state())
        except ValueError:
            raise ParseFatalException("Unknown symbol: %s" % c)

        if c in self._spaced_symbols:
            return [Hlist( [self._make_space(0.2),
                            char,
                            self._make_space(0.2)] ,
                           do_kern = False)]
        elif c in self._punctuation_symbols:
            return [Hlist( [char,
                            self._make_space(0.2)] ,
                           do_kern = False)]
        return [char]

    _char_over_chars = {
        # The first 2 entires in the tuple are (font, char, sizescale) for
        # the two symbols under and over.  The third element is the space
        # (in multiples of underline height)
        r'AA' : (  ('rm', 'A', 1.0), (None, '\circ', 0.5), 0.0),
    }

    def char_over_chars(self, s, loc, toks):
        sym = toks[0]
        state = self.get_state()
        thickness = state.font_output.get_underline_thickness(
            state.font, state.fontsize, state.dpi)

        under_desc, over_desc, space = \
            self._char_over_chars.get(sym, (None, None, 0.0))
        if under_desc is None:
            raise ParseFatalException("Error parsing symbol")

        over_state = state.copy()
        if over_desc[0] is not None:
            over_state.font = over_desc[0]
        over_state.fontsize *= over_desc[2]
        over = Accent(over_desc[1], over_state)

        under_state = state.copy()
        if under_desc[0] is not None:
            under_state.font = under_desc[0]
        under_state.fontsize *= under_desc[2]
        under = Char(under_desc[1], under_state)

        width = max(over.width, under.width)

        over_centered = HCentered([over])
        over_centered.hpack(width, 'exactly')

        under_centered = HCentered([under])
        under_centered.hpack(width, 'exactly')

        return Vlist([
                over_centered,
                Vbox(0., thickness * space),
                under_centered
                ])

    _accent_map = {
        r'hat'   : r'\circumflexaccent',
        r'breve' : r'\combiningbreve',
        r'bar'   : r'\combiningoverline',
        r'grave' : r'\combininggraveaccent',
        r'acute' : r'\combiningacuteaccent',
        r'ddot'  : r'\combiningdiaeresis',
        r'tilde' : r'\combiningtilde',
        r'dot'   : r'\combiningdotabove',
        r'vec'   : r'\combiningrightarrowabove',
        r'"'     : r'\combiningdiaeresis',
        r"`"     : r'\combininggraveaccent',
        r"'"     : r'\combiningacuteaccent',
        r'~'     : r'\combiningtilde',
        r'.'     : r'\combiningdotabove',
        r'^'     : r'\circumflexaccent',
        r'overrightarrow' : r'\rightarrow',
        r'overleftarrow'  : r'\leftarrow'
        }

    _wide_accents = set(r"widehat widetilde widebar".split())

    def accent(self, s, loc, toks):
        assert(len(toks)==1)
        state = self.get_state()
        thickness = state.font_output.get_underline_thickness(
            state.font, state.fontsize, state.dpi)
        if len(toks[0]) != 2:
            raise ParseFatalException("Error parsing accent")
        accent, sym = toks[0]
        if accent in self._wide_accents:
            accent = AutoWidthChar(
                '\\' + accent, sym.width, state, char_class=Accent)
        else:
            accent = Accent(self._accent_map[accent], state)
        centered = HCentered([accent])
        centered.hpack(sym.width, 'exactly')
        return Vlist([
                centered,
                Vbox(0., thickness * 2.0),
                Hlist([sym])
                ])

    def function(self, s, loc, toks):
        #~ print "function", toks
        self.push_state()
        state = self.get_state()
        state.font = 'rm'
        hlist = Hlist([Char(c, state) for c in toks[0]])
        self.pop_state()
        hlist.function_name = toks[0]
        return hlist

    def start_group(self, s, loc, toks):
        self.push_state()
        # Deal with LaTeX-style font tokens
        if len(toks):
            self.get_state().font = toks[0][4:]
        return []

    def group(self, s, loc, toks):
        grp = Hlist(toks[0])
        return [grp]

    def end_group(self, s, loc, toks):
        self.pop_state()
        return []

    def font(self, s, loc, toks):
        assert(len(toks)==1)
        name = toks[0]
        self.get_state().font = name
        return []

    def is_overunder(self, nucleus):
        if isinstance(nucleus, Char):
            return nucleus.c in self._overunder_symbols
        elif isinstance(nucleus, Hlist) and hasattr(nucleus, 'function_name'):
            return nucleus.function_name in self._overunder_functions
        return False

    def is_dropsub(self, nucleus):
        if isinstance(nucleus, Char):
            return nucleus.c in self._dropsub_symbols
        return False

    def is_slanted(self, nucleus):
        if isinstance(nucleus, Char):
            return nucleus.is_slanted()
        return False

    def subsuperscript(self, s, loc, toks):
        assert(len(toks)==1)
        # print 'subsuperscript', toks

        nucleus = None
        sub = None
        super = None

        if len(toks[0]) == 1:
            return toks[0].asList()
        elif len(toks[0]) == 2:
            op, next = toks[0]
            nucleus = Hbox(0.0)
            if op == '_':
                sub = next
            else:
                super = next
        elif len(toks[0]) == 3:
            nucleus, op, next = toks[0]
            if op == '_':
                sub = next
            else:
                super = next
        elif len(toks[0]) == 5:
            nucleus, op1, next1, op2, next2 = toks[0]
            if op1 == op2:
                if op1 == '_':
                    raise ParseFatalException("Double subscript")
                else:
                    raise ParseFatalException("Double superscript")
            if op1 == '_':
                sub = next1
                super = next2
            else:
                super = next1
                sub = next2
        else:
            raise ParseFatalException(
                "Subscript/superscript sequence is too long. "
                "Use braces { } to remove ambiguity.")

        state = self.get_state()
        rule_thickness = state.font_output.get_underline_thickness(state.fontsize, state.dpi)
        xHeight = state.font_output.get_xheight(
            state.font, state.fontsize, state.dpi)

        # Handle over/under symbols, such as sum or integral
        if self.is_overunder(nucleus):
            vlist = []
            shift = 0.
            width = nucleus.width
            if super is not None:
                super.shrink()
                width = max(width, super.width)
            if sub is not None:
                sub.shrink()
                width = max(width, sub.width)

            if super is not None:
                hlist = HCentered([super])
                hlist.hpack(width, 'exactly')
                vlist.extend([hlist, Kern(rule_thickness * 3.0)])
            hlist = HCentered([nucleus])
            hlist.hpack(width, 'exactly')
            vlist.append(hlist)
            if sub is not None:
                hlist = HCentered([sub])
                hlist.hpack(width, 'exactly')
                vlist.extend([Kern(rule_thickness * 3.0), hlist])
                shift = hlist.height
            vlist = Vlist(vlist)
            vlist.shift_amount = shift + nucleus.depth
            result = Hlist([vlist])
            return [result]

        # Handle regular sub/superscripts
        shift_up = nucleus.height - SUBDROP * xHeight
        if self.is_dropsub(nucleus):
            shift_down = nucleus.depth + SUBDROP * xHeight
        else:
            shift_down = SUBDROP * xHeight
        if super is None:
            # node757
            sub.shrink()
            x = Hlist([sub])
            # x.width += SCRIPT_SPACE * xHeight
            shift_down = max(shift_down, SUB1)
            clr = x.height - (abs(xHeight * 4.0) / 5.0)
            shift_down = max(shift_down, clr)
            x.shift_amount = shift_down
        else:
            super.shrink()
            x = Hlist([super, Kern(SCRIPT_SPACE * xHeight)])
            # x.width += SCRIPT_SPACE * xHeight
            clr = SUP1 * xHeight
            shift_up = max(shift_up, clr)
            clr = x.depth + (abs(xHeight) / 4.0)
            shift_up = max(shift_up, clr)
            if sub is None:
                x.shift_amount = -shift_up
            else: # Both sub and superscript
                sub.shrink()
                y = Hlist([sub])
                # y.width += SCRIPT_SPACE * xHeight
                shift_down = max(shift_down, SUB1 * xHeight)
                clr = (2.0 * rule_thickness -
                       ((shift_up - x.depth) - (y.height - shift_down)))
                if clr > 0.:
                    shift_up += clr
                    shift_down += clr
                if self.is_slanted(nucleus):
                    x.shift_amount = DELTA * (shift_up + shift_down)
                x = Vlist([x,
                           Kern((shift_up - x.depth) - (y.height - shift_down)),
                           y])
                x.shift_amount = shift_down

        result = Hlist([nucleus, x])
        return [result]

    def _genfrac(self, ldelim, rdelim, rule, style, num, den):
        state = self.get_state()
        thickness = state.font_output.get_underline_thickness(state.fontsize, state.dpi)

        rule = float(rule)
        num.shrink()
        den.shrink()
        cnum = HCentered([num])
        cden = HCentered([den])
        width = max(num.width, den.width)
        cnum.hpack(width, 'exactly')
        cden.hpack(width, 'exactly')
        vlist = Vlist([cnum,                      # numerator
                       Vbox(0, thickness * 2.0),  # space
                       Hrule(state, rule),        # rule
                       Vbox(0, thickness * 2.0),  # space
                       cden                       # denominator
                       ])

        # Shift so the fraction line sits in the middle of the
        # equals sign
        metrics = state.font_output.get_metrics(
            state.font, 'it',
            '=', state.fontsize, state.dpi)
        shift = (cden.height -
                 ((metrics.ymax + metrics.ymin) / 2 -
                  thickness * 3.0))
        vlist.shift_amount = shift

        result = [Hlist([vlist, Hbox(thickness * 2.)])]
        if ldelim or rdelim:
            if ldelim == '':
                ldelim = '.'
            if rdelim == '':
                rdelim = '.'
            elif rdelim == r'\}':
                rdelim = '}'
            return self._auto_sized_delimiter(ldelim, result, rdelim)
        return result

    def genfrac(self, s, loc, toks):
        assert(len(toks)==1)
        assert(len(toks[0])==6)

        return self._genfrac(*tuple(toks[0]))

    def frac(self, s, loc, toks):
        assert(len(toks)==1)
        assert(len(toks[0])==2)
        state = self.get_state()

        thickness = state.font_output.get_underline_thickness(state.fontsize, state.dpi)
        num, den = toks[0]

        return self._genfrac('', '', thickness, '', num, den)

    def stackrel(self, s, loc, toks):
        assert(len(toks)==1)
        assert(len(toks[0])==2)
        num, den = toks[0]

        return self._genfrac('', '', 0.0, '', num, den)

    def binom(self, s, loc, toks):
        assert(len(toks)==1)
        assert(len(toks[0])==2)
        num, den = toks[0]

        return self._genfrac('(', ')', 0.0, '', num, den)

    def sqrt(self, s, loc, toks):
        #~ print "sqrt", toks
        root, body = toks[0]
        state = self.get_state()
        thickness = state.font_output.get_underline_thickness(state.fontsize, state.dpi)

        # Determine the height of the body, and add a little extra to
        # the height so it doesn't seem cramped
        height = body.height - body.shift_amount + thickness * 5.0
        depth = body.depth + body.shift_amount
        check = AutoHeightChar(r'\__sqrt__', height, depth, state, always=True)
        height = check.height - check.shift_amount
        depth = check.depth + check.shift_amount

        # Put a little extra space to the left and right of the body
        padded_body = Hlist([Hbox(thickness * 2.0),
                             body,
                             Hbox(thickness * 2.0)])
        rightside = Vlist([Hrule(state),
                           Fill(),
                           padded_body])
        # Stretch the glue between the hrule and the body
        rightside.vpack(height + (state.fontsize * state.dpi) / (100.0 * 12.0),
                        depth, 'exactly')

        # Add the root and shift it upward so it is above the tick.
        # The value of 0.6 is a hard-coded hack ;)
        if root is None:
            root = Box(check.width * 0.5, 0., 0.)
        else:
            root = Hlist([Char(x, state) for x in root])
            root.shrink()
            root.shrink()

        root_vlist = Vlist([Hlist([root])])
        root_vlist.shift_amount = -height * 0.6

        hlist = Hlist([root_vlist,               # Root
                       # Negative kerning to put root over tick
                       Kern(-check.width * 0.5),
                       check,                    # Check
                       rightside])               # Body
        return [hlist]

    def _auto_sized_delimiter(self, front, middle, back):
        state = self.get_state()
        height = max([x.height for x in middle])
        depth = max([x.depth for x in middle])
        parts = []
        # \left. and \right. aren't supposed to produce any symbols
        if front != '.':
            parts.append(AutoHeightChar(front, height, depth, state))
        parts.extend(middle)
        if back != '.':
            parts.append(AutoHeightChar(back, height, depth, state))
        hlist = Hlist(parts)
        return hlist


    def auto_sized_delimiter(self, s, loc, toks):
        #~ print "auto_sized_delimiter", toks
        front, middle, back = toks

        return self._auto_sized_delimiter(front, middle.asList(), back)

tex2uni = {
    'widehat'                  : 0x0302,
    'widetilde'                : 0x0303,
    'widebar'                  : 0x0305,
    'langle'                   : 0x27e8,
    'rangle'                   : 0x27e9,
    'perp'                     : 0x27c2,
    'neq'                      : 0x2260,
    'Join'                     : 0x2a1d,
    'leqslant'                 : 0x2a7d,
    'geqslant'                 : 0x2a7e,
    'lessapprox'               : 0x2a85,
    'gtrapprox'                : 0x2a86,
    'lesseqqgtr'               : 0x2a8b,
    'gtreqqless'               : 0x2a8c,
    'triangleeq'               : 0x225c,
    'eqslantless'              : 0x2a95,
    'eqslantgtr'               : 0x2a96,
    'backepsilon'              : 0x03f6,
    'precapprox'               : 0x2ab7,
    'succapprox'               : 0x2ab8,
    'fallingdotseq'            : 0x2252,
    'subseteqq'                : 0x2ac5,
    'supseteqq'                : 0x2ac6,
    'varpropto'                : 0x221d,
    'precnapprox'              : 0x2ab9,
    'succnapprox'              : 0x2aba,
    'subsetneqq'               : 0x2acb,
    'supsetneqq'               : 0x2acc,
    'lnapprox'                 : 0x2ab9,
    'gnapprox'                 : 0x2aba,
    'longleftarrow'            : 0x27f5,
    'longrightarrow'           : 0x27f6,
    'longleftrightarrow'       : 0x27f7,
    'Longleftarrow'            : 0x27f8,
    'Longrightarrow'           : 0x27f9,
    'Longleftrightarrow'       : 0x27fa,
    'longmapsto'               : 0x27fc,
    'leadsto'                  : 0x21dd,
    'dashleftarrow'            : 0x290e,
    'dashrightarrow'           : 0x290f,
    'circlearrowleft'          : 0x21ba,
    'circlearrowright'         : 0x21bb,
    'leftrightsquigarrow'      : 0x21ad,
    'leftsquigarrow'           : 0x219c,
    'rightsquigarrow'          : 0x219d,
    'Game'                     : 0x2141,
    'hbar'                     : 0x0127,
    'hslash'                   : 0x210f,
    'ldots'                    : 0x2026,
    'vdots'                    : 0x22ee,
    'doteqdot'                 : 0x2251,
    'doteq'                    : 8784,
    'partial'                  : 8706,
    'gg'                       : 8811,
    'asymp'                    : 8781,
    'blacktriangledown'        : 9662,
    'otimes'                   : 8855,
    'nearrow'                  : 8599,
    'varpi'                    : 982,
    'vee'                      : 8744,
    'vec'                      : 8407,
    'smile'                    : 8995,
    'succnsim'                 : 8937,
    'gimel'                    : 8503,
    'vert'                     : 124,
    '|'                        : 124,
    'varrho'                   : 1009,
    'P'                        : 182,
    'approxident'              : 8779,
    'Swarrow'                  : 8665,
    'textasciicircum'          : 94,
    'imageof'                  : 8887,
    'ntriangleleft'            : 8938,
    'nleq'                     : 8816,
    'div'                      : 247,
    'nparallel'                : 8742,
    'Leftarrow'                : 8656,
    'lll'                      : 8920,
    'oiint'                    : 8751,
    'ngeq'                     : 8817,
    'Theta'                    : 920,
    'origof'                   : 8886,
    'blacksquare'              : 9632,
    'solbar'                   : 9023,
    'neg'                      : 172,
    'sum'                      : 8721,
    'Vdash'                    : 8873,
    'coloneq'                  : 8788,
    'degree'                   : 176,
    'bowtie'                   : 8904,
    'blacktriangleright'       : 9654,
    'varsigma'                 : 962,
    'leq'                      : 8804,
    'ggg'                      : 8921,
    'lneqq'                    : 8808,
    'scurel'                   : 8881,
    'stareq'                   : 8795,
    'BbbN'                     : 8469,
    'nLeftarrow'               : 8653,
    'nLeftrightarrow'          : 8654,
    'k'                        : 808,
    'bot'                      : 8869,
    'BbbC'                     : 8450,
    'Lsh'                      : 8624,
    'leftleftarrows'           : 8647,
    'BbbZ'                     : 8484,
    'digamma'                  : 989,
    'BbbR'                     : 8477,
    'BbbP'                     : 8473,
    'BbbQ'                     : 8474,
    'vartriangleright'         : 8883,
    'succsim'                  : 8831,
    'wedge'                    : 8743,
    'lessgtr'                  : 8822,
    'veebar'                   : 8891,
    'mapsdown'                 : 8615,
    'Rsh'                      : 8625,
    'chi'                      : 967,
    'prec'                     : 8826,
    'nsubseteq'                : 8840,
    'therefore'                : 8756,
    'eqcirc'                   : 8790,
    'textexclamdown'           : 161,
    'nRightarrow'              : 8655,
    'flat'                     : 9837,
    'notin'                    : 8713,
    'llcorner'                 : 8990,
    'varepsilon'               : 949,
    'bigtriangleup'            : 9651,
    'aleph'                    : 8501,
    'dotminus'                 : 8760,
    'upsilon'                  : 965,
    'Lambda'                   : 923,
    'cap'                      : 8745,
    'barleftarrow'             : 8676,
    'mu'                       : 956,
    'boxplus'                  : 8862,
    'mp'                       : 8723,
    'circledast'               : 8859,
    'tau'                      : 964,
    'in'                       : 8712,
    'backslash'                : 92,
    'varnothing'               : 8709,
    'sharp'                    : 9839,
    'eqsim'                    : 8770,
    'gnsim'                    : 8935,
    'Searrow'                  : 8664,
    'updownarrows'             : 8645,
    'heartsuit'                : 9825,
    'trianglelefteq'           : 8884,
    'ddag'                     : 8225,
    'sqsubseteq'               : 8849,
    'mapsfrom'                 : 8612,
    'boxbar'                   : 9707,
    'sim'                      : 8764,
    'Nwarrow'                  : 8662,
    'nequiv'                   : 8802,
    'succ'                     : 8827,
    'vdash'                    : 8866,
    'Leftrightarrow'           : 8660,
    'parallel'                 : 8741,
    'invnot'                   : 8976,
    'natural'                  : 9838,
    'ss'                       : 223,
    'uparrow'                  : 8593,
    'nsim'                     : 8769,
    'hookrightarrow'           : 8618,
    'Equiv'                    : 8803,
    'approx'                   : 8776,
    'Vvdash'                   : 8874,
    'nsucc'                    : 8833,
    'leftrightharpoons'        : 8651,
    'Re'                       : 8476,
    'boxminus'                 : 8863,
    'equiv'                    : 8801,
    'Lleftarrow'               : 8666,
    'thinspace'                : 8201,
    'll'                       : 8810,
    'Cup'                      : 8915,
    'measeq'                   : 8798,
    'upharpoonleft'            : 8639,
    'lq'                       : 8216,
    'Upsilon'                  : 933,
    'subsetneq'                : 8842,
    'greater'                  : 62,
    'supsetneq'                : 8843,
    'Cap'                      : 8914,
    'L'                        : 321,
    'spadesuit'                : 9824,
    'lrcorner'                 : 8991,
    'not'                      : 824,
    'bar'                      : 772,
    'rightharpoonaccent'       : 8401,
    'boxdot'                   : 8865,
    'l'                        : 322,
    'leftharpoondown'          : 8637,
    'bigcup'                   : 8899,
    'iint'                     : 8748,
    'bigwedge'                 : 8896,
    'downharpoonleft'          : 8643,
    'textasciitilde'           : 126,
    'subset'                   : 8834,
    'leqq'                     : 8806,
    'mapsup'                   : 8613,
    'nvDash'                   : 8877,
    'looparrowleft'            : 8619,
    'nless'                    : 8814,
    'rightarrowbar'            : 8677,
    'Vert'                     : 8214,
    'downdownarrows'           : 8650,
    'uplus'                    : 8846,
    'simeq'                    : 8771,
    'napprox'                  : 8777,
    'ast'                      : 8727,
    'twoheaduparrow'           : 8607,
    'doublebarwedge'           : 8966,
    'Sigma'                    : 931,
    'leftharpoonaccent'        : 8400,
    'ntrianglelefteq'          : 8940,
    'nexists'                  : 8708,
    'times'                    : 215,
    'measuredangle'            : 8737,
    'bumpeq'                   : 8783,
    'carriagereturn'           : 8629,
    'adots'                    : 8944,
    'checkmark'                : 10003,
    'lambda'                   : 955,
    'xi'                       : 958,
    'rbrace'                   : 125,
    'rbrack'                   : 93,
    'Nearrow'                  : 8663,
    'maltese'                  : 10016,
    'clubsuit'                 : 9827,
    'top'                      : 8868,
    'overarc'                  : 785,
    'varphi'                   : 966,
    'Delta'                    : 916,
    'iota'                     : 953,
    'nleftarrow'               : 8602,
    'candra'                   : 784,
    'supset'                   : 8835,
    'triangleleft'             : 9665,
    'gtreqless'                : 8923,
    'ntrianglerighteq'         : 8941,
    'quad'                     : 8195,
    'Xi'                       : 926,
    'gtrdot'                   : 8919,
    'leftthreetimes'           : 8907,
    'minus'                    : 8722,
    'preccurlyeq'              : 8828,
    'nleftrightarrow'          : 8622,
    'lambdabar'                : 411,
    'blacktriangle'            : 9652,
    'kernelcontraction'        : 8763,
    'Phi'                      : 934,
    'angle'                    : 8736,
    'spadesuitopen'            : 9828,
    'eqless'                   : 8924,
    'mid'                      : 8739,
    'varkappa'                 : 1008,
    'Ldsh'                     : 8626,
    'updownarrow'              : 8597,
    'beta'                     : 946,
    'textquotedblleft'         : 8220,
    'rho'                      : 961,
    'alpha'                    : 945,
    'intercal'                 : 8890,
    'beth'                     : 8502,
    'grave'                    : 768,
    'acwopencirclearrow'       : 8634,
    'nmid'                     : 8740,
    'nsupset'                  : 8837,
    'sigma'                    : 963,
    'dot'                      : 775,
    'Rightarrow'               : 8658,
    'turnednot'                : 8985,
    'backsimeq'                : 8909,
    'leftarrowtail'            : 8610,
    'approxeq'                 : 8778,
    'curlyeqsucc'              : 8927,
    'rightarrowtail'           : 8611,
    'Psi'                      : 936,
    'copyright'                : 169,
    'yen'                      : 165,
    'vartriangleleft'          : 8882,
    'rasp'                     : 700,
    'triangleright'            : 9655,
    'precsim'                  : 8830,
    'infty'                    : 8734,
    'geq'                      : 8805,
    'updownarrowbar'           : 8616,
    'precnsim'                 : 8936,
    'H'                        : 779,
    'ulcorner'                 : 8988,
    'looparrowright'           : 8620,
    'ncong'                    : 8775,
    'downarrow'                : 8595,
    'circeq'                   : 8791,
    'subseteq'                 : 8838,
    'bigstar'                  : 9733,
    'prime'                    : 8242,
    'lceil'                    : 8968,
    'Rrightarrow'              : 8667,
    'oiiint'                   : 8752,
    'curlywedge'               : 8911,
    'vDash'                    : 8872,
    'lfloor'                   : 8970,
    'ddots'                    : 8945,
    'exists'                   : 8707,
    'underbar'                 : 817,
    'Pi'                       : 928,
    'leftrightarrows'          : 8646,
    'sphericalangle'           : 8738,
    'coprod'                   : 8720,
    'circledcirc'              : 8858,
    'gtrsim'                   : 8819,
    'gneqq'                    : 8809,
    'between'                  : 8812,
    'theta'                    : 952,
    'complement'               : 8705,
    'arceq'                    : 8792,
    'nVdash'                   : 8878,
    'S'                        : 167,
    'wr'                       : 8768,
    'wp'                       : 8472,
    'backcong'                 : 8780,
    'lasp'                     : 701,
    'c'                        : 807,
    'nabla'                    : 8711,
    'dotplus'                  : 8724,
    'eta'                      : 951,
    'forall'                   : 8704,
    'eth'                      : 240,
    'colon'                    : 58,
    'sqcup'                    : 8852,
    'rightrightarrows'         : 8649,
    'sqsupset'                 : 8848,
    'mapsto'                   : 8614,
    'bigtriangledown'          : 9661,
    'sqsupseteq'               : 8850,
    'propto'                   : 8733,
    'pi'                       : 960,
    'pm'                       : 177,
    'dots'                     : 0x2026,
    'nrightarrow'              : 8603,
    'textasciiacute'           : 180,
    'Doteq'                    : 8785,
    'breve'                    : 774,
    'sqcap'                    : 8851,
    'twoheadrightarrow'        : 8608,
    'kappa'                    : 954,
    'vartriangle'              : 9653,
    'diamondsuit'              : 9826,
    'pitchfork'                : 8916,
    'blacktriangleleft'        : 9664,
    'nprec'                    : 8832,
    'vdots'                    : 8942,
    'curvearrowright'          : 8631,
    'barwedge'                 : 8892,
    'multimap'                 : 8888,
    'textquestiondown'         : 191,
    'cong'                     : 8773,
    'rtimes'                   : 8906,
    'rightzigzagarrow'         : 8669,
    'rightarrow'               : 8594,
    'leftarrow'                : 8592,
    '__sqrt__'                 : 8730,
    'twoheaddownarrow'         : 8609,
    'oint'                     : 8750,
    'bigvee'                   : 8897,
    'eqdef'                    : 8797,
    'sterling'                 : 163,
    'phi'                      : 981,
    'Updownarrow'              : 8661,
    'backprime'                : 8245,
    'emdash'                   : 8212,
    'Gamma'                    : 915,
    'i'                        : 305,
    'rceil'                    : 8969,
    'leftharpoonup'            : 8636,
    'Im'                       : 8465,
    'curvearrowleft'           : 8630,
    'wedgeq'                   : 8793,
    'fallingdotseq'            : 8786,
    'curlyeqprec'              : 8926,
    'questeq'                  : 8799,
    'less'                     : 60,
    'upuparrows'               : 8648,
    'tilde'                    : 771,
    'textasciigrave'           : 96,
    'smallsetminus'            : 8726,
    'ell'                      : 8467,
    'cup'                      : 8746,
    'danger'                   : 9761,
    'nVDash'                   : 8879,
    'cdotp'                    : 183,
    'cdots'                    : 8943,
    'hat'                      : 770,
    'eqgtr'                    : 8925,
    'enspace'                  : 8194,
    'psi'                      : 968,
    'frown'                    : 8994,
    'acute'                    : 769,
    'downzigzagarrow'          : 8623,
    'ntriangleright'           : 8939,
    'cupdot'                   : 8845,
    'circleddash'              : 8861,
    'oslash'                   : 8856,
    'mho'                      : 8487,
    'd'                        : 803,
    'sqsubset'                 : 8847,
    'cdot'                     : 8901,
    'Omega'                    : 937,
    'OE'                       : 338,
    'veeeq'                    : 8794,
    'Finv'                     : 8498,
    't'                        : 865,
    'leftrightarrow'           : 8596,
    'swarrow'                  : 8601,
    'rightthreetimes'          : 8908,
    'rightleftharpoons'        : 8652,
    'lesssim'                  : 8818,
    'searrow'                  : 8600,
    'because'                  : 8757,
    'gtrless'                  : 8823,
    'star'                     : 8902,
    'nsubset'                  : 8836,
    'zeta'                     : 950,
    'dddot'                    : 8411,
    'bigcirc'                  : 9675,
    'Supset'                   : 8913,
    'circ'                     : 8728,
    'slash'                    : 8725,
    'ocirc'                    : 778,
    'prod'                     : 8719,
    'twoheadleftarrow'         : 8606,
    'daleth'                   : 8504,
    'upharpoonright'           : 8638,
    'odot'                     : 8857,
    'Uparrow'                  : 8657,
    'O'                        : 216,
    'hookleftarrow'            : 8617,
    'trianglerighteq'          : 8885,
    'nsime'                    : 8772,
    'oe'                       : 339,
    'nwarrow'                  : 8598,
    'o'                        : 248,
    'ddddot'                   : 8412,
    'downharpoonright'         : 8642,
    'succcurlyeq'              : 8829,
    'gamma'                    : 947,
    'scrR'                     : 8475,
    'dag'                      : 8224,
    'thickspace'               : 8197,
    'frakZ'                    : 8488,
    'lessdot'                  : 8918,
    'triangledown'             : 9663,
    'ltimes'                   : 8905,
    'scrB'                     : 8492,
    'endash'                   : 8211,
    'scrE'                     : 8496,
    'scrF'                     : 8497,
    'scrH'                     : 8459,
    'scrI'                     : 8464,
    'rightharpoondown'         : 8641,
    'scrL'                     : 8466,
    'scrM'                     : 8499,
    'frakC'                    : 8493,
    'nsupseteq'                : 8841,
    'circledR'                 : 174,
    'circledS'                 : 9416,
    'ngtr'                     : 8815,
    'bigcap'                   : 8898,
    'scre'                     : 8495,
    'Downarrow'                : 8659,
    'scrg'                     : 8458,
    'overleftrightarrow'       : 8417,
    'scro'                     : 8500,
    'lnsim'                    : 8934,
    'eqcolon'                  : 8789,
    'curlyvee'                 : 8910,
    'urcorner'                 : 8989,
    'lbrace'                   : 123,
    'Bumpeq'                   : 8782,
    'delta'                    : 948,
    'boxtimes'                 : 8864,
    'overleftarrow'            : 8406,
    'prurel'                   : 8880,
    'clubsuitopen'             : 9831,
    'cwopencirclearrow'        : 8635,
    'geqq'                     : 8807,
    'rightleftarrows'          : 8644,
    'ac'                       : 8766,
    'ae'                       : 230,
    'int'                      : 8747,
    'rfloor'                   : 8971,
    'risingdotseq'             : 8787,
    'nvdash'                   : 8876,
    'diamond'                  : 8900,
    'ddot'                     : 776,
    'backsim'                  : 8765,
    'oplus'                    : 8853,
    'triangleq'                : 8796,
    'check'                    : 780,
    'ni'                       : 8715,
    'iiint'                    : 8749,
    'ne'                       : 8800,
    'lesseqgtr'                : 8922,
    'obar'                     : 9021,
    'supseteq'                 : 8839,
    'nu'                       : 957,
    'AA'                       : 8491,
    'AE'                       : 198,
    'models'                   : 8871,
    'ominus'                   : 8854,
    'dashv'                    : 8867,
    'omega'                    : 969,
    'rq'                       : 8217,
    'Subset'                   : 8912,
    'rightharpoonup'           : 8640,
    'Rdsh'                     : 8627,
    'bullet'                   : 8729,
    'divideontimes'            : 8903,
    'lbrack'                   : 91,
    'textquotedblright'        : 8221,
    'Colon'                    : 8759,
    '%'                        : 37,
    '$'                        : 36,
    '{'                        : 123,
    '}'                        : 125,
    '_'                        : 95,
    '#'                        : 35,
    'imath'                    : 0x131,
    'circumflexaccent'         : 770,
    'combiningbreve'           : 774,
    'combiningoverline'        : 772,
    'combininggraveaccent'     : 768,
    'combiningacuteaccent'     : 769,
    'combiningdiaeresis'       : 776,
    'combiningtilde'           : 771,
    'combiningrightarrowabove' : 8407,
    'combiningdotabove'        : 775,
    'to'                       : 8594,
    'succeq'                   : 8829,
    'emptyset'                 : 8709,
    'leftparen'                : 40,
    'rightparen'               : 41,
    'bigoplus'                 : 10753,
    'leftangle'                : 10216,
    'rightangle'               : 10217,
    'leftbrace'                : 124,
    'rightbrace'               : 125,
    'jmath'                    : 567,
    'bigodot'                  : 10752,
    'preceq'                   : 8828,
    'biguplus'                 : 10756,
    'epsilon'                  : 949,
    'vartheta'                 : 977,
    'bigotimes'                : 10754
}