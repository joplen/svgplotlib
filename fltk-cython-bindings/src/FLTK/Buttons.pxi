cdef class Button(Widget):
    def __init__(self, int X, int Y, int W, int H, char* L = NULL):
        self.thisptr = new Fl_Button(X, Y, W, H, L)
        
        # This object is owned by parent class
        Py_INCREF(self)
    
    def value(self, *args):
        cdef Fl_Button *button = <Fl_Button *>self.thisptr
        
        if len(args) == 0:
            return button.value()
        elif len(args) == 1:
            return button.value(args[0])
        else:
            msg = 'value() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef char get_value(self):
        '''
        Returns the current value of the button (0 or 1).
        '''
        cdef Fl_Button *button = <Fl_Button *>self.thisptr
        return button.value()
    
    cpdef int set_value(self, int v):
        '''
        Sets the current value of the button (0 or 1).
        '''
        cdef Fl_Button *button = <Fl_Button *>self.thisptr
        return button.value(v)
        
    cpdef int set(self):
        '''
        Same as \c value(1).
        '''
        cdef Fl_Button *button = <Fl_Button *>self.thisptr
        return button.set()
    
    cpdef int clear(self, int v):
        '''
        Same as value(0).
        '''
        cdef Fl_Button *button = <Fl_Button *>self.thisptr
        return button.clear()
    
    cpdef setonly(self, int v):
        '''
        this should only be called on FL_RADIO_BUTTONs
        '''
        cdef Fl_Button *button = <Fl_Button *>self.thisptr
        button.setonly()
    
    def shortcut(self, *args):
        cdef Fl_Button *button = <Fl_Button *>self.thisptr
        
        if len(args) == 0:
            return button.shortcut()
        elif len(args) == 1:
            button.shortcut(args[0])
        else:
            msg = 'value() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef int get_shortcut(self):
        '''
        Returns the current shortcut key for the button.
        '''
        cdef Fl_Button *button = <Fl_Button *>self.thisptr
        button.shortcut()
        
    cpdef set_shortcut(self, int s):
        '''
        Sets the shortcut key to \c s.
        Setting this overrides the use of '\&' in the label().
        The value is a bitwise OR of a key and a set of shift flags, for example::
            FL_ALT | 'a', or
            FL_ALT | (FL_F + 10), or just
            'a'
            
        A value of 0 disables the shortcut.
        
        The key can be any value returned by Fl::event_key(), but will usually be
        an ASCII letter.  Use a lower-case letter unless you require the shift key
        to be held down.
        
        The shift flags can be any set of values accepted by Fl::event_state().
        If the bit is on, that shift key must be pushed.  Meta, Alt, Ctrl, and
        Shift must be off if they are not in the shift flags (zero for the other
        bits indicates a "don't care" setting).
        '''
        cdef Fl_Button *button = <Fl_Button *>self.thisptr
        button.shortcut(s)

cdef class Check_Button(Button):
    def __init__(self, int X, int Y, int W, int H, char* L = NULL):
        self.thisptr = new Fl_Check_Button(X, Y, W, H, L)
        
        # This object is owned by parent class
        Py_INCREF(self)