cdef class Text_Buffer:
    cdef void *thisptr
    
    def __init__(self, int requestedSize = 0, int preferredGapSize = 1024):
        self.thisptr = new Fl_Text_Buffer(requestedSize,preferredGapSize)
        
        # This object is owned by parent class
        Py_INCREF(self)
            
    def __dealloc__(self):
        cdef Fl_Text_Buffer *tmp
        
        if self.thisptr != NULL:
            tmp = <Fl_Text_Buffer *>self.thisptr
            del tmp
    
    cpdef int length(self):
        cdef Fl_Text_Buffer *buffer = <Fl_Text_Buffer *>self.thisptr
        return buffer.length()
    
    cpdef insert(self, int pos, char *text):
        cdef Fl_Text_Buffer *buffer = <Fl_Text_Buffer *>self.thisptr
        buffer.insert(pos, text)
        
    cpdef append(self, char *text):
        cdef Fl_Text_Buffer *buffer = <Fl_Text_Buffer *>self.thisptr
        buffer.append(text)
    
    cpdef int loadfile(self, char *file, int buflen = 128*1024):
        cdef Fl_Text_Buffer *buffer = <Fl_Text_Buffer *>self.thisptr
        return buffer.loadfile(file, buflen)
    
    cpdef text(self, char *text = NULL):
        cdef Fl_Text_Buffer *buffer = <Fl_Text_Buffer *>self.thisptr
        if not text is NULL:
            buffer.text(text)
        else:
            return buffer.text()
        
cdef class Text_Display(Group):
    def __init__(self, int x, int y, int w, int h, char* label = NULL):
        self.thisptr = new Fl_Text_Display(x, y, w, h, label)
        
        # This object is owned by parent class
        Py_INCREF(self)
            
    cpdef buffer(self, Text_Buffer buffer):
        '''
        Sets the current text buffer.
        '''
        cdef Fl_Text_Display *widget = <Fl_Text_Display *>self.thisptr
        widget.buffer(<Fl_Text_Buffer *>buffer.thisptr)
    
    def textfont(self, *args):
        cdef Fl_Text_Display *widget = <Fl_Text_Display *>self.thisptr
        
        if len(args) == 0:
            return widget.textfont()
        elif len(args) == 1:
            widget.textfont(args[0])
        else:
            msg = 'textfont() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef Fl_Font get_textfont(self):
        '''
        Gets the font of the text.
        '''
        cdef Fl_Text_Display *widget = <Fl_Text_Display *>self.thisptr
        return widget.textfont()
        
    cpdef set_textfont(self, Fl_Font f):
        '''
        Sets the font of the text.
        '''
        cdef Fl_Text_Display *widget = <Fl_Text_Display *>self.thisptr
        widget.textfont(f)
    
    def textsize(self, *args):
        cdef Fl_Text_Display *widget = <Fl_Text_Display *>self.thisptr
        
        if len(args) == 0:
            return widget.textsize()
        elif len(args) == 1:
            widget.textsize(args[0])
        else:
            msg = 'textsize() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef Fl_Fontsize get_textsize(self):
        '''
        Gets the size of the text.
        '''
        cdef Fl_Text_Display *widget = <Fl_Text_Display *>self.thisptr
        return widget.textsize()
        
    cpdef set_textsize(self, Fl_Fontsize pix):
        '''
        Sets the size of the text.
        '''
        cdef Fl_Text_Display *widget = <Fl_Text_Display *>self.thisptr
        widget.textsize(pix)
    
    def textcolor(self, *args):
        cdef Fl_Text_Display *widget = <Fl_Text_Display *>self.thisptr
        
        if len(args) == 0:
            return widget.textcolor()
        elif len(args) == 1:
            widget.textcolor(args[0])
        else:
            msg = 'textcolor() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef Fl_Color get_textcolor(self):
        '''
        Gets the color of the text.
        '''
        cdef Fl_Text_Display *widget = <Fl_Text_Display *>self.thisptr
        return widget.textcolor()
        
    cpdef set_textcolor(self, Fl_Color c):
        '''
        sets the color of the text.
        '''
        cdef Fl_Text_Display *widget = <Fl_Text_Display *>self.thisptr
        widget.textcolor(c)
    
    def cursor_color(self, *args):
        cdef Fl_Text_Display *widget = <Fl_Text_Display *>self.thisptr
        
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
        cdef Fl_Text_Display *widget = <Fl_Text_Display *>self.thisptr
        return widget.cursor_color()
        
    cpdef set_cursor_color(self, Fl_Color c):
        '''
        Sets the color of the cursor.
        '''
        cdef Fl_Text_Display *widget = <Fl_Text_Display *>self.thisptr
        widget.cursor_color(c)

cdef Fl_Image *Help_View_callback(Fl_Widget *widget, object data, char *name):
    '''
    Callback wrapper
    '''
    cdef Image img, cpy
    cdef Fl_Image *c_img
    cdef Help_View self
    cdef bint update = False
    
    self, py_callback, py_data = data
    
    if name.endswith('/'):
        ret = py_callback(self, py_data, name[:len(name) - 1])
    else:
        ret = py_callback(self, py_data, name)
    
    if PyErr_Occurred():
        PyErr_Print()
        
    if ret is None:
        return NULL
    else:
        img = ret
        
    if name not in self.img_org:
        update = True
    elif self.img_org[name] != ret:
        update = True
    
    if update:
        self.img_org[name] = ret
        
        cpy = Image.__new__(Image, None)
        c_img = (<Fl_Image *>img.thisptr).copy()
        cpy.thisptr = c_img
        self.img_cpy[name] = cpy
    else:
        cpy = self.img_cpy[name]
        c_img = <Fl_Image *>cpy.thisptr
    
    return c_img
    
cdef class Help_View(Group):
    cdef dict img_org
    cdef dict img_cpy
    
    def __init__(self, int xx, int yy, int ww, int hh, char *l = NULL):
        self.thisptr = new Fl_Help_View(xx,yy,ww,hh,l)
        
        self.img_org = {}
        self.img_cpy = {}
    
        # This object is owned by parent class
        Py_INCREF(self)
    
    cpdef callback(self, cb, data=None):
        '''
        Sets the callback for missing images
        
        Each widget has a single callback.
         * cb : new callback
         * data : user data passed to callback
        '''
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        self.cb_data = (self, cb, data)
        #widget.image_callback(<Fl_Image_Callback_p>Help_View_callback)
        #widget.image_callback(<Fl_Callback_p>Help_View_callback)
        widget.callback(<Fl_Callback_p>Help_View_callback)
        widget.user_data(<void *>self.cb_data)
    
    def value(self, *args):
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        
        if len(args) == 0:
            return widget.value()
        elif len(args) == 1:
            widget.value(args[0])
        else:
            msg = 'value() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef get_value(self):
        '''
        Returns the current content.
        '''
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        return widget.value()
    
    cpdef set_value(self, char *text):
        '''
        Sets the current content
        '''
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        widget.value(text)
    
    def textfont(self, *args):
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        
        if len(args) == 0:
            return widget.textfont()
        elif len(args) == 1:
            widget.textfont(args[0])
        else:
            msg = 'textfont() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef Fl_Font get_textfont(self):
        '''
        Gets the font of the text.
        '''
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        return widget.textfont()
        
    cpdef set_textfont(self, Fl_Font f):
        '''
        Sets the font of the text.
        '''
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        widget.textfont(f)
    
    def textsize(self, *args):
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        
        if len(args) == 0:
            return widget.textsize()
        elif len(args) == 1:
            widget.textsize(args[0])
        else:
            msg = 'textsize() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef Fl_Fontsize get_textsize(self):
        '''
        Gets the size of the text.
        '''
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        return widget.textsize()
        
    cpdef set_textsize(self, Fl_Fontsize pix):
        '''
        Sets the size of the text.
        '''
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        widget.textsize(pix)
    
    def textcolor(self, *args):
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        
        if len(args) == 0:
            return widget.textcolor()
        elif len(args) == 1:
            widget.textcolor(args[0])
        else:
            msg = 'textcolor() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef Fl_Color get_textcolor(self):
        '''
        Gets the color of the text.
        '''
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        return widget.textcolor()
        
    cpdef set_textcolor(self, Fl_Color c):
        '''
        sets the color of the text.
        '''
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        widget.textcolor(c)
    
    cpdef title(self):
        '''
        Gets the title of document
        '''
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        return widget.title()
    
    def topline(self, *args):
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        
        if len(args) == 0:
            return widget.topline()
        elif len(args) == 1:
            widget.topline(<int>args[0])
        else:
            msg = 'topline() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef int get_topline(self):
        '''
        Gets the topline distance in pixels
        '''
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        return widget.topline()
        
    cpdef set_topline(self, int px):
        '''
        Sets the topline distance in pixels
        '''
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        widget.topline(px)
    
    def leftline(self, *args):
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        
        if len(args) == 0:
            return widget.leftline()
        elif len(args) == 1:
            widget.leftline(args[0])
        else:
            msg = 'leftline() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef int get_leftline(self):
        '''
        Gets the leftline distance in pixels
        '''
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        return widget.leftline()
        
    cpdef set_leftline(self, int px):
        '''
        Sets the leftline distance in pixels
        '''
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        widget.leftline(px)
    
    cpdef clear_selection(self):
        '''
        Clear selection.
        '''
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        widget.clear_selection()
    
    cpdef select_all(self):
        '''
        Selects all content.
        '''
        cdef Fl_Help_View *widget = <Fl_Help_View *>self.thisptr
        widget.select_all()
