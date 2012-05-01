cdef class Menu_(Widget):
    cpdef int add(self, char *label, int shortcut = 0, object cb = None, object data = None, int flags = 0):
        cdef Fl_Menu_ *menu = <Fl_Menu_ *>self.thisptr
        cdef int idx
        if not cb is None:
            cb_data = (self, cb, data)
            idx = menu.add(label, shortcut, <Fl_Callback_p>Widget_callback, <void *>cb_data, flags)
            self.cb_data[idx] = cb_data
        else:
            idx = menu.add(label, shortcut, NULL, NULL, flags)
        
        return idx
    
    def value(self, *args):
        cdef Fl_Menu_ *menu = <Fl_Menu_ *>self.thisptr
        
        if len(args) == 0:
            return menu.value()
        elif len(args) == 1:
            menu.value(args[0])
        else:
            msg = 'value() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef int get_value(self):
        cdef Fl_Menu_ *menu = <Fl_Menu_ *>self.thisptr
        return menu.value()
    
    cpdef int set_value(self, int v):
        cdef Fl_Menu_ *menu = <Fl_Menu_ *>self.thisptr
        return menu.value(v)
        
cdef class Menu_Bar(Menu_):
    def __init__(self, int X, int Y, int W, int H, char *l = NULL):
        self.thisptr = new Fl_Menu_Bar(X, Y, W, H, l)
        self.cb_data = {}
        
        # This object is owned by parent class
        Py_INCREF(self)

cdef class Menu_Button(Menu_):
    def __init__(self, int X, int Y, int W, int H, char *l = NULL):
        self.thisptr = new Fl_Menu_Button(X, Y, W, H, l)
        self.cb_data = {}
        
        # This object is owned by parent class
        Py_INCREF(self)

cdef class Choice(Menu_):
    def __init__(self, int X, int Y, int W, int H, char *l = NULL):
        self.thisptr = new Fl_Choice(X, Y, W, H, l)
        self.cb_data = {}
        
        # This object is owned by parent class
        Py_INCREF(self)