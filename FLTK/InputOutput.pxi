cdef class Input_(Widget):
    
    def value(self, *args):
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        
        if len(args) == 0:
            return widget.value()
        elif len(args) == 1:
            return widget.value(args[0])
        elif len(args) == 2:
            return widget.value(args[0], args[1])
        else:
            msg = 'value() takes at most two argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef get_value(self):
        '''
        Returns the text displayed in the widget.
        
        This function returns the current value, which is a pointer
        to the internal buffer and is valid only until the next event is
        handled.
        '''
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        return widget.value()
        
    cpdef int set_value(self, char *text, int i = -1):
        '''
        Changes the widget text.
        '''
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        if i == -1:
            return widget.value(text)
        else:
            return widget.value(text, i)
    
    def static_value(self, *args):
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        
        if len(args) == 1:
            return widget.static_value(args[0])
        elif len(args) == 2:
            return widget.static_value(args[0], args[1])
        else:
            msg = 'static_value() takes one or two argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef int set_static_value(self, char *text, int i = -1):
        '''
        Changes the widget text.
        '''
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        if i == -1:
            return widget.static_value(text)
        else:
            return widget.static_value(text, i)
    
    cpdef Fl_Char index(self, int i):
        '''
        Returns the character at index i.
        '''
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        return widget.index(i)
    
    cpdef int count(self):
        '''
        Returns the number of bytes in value(). 
        
        This may be greater than 'strlen(value())' if there are 
        nul characters in the text.
        '''
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        return widget.size()
    
    cpdef int cut(self):
        '''
        Deletes the current selection.

        This function deletes the currently selected text
        without storing it in the clipboard. To use the clipboard,
        you may call copy() first or copy_cuts() after
        this call.
        '''
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        return widget.cut()
    
    cpdef int copy(self, int clipboard):
        '''
        Put the current selection into the clipboard.
        '''
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        return widget.copy(clipboard)
    
    cpdef int undo(self):
        '''
        Undo previous changes to the text buffer.
        '''
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        return widget.undo()
    
    def textfont(self, *args):
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        
        if len(args) == 0:
            return widget.textfont()
        elif len(args) == 1:
            widget.textfont(args[0])
        else:
            msg = 'textfont() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef Fl_Font get_textfont(self):
        '''
        Gets the font of the text in the input field.
        '''
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        return widget.textfont()
        
    cpdef set_textfont(self, Fl_Font f):
        '''
        Sets the font of the text in the input field.
        The text font defaults to FL_HELVETICA.
        '''
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        widget.textfont(f)
    
    def textsize(self, *args):
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        
        if len(args) == 0:
            return widget.textsize()
        elif len(args) == 1:
            widget.textsize(args[0])
        else:
            msg = 'textsize() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef Fl_Fontsize get_textsize(self):
        '''
        Gets the size of the text in the input field.
        '''
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        return widget.textsize()
        
    cpdef set_textsize(self, Fl_Fontsize pix):
        '''
        Sets the size of the text in the input field.
        The text height defaults to FL_NORMAL_SIZE.
        '''
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        widget.textsize(pix)
    
    def textcolor(self, *args):
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        
        if len(args) == 0:
            return widget.textcolor()
        elif len(args) == 1:
            widget.textcolor(args[0])
        else:
            msg = 'textcolor() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef Fl_Color get_textcolor(self):
        '''
        Gets the color of the text in the input field.
        '''
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        return widget.textcolor()
        
    cpdef set_textcolor(self, Fl_Color c):
        '''
        ets the color of the text in the input field.
        The text color defaults to FL_FOREGROUND_COLOR.
        '''
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        widget.textcolor(c)
    
    def cursor_color(self, *args):
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        
        if len(args) == 0:
            return widget.cursor_color()
        elif len(args) == 1:
            widget.cursor_color(args[0])
        else:
            msg = 'cursor_color() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef Fl_Color get_cursor_color(self):
        '''
        Gets the color of the cursor.
        '''
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        return widget.cursor_color()
        
    cpdef set_cursor_color(self, Fl_Color c):
        '''
        Sets the color of the cursor.
        '''
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        widget.cursor_color(c)
    
    def readonly(self, *args):
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        
        if len(args) == 0:
            return widget._readonly()
        elif len(args) == 1:
            widget._readonly(args[0])
        else:
            msg = 'readonly() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef int get_readonly(self):
        '''
        Gets the read-only state of the input field.
        '''
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        return widget._readonly()
    
    cpdef set_readonly(self, int b):
        '''
        Sets the read-only state of the input field.
        '''
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        widget._readonly(b)
    
    cpdef int get_wrap(self):
        '''
        Gets  the word wrapping state of the input field. 
        Word wrap is only functional with multi-line input fields.
        '''
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        return widget.wrap()
    
    cpdef set_wrap(self, int b):
        '''
        Sets the word wrapping state of the input field. 
        Word wrap is only functional with multi-line input fields.
        '''
        cdef Fl_Input_ *widget = <Fl_Input_ *>self.thisptr
        widget.wrap(b)

cdef class Input(Input_):
    '''
    This is the FLTK text input widget. It displays a single line
    of text and lets the user edit it. Normally it is drawn with an
    inset box and a white background. The text may contain any
    characters, and will correctly display any UTF text, using
    ^X notation for unprintable control characters. It assumes the
    font can draw any characters of the used scripts, which is true
    for standard fonts under MSWindows and Mac OS X.
    Characters can be input using the keyboard or the character palette/map.
    Character composition is done using dead keys and/or a compose
    key as defined by the operating system.
    '''
    def __init__(self, int X, int Y, int W, int H, char* L = NULL):
        self.thisptr = new Fl_Input(X, Y, W, H, L)
        
        # This object is owned by parent class
        Py_INCREF(self)
            
cdef class Float_Input(Input):
    '''
    The Fl_Float_Input class is a subclass of Fl_Input
    that only allows the user to type floating point numbers (sign,
    digits, decimal point, more digits, 'E' or 'e', sign, digits).
    '''
    def __init__(self, int X, int Y, int W, int H, char* L = NULL):
        self.thisptr = new Fl_Float_Input(X, Y, W, H, L)
        
        # This object is owned by parent class
        Py_INCREF(self)
            
cdef class Int_Input(Input):
    '''
    The Fl_Int_Input class is a subclass of Fl_Input
    that only allows the user to type decimal digits (or hex numbers of the form 0xaef).
    '''
    def __init__(self, int X, int Y, int W, int H, char* L = NULL):
        self.thisptr = new Fl_Int_Input(X, Y, W, H, L)
        
        # This object is owned by parent class
        Py_INCREF(self)
            
cdef class Multiline_Input(Input):
    '''
    This input field displays '\n' characters as new lines rather than ^J,
    and accepts the Return, Tab, and up and down arrow keys.  This is for
    editing multiline text.

    This is far from the nirvana of text editors, and is probably only
    good for small bits of text, 10 lines at most. Note that this widget
    does not support scrollbars or per-character color control.

    If you are presenting large amounts of text and need scrollbars
    or full color control of characters, you probably want Fl_Text_Editor
    instead.
    '''
    def __init__(self, int X, int Y, int W, int H, char* L = NULL):
        self.thisptr = new Fl_Multiline_Input(X, Y, W, H, L)
        
        # This object is owned by parent class
        Py_INCREF(self)
            
cdef class Output(Input):
    '''
    This widget displays a piece of text.  When you set the value()
    , Fl_Output does a strcpy() to it's own storage,
    which is useful for program-generated values.  The user may select
    portions of the text using the mouse and paste the contents into other
    fields or programs.
    '''
    def __init__(self, int X, int Y, int W, int H, char* L = NULL):
        self.thisptr = new Fl_Output(X, Y, W, H, L)
        
        # This object is owned by parent class
        Py_INCREF(self)
            
cdef class Multiline_Output(Output):
    '''
    This widget is a subclass of Fl_Output that displays multiple
    lines of text. It also displays tab characters as whitespace to the
    next column.

    Note that this widget does not support scrollbars, or per-character
    color control.

    If you are presenting large amounts of read-only text 
    and need scrollbars, or full color control of characters,
    then use Fl_Text_Display. If you want to display HTML text,
    use Fl_Help_View.
    '''
    def __init__(self, int X, int Y, int W, int H, char* L = NULL):
        self.thisptr = new Fl_Multiline_Output(X, Y, W, H, L)
        
        # This object is owned by parent class
        Py_INCREF(self)