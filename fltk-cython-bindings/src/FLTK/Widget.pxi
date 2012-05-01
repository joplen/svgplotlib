# -*- coding: utf-8 -*-
cdef Widget_callback(Fl_Widget *widget, object data):
    '''
    Callback wrapper
    '''
    py_widget, py_callback, py_data = data
    py_callback(py_widget, py_data)
    
    if PyErr_Occurred():
        PyErr_Print()

cdef public Widget_ext_callback(Fl_Widget *widget, object py_data, char *cmd, int *data):
    '''
    Callback wrapper
    '''
    cdef Widget self = py_data
    cdef int ret
    
    if cmd == b'draw':
        self.draw()
    elif cmd == b'handle':
        ret = self.handle(data[0])
        data[0] = ret
    
    if PyErr_Occurred():
        PyErr_Print()
    
cdef class Widget:
    '''
    Fl_Widget is the base class for all widgets in FLTK.  
  
    You can't create one of these because the constructor is not public.
    However you can subclass it.  

    All "property" accessing methods, such as color(), parent(), or argument() 
    are implemented as trivial inline functions and thus are as fast and small 
    as accessing fields in a structure. Unless otherwise noted, the property 
    setting methods such as color(n) or label(s) are also trivial inline 
    functions, even if they change the widget's appearance. It is up to the 
    user code to call redraw() after these.
    '''
    cdef void *thisptr
    cdef object cb_data
    
    def __init__(self, int x, int y, int w, int h, char* label = NULL):
        self.thisptr = new Fl_Widget_(x, y, w, h, label, <void *>self)
        
        # This object is owned by parent class
        Py_INCREF(self)
        
    cpdef int x(self):
        '''
        Gets the widget position in its window.
        return the x position relative to the window.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        return widget.x()
    
    cpdef int y(self):
        '''
        Gets the widget position in its window.
        return the y position relative to the window.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        return widget.y()
    
    cpdef int w(self):
        '''
        Gets the widget width.
        return the width of the widget in pixels.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        return widget.w()
    
    cpdef int h(self):
        '''
        Gets the widget height.
        return the height of the widget in pixels.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        return widget.h()
    
    cpdef draw(self):
        '''
        Draws the widget.
        Never call this function directly. FLTK will schedule redrawing whenever
        needed. If your widget must be redrawn as soon as possible, call redraw()
        instead.

        Override this function to draw your own widgets.
        '''
        pass
    
    cpdef int handle(self, int event):
        '''
        Handles the specified event. 
        You normally don't call this method directly, but instead let FLTK do 
        it when the user interacts with the widget.

        When implemented in a widget, this function must return 0 if the 
        widget does not use the event or 1 otherwise.

        Most of the time, you want to call the inherited handle() method in 
        your overridden method so that you don't short-circuit events that you 
        don't handle. In this last case you should return the callee retval.

         * event : the kind of event received
         * return 0 if the event was not used or understood
         * return 1 if the event was used and can be deleted
        '''
        pass
    
    def when(self, *args):
        '''
        Returns the conditions under which the callback is called.
        
        You can set the flags with when(uchar), the default value is FL_WHEN_RELEASE.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        
        if len(args) == 0:
            return widget.when()
        elif len(args) == 1:
            widget.when(args[0])
        else:
            msg = 'when() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef Fl_When get_when(self):
        '''
        Returns the conditions under which the callback is called.
        
        You can set the flags with when(uchar), the default value is
        FL_WHEN_RELEASE.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        return widget.when()
    
    cpdef set_when(self, uchar i):
        '''
        Sets the flags used to decide when a callback is called.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.when(i)
            
    cpdef int changed(self):
        '''
        Checks if the widget value changed since the last callback.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        return widget.changed()
    
    cpdef set_changed(self):
        '''
        Marks the value of the widget as changed.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.set_changed()
        
    cpdef clear_changed(self):
        '''
        Marks the value of the widget as unchanged.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.clear_changed()
        
    cpdef resize(self, int x, int y, int w, int h):
        '''
        Changes the size or position of the widget.

        This is a virtual function so that the widget may implement its 
        own handling of resizing. The default version does \e not
        call the redraw() method, but instead relies on the parent widget 
        to do so because the parent may know a faster way to update the 
        display, such as scrolling from the old position.  

        Some window managers under X11 call resize() a lot more often 
        than needed. Please verify that the position or size of a widget 
        did actually change before doing any extensive calculations.

        position(X, Y) is a shortcut for resize(X, Y, w(), h()), 
        and size(W, H) is a shortcut for resize(x(), y(), W, H).

         * x, y new position relative to the parent window 
         * w, h new size
        
        see : position(int,int), size(int,int)
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.resize(x,y,w,h)
    
    cpdef position(self, int x, int y):
        '''
        Repositions the window or widget.

        position(X, Y) is a shortcut for resize(X, Y, w(), h()).

         * X, Y new position relative to the parent window
         
        see: resize(int,int,int,int), size(int,int)
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.position(x,y)
    
    cpdef size(self, int w, int h):
        '''
        Changes the size of the widget.

        size(W, H) is a shortcut for resize(x(), y(), W, H).
    
         * W, H new size
         
        see: position(int,int), resize(int,int,int,int)
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.size(w,h)
        
    cpdef show(self):
        '''
        Makes a widget visible.
        An invisible widget never gets redrawn and does not get events.  
        The visible() method returns true if the widget is set to be  
        visible. The visible_r() method returns true if the widget and 
        all of its parents are visible. A widget is only visible if 
        visible() is true on it *and all of its parents*. 

        Changing it will send FL_SHOW or FL_HIDE events to 
        the widget. *Do not change it if the parent is not visible, as this 
        will send false FL_SHOW or FL_HIDE events to the widget*.
        redraw() is called if necessary on this or the parent.

        see: hide(), visible(), visible_r()
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.show()
    
    cpdef hide(self):
        '''
        Makes a widget invisible.
        
        see: show(), visible(), visible_r()
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.hide()
    
    cpdef int visible(self):
        '''
        Returns whether a widget is visible.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        return widget.visible()
    
    cpdef int visible_r(self):
        '''
        Returns whether a widget and all its parents are visible.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        return widget.visible_r()
    
    cpdef int active(self):
        '''
        Returns whether the widget is active.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        return widget.active()
    
    cpdef int active_r(self):
        '''
        Returns whether the widget and all of its parents are active.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        return widget.active_r()
    
    cpdef activate(self):
        '''
        Activates the widget.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.activate()
    
    cpdef deactivate(self):
        '''
        Deactivates the widget.
        Inactive widgets will be drawn "grayed out", e.g. with less contrast 
        than the active widget. Inactive widgets will not receive any keyboard 
        or mouse button events. Other events (including FL_ENTER, FL_MOVE, 
        FL_LEAVE, FL_SHORTCUT, and others) will still be sent. A widget is 
        only active if active() is true on it <I>and all of its parents</I>.  

        Changing this value will send FL_DEACTIVATE to the widget if 
        active_r() is true.

        Currently you cannot deactivate Fl_Window widgets.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.deactivate()
    
    cpdef redraw(self):
        '''
        Schedules the drawing of the widget.
        Marks the widget as needing its draw() routine called.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.redraw()
    
    def callback(self, *args):
        '''
        Sets the current callback function for the widget.
        
        Each widget has a single callback.
         * cb : new callback
         * data : user data passed to callback
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        
        if len(args) == 1:
            self.cb_data = (self, args[0], None)
            widget.callback(<Fl_Callback_p>Widget_callback, <void *>self.cb_data)
        elif len(args) == 2:
            self.cb_data = (self, args[0], args[1])
            widget.callback(<Fl_Callback_p>Widget_callback, <void *>self.cb_data)
        else:
            msg = 'callback() takes one or two arguments (%d given)'
            raise TypeError(msg % len(args))
    
    def color(self, *args):
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        
        if len(args) == 0:
            return widget.color()
        elif len(args) == 1:
            widget.color(args[0])
        else:
            msg = 'color() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef Fl_Color get_color(self):
        '''
        Gets the background color of the widget.
        return current background color
        
        see: set_color(Fl_Color)
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        return widget.color()
        
    cpdef set_color(self, Fl_Color bg):
        '''
        Sets the background color of the widget. 
        The color is passed to the box routine. The color is either an index into 
        an internal table of RGB colors or an RGB color value generated using 
        fl_rgb_color().

        The default for most widgets is FL_BACKGROUND_COLOR. Use Fl::set_color()
        to redefine colors in the color map.
        
         * bg background color
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.color(bg)
    
    def selection_color(self, *args):
        '''
        Sets the selection color.

        The selection color is defined for Forms compatibility and is usually 
        used to color the widget when it is selected, although some widgets use 
        this color for other purposes. You can set both colors at once with 
        color(Fl_Color bg, Fl_Color sel).

        Parameters:
        [in] 	a 	the new selection color
        See also:
        selection_color(), color(Fl_Color, Fl_Color)
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        
        if len(args) == 0:
            return widget.selection_color()
        elif len(args) == 1:
            widget.selection_color(args[0])
        else:
            msg = 'selection_color() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef Fl_Color get_selection_color(self):
        '''
        Gets the selection color.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        return widget.selection_color()
        
    cpdef set_selection_color(self, Fl_Color a):
        '''
        Sets the selection color.
        The selection color is defined for Forms compatibility and is usually 
        used to color the widget when it is selected, although some widgets 
        use this color for other purposes.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.selection_color(a)
    
    def box(self, *args):
        '''
        Sets the box type for the widget.

        This identifies a routine that draws the background of the widget. See 
        Fl_Boxtype for the available types. The default depends on the widget,
        but is usually FL_NO_BOX or FL_UP_BOX.

        Parameters:
        [in] 	new_box 	the new box type
        
        See also:
        box(), Fl_Boxtype
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        
        if len(args) == 0:
            return widget.box()
        elif len(args) == 1:
            widget.box(args[0])
        else:
            msg = 'box() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef Fl_Boxtype get_box(self):
        '''
        Gets the box type of the widget.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        return widget.box()
        
    cpdef set_box(self, Fl_Boxtype new_box):
        '''
        Sets the box type for the widget.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.box(new_box)
    
    def label(self, *args):
        '''
        Sets the current label pointer.

        The label is shown somewhere on or next to the widget. The passed 
        pointer is stored unchanged in the widget (the string is not copied), 
        so if you need to set the label to a formatted value, make sure the 
        buffer is static, global, or allocated. The copy_label() method can be 
        used to make a copy of the label string automatically.

        Parameters:
        [in] 	text 	pointer to new label text
        
        See also:
        copy_label()
        
        Reimplemented in Fl_Window.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        
        if len(args) == 0:
            return widget.label()
        elif len(args) == 1:
            widget.copy_label(args[0])
        else:
            msg = 'label() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef get_label(self):
        '''
        Gets the current label text.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        return widget.label()
    
    cpdef set_label(self, char *new_label):
        '''
        Sets the current label.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.copy_label(new_label)
    
    cpdef tuple measure_label(self):
        '''
        Measure size of current label
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        cdef int ww, hh
        widget.measure_label(ww, hh)
        return ww,hh
        
    def tooltip(self, *args):
        '''
        Sets the current tooltip text.

        Sets a string of text to display in a popup tooltip window when the user
        hovers the mouse over the widget. The string is not copied, so make sure
        any formatted string is stored in a static, global, or allocated buffer.
        If you want a copy made and managed for you, use the copy_tooltip() 
        method, which will manage the tooltip string automatically.

        If no tooltip is set, the tooltip of the parent is inherited. Setting a
        tooltip for a group and setting no tooltip for a child will show the 
        group's tooltip instead. To avoid this behavior, you can set the child's
        tooltip to an empty string ("").

        Parameters:
        [in] 	text 	New tooltip text (no copy is made)
        
        See also:
        copy_tooltip(const char*), tooltip()
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        
        if len(args) == 0:
            return widget.tooltip()
        elif len(args) == 1:
            widget.copy_tooltip(args[0])
        else:
            msg = 'tooltip() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef get_tooltip(self):
        '''
        Gets the current tooltip text.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        return widget.tooltip()
    
    cpdef set_tooltip(self, char *text):
        '''
        Sets the current tooltip text.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.copy_tooltip(text)
    
    def align(self, *args):
        '''
        Sets the label alignment.

        This controls how the label is displayed next to or inside the widget.
        The default value is FL_ALIGN_CENTER, which centers the label inside the
        widget.

        Parameters:
        [in] 	alignment 	new label alignment
        
        See also:
        align(), Fl_Align
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        
        if len(args) == 0:
            return widget.align()
        elif len(args) == 1:
            widget.align(args[0])
        else:
            msg = 'align() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef Fl_Align get_align(self):
        '''
        Gets the label alignment.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        return widget.align()
        
    cpdef set_align(self, Fl_Align a):
        '''
        Sets the label alignment.
        This controls how the label is displayed next to or inside the widget. 
        The default value is FL_ALIGN_CENTER, which centers the label inside 
        the widget.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.align(a)
    
    def labelcolor(self, *args):
        '''
        Sets the label color.

        The default color is FL_FOREGROUND_COLOR.

        Parameters:
        [in] 	c 	the new label color
        
        See also:
        labelcolor()
        
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        
        if len(args) == 0:
            return widget.labelcolor()
        elif len(args) == 1:
            widget.labelcolor(args[0])
        else:
            msg = 'labelcolor() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef Fl_Color get_labelcolor(self):
        '''
        Gets the label color. 
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        return widget.labelcolor()
        
    cpdef set_labelcolor(self, Fl_Color c):
        '''
        Sets the label color. 
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.labelcolor(c)
    
    def labelfont(self, *args):
        '''
        Sets the font to use.

        Fonts are identified by indexes into a table. The default value uses a 
        Helvetica typeface (Arial for Microsoft® Windows®). The function 
        Fl::set_font() can define new typefaces.

        Parameters:
        [in] 	f 	the new font for the label
        
        See also:
        Fl_Font
        
        Reimplemented in Fl_Tree.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        
        if len(args) == 0:
            return widget.labelfont()
        elif len(args) == 1:
            widget.labelfont(args[0])
        else:
            msg = 'labelfont() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef Fl_Font get_labelfont(self):
        '''
        Gets the font to use. 
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        return widget.labelfont()
        
    cpdef set_labelfont(self, Fl_Font f):
        '''
        Sets the font to use. 
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.labelfont(f)
    
    def labeltype(self, *args):
        '''
        Sets the label type.

        The label type identifies the function that draws the label of the 
        widget. This is generally used for special effects such as embossing or 
        for using the label() pointer as another form of data such as an icon. 
        The value FL_NORMAL_LABEL prints the label as plain text.

        Parameters:
        [in] 	a 	new label type
        
        See also:
        Fl_Labeltype
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        
        if len(args) == 0:
            return widget.labeltype()
        elif len(args) == 1:
            widget.labeltype(args[0])
        else:
            msg = 'labeltype() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef Fl_Labeltype get_labeltype(self):
        '''
        Gets the label type.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        return widget.labeltype()
        
    cpdef set_labeltype(self, Fl_Labeltype a):
        '''
        Sets the label type. 
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.labeltype(a)
    
    def labelsize(self, *args):
        '''
        Sets the font size in pixels.

        Parameters:
        
        [in] 	pix 	the new font size
        See also:
        Fl_Fontsize labelsize()
        
        Reimplemented in Fl_Tree.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        
        if len(args) == 0:
            return widget.labelsize()
        elif len(args) == 1:
            widget.labelsize(args[0])
        else:
            msg = 'labelsize() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef Fl_Fontsize get_labelsize(self):
        '''
        Gets the font size in pixels.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        return widget.labelsize()
        
    cpdef set_labelsize(self, Fl_Fontsize pix):
        '''
        Sets the font size in pixels.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.labelsize(pix)
    
    def image(self, *args):
        '''
        Sets the image to use as part of the widget label.
        This image is used when drawing the widget in the active state.

        Parameters:
        [in] 	img 	the new image for the label
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        
        if len(args) == 0:
            return self.get_image()
        elif len(args) == 1:
            self.set_image(args[0])
        else:
            msg = 'image() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef set_image(self, Image img):
        '''
        Sets the image to use as part of the widget label.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.image((<Fl_Image *>img.thisptr).copy())
    
    cpdef get_image(self):
        '''
        Gets the image to use as part of the widget label.
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        cdef Image ret = Image.__new__(Image, None)
        
        cdef Fl_Image *img = widget.image()
        if img != NULL:
            ret.thisptr = img
            return ret
        
    cpdef deimage(self, Image img):
        '''
        Sets the image to use as part of the widget label.  
        '''
        cdef Fl_Widget *widget = <Fl_Widget *>self.thisptr
        widget.deimage(<Fl_Image *>img.thisptr)
        
cdef class Group(Widget):
    def __init__(self, int x, int y, int w, int h, char* label = NULL):
        self.thisptr = new Fl_Group(x, y, w, h, label)
        
        # This object is owned by parent class
        Py_INCREF(self)
        
    cpdef begin(self):
        cdef Fl_Group *group = <Fl_Group *>self.thisptr
        group.begin()
    
    cpdef end(self):
        cdef Fl_Group *group = <Fl_Group *>self.thisptr
        group.end()
    
    cpdef resizable(self, Widget w):
        cdef Fl_Group *group = <Fl_Group *>self.thisptr
        group.resizable(<Fl_Widget *>w.thisptr)

cdef class Tabs(Group):
    def __init__(self, int x, int y, int w, int h, char* label = NULL):
        self.thisptr = new Fl_Tabs(x, y, w, h, label)
        
        # This object is owned by parent class
        Py_INCREF(self)
        
    cpdef value(self, Widget widget):
        cdef Fl_Tabs *group = <Fl_Tabs *>self.thisptr
        group.value(<Fl_Widget *>widget.thisptr)
        
cdef Window_callback(Fl_Window *window, void *data):
    '''
    Callback to call Py_DECREF on children widgets.
    Only used for top level windows.
    '''
    cdef object user_data
    cdef Fl_Widget *w
    
    for i in range(window.children()):
        w = window.child(i)
        if w.user_data() != NULL:
            user_data = <object>w.user_data()
            Py_DECREF(user_data[0])
    
    # This closes the window
    window.hide()
            
cdef class Window(Group):
    def __init__(self, *args):
        cdef Fl_Window *tmp
        cdef char *L = NULL
        
        if len(args) == 2:
            self.thisptr = new Fl_Window(args[0], args[1], L)
        elif len(args) == 3:
            L = args[2]
            self.thisptr = new Fl_Window(args[0], args[1], L)
            
        elif len(args) == 4:
            self.thisptr = new Fl_Window(args[0], args[1], args[2], args[3], L)
        elif len(args) == 5:
            L = args[4]
            self.thisptr = new Fl_Window(args[0], args[1], args[2], args[3], L)
            
        else:
            msg = 'Window() takes two or four arguments (%d given)'
            raise TypeError(msg % len(args))
        
        tmp = <Fl_Window *>self.thisptr
        if tmp.parent() != NULL:
            # This object is owned by parent class
            Py_INCREF(self)
        else:
            tmp.callback(<Fl_Callback_p>Window_callback, NULL)
            
    def __dealloc__(self):
        cdef Fl_Window *tmp
        if self.thisptr != NULL:
            tmp = <Fl_Window *>self.thisptr
            if tmp.parent() == NULL:
                del tmp
                self.thisptr = NULL
    
    def callback(self, *args):
        '''
        Sets the current callback function for the widget.
        
        Each widget has a single callback.
         * cb : new callback
         * data : user data passed to callback
        '''
        cdef Fl_Window *widget = <Fl_Window *>self.thisptr
        
        if widget.parent() == NULL:
            raise ValueError('Can not set callback on top level window')
            
        if len(args) == 1:
            self.cb_data = (self, args[0], None)
            widget.callback(<Fl_Callback_p>Widget_callback, <void *>self.cb_data)
        elif len(args) == 13:
            self.cb_data = (self, args[0], args[1])
            widget.callback(<Fl_Callback_p>Widget_callback, <void *>self.cb_data)
        else:
            msg = 'callback() takes one or two arguments (%d given)'
            raise TypeError(msg % len(args))
        
    cpdef size_range(self, int a, int b, int c=0, int d=0, int e=0, int f=0, int g=0):
        '''
        Sets the allowable range the user can resize this window to.
        This only works for top-level windows.
        '''
        cdef Fl_Window *window = <Fl_Window *>self.thisptr
        window.size_range(a,b,c,d,e,f,g)

    
    cpdef set_modal(self):
        '''
        A "modal" window, when shown(), will prevent any events from being 
        delivered to other windows in the same program, and will also remain on
        top of the other windows (if the X window manager supports the 
        "transient for" property).

        Several modal windows may be shown at once, in which case only the last
        one shown gets events. You can see which window (if any) is modal by 
        calling Fl::modal().
        '''
        cdef Fl_Window *window = <Fl_Window *>self.thisptr
        window.set_modal()
        
    cpdef int modal(self):
        '''
        Return modal flag
        '''
        cdef Fl_Window *window = <Fl_Window *>self.thisptr
        return window.modal()
        
    cpdef set_non_modal(self):
        '''
        Clear modal flag
        '''
        cdef Fl_Window *window = <Fl_Window *>self.thisptr
        window.set_non_modal()
        
cdef class Double_Window(Window):
    def __init__(self, *args, char* title = NULL):
        cdef Fl_Window *tmp
        cdef char *L = NULL
        
        if len(args) == 2:
            self.thisptr = new Fl_Double_Window(args[0], args[1], L)
        elif len(args) == 3:
            L = args[2]
            self.thisptr = new Fl_Double_Window(args[0], args[1], L)
            
        elif len(args) == 4:
            self.thisptr = new Fl_Double_Window(args[0], args[1], args[2], args[3], L)
        elif len(args) == 5:
            L = args[4]
            self.thisptr = new Fl_Double_Window(args[0], args[1], args[2], args[3], L)
            
        else:
            msg = 'Double_Window() takes two to five arguments (%d given)'
            raise TypeError(msg % len(args))
            
        tmp = <Fl_Window *>self.thisptr
        if tmp.parent() != NULL:
            # This object is owned by parent class
            Py_INCREF(self)
        else:
            tmp.callback(<Fl_Callback_p>Window_callback, NULL)
            
cdef public GL_Window_ext_callback(Fl_Gl_Window *widget, object py_data, char *cmd, int *data):
    '''
    Callback wrapper
    '''
    cdef Gl_Window self = py_data
    cdef int ret
    
    if cmd == b'draw':
        self.draw()
    elif cmd == b'handle':
        ret = self.handle(data[0])
        data[0] = ret
        
cdef class Gl_Window(Window):
    '''
    The Fl_Gl_Window widget sets things up so OpenGL works.
    
    It also keeps an OpenGL "context" for that window, so that changes to the
    lighting and projection may be reused between redraws. Fl_Gl_Window
    also flushes the OpenGL streams and swaps buffers after draw() returns.

    OpenGL hardware typically provides some overlay bit planes, which
    are very useful for drawing UI controls atop your 3D graphics.  If the
    overlay hardware is not provided, FLTK tries to simulate the overlay.
    This works pretty well if your graphics are double buffered, but not
    very well for single-buffered.

    Please note that the FLTK drawing and clipping functions
    will not work inside an Fl_Gl_Window. All drawing
    should be done using OpenGL calls exclusively.
    Even though Fl_Gl_Window is derived from Fl_Group, 
    it is not useful to add other FLTK Widgets as children,
    unless those widgets are modified to draw using OpenGL calls.
    '''
    def __init__(self, *args):
        cdef Fl_Window *tmp
        cdef char *L = NULL
        
        if len(args) == 2:
            self.thisptr = new Fl_Gl_Window_(args[0], args[1], L, <void *>self)
        elif len(args) == 3:
            L = args[2]
            self.thisptr = new Fl_Gl_Window_(args[0], args[1], L, <void *>self)
        elif len(args) == 4:
            self.thisptr = new Fl_Gl_Window_(args[0], args[1], args[2], args[3], L, <void *>self)
        elif len(args) == 5:
            L = args[4]
            self.thisptr = new Fl_Gl_Window_(args[0], args[1], args[2], args[3], L, <void *>self)
        else:
            msg = 'Gl_Window() takes two to five arguments (%d given)'
            raise TypeError(msg % len(args))
        
        tmp = <Fl_Window *>self.thisptr
        if tmp.parent() != NULL:
            # This object is owned by parent class
            Py_INCREF(self)
        else:
            tmp.callback(<Fl_Callback_p>Window_callback, NULL)
    
    cpdef flush(self):
        '''
        Forces the window to be drawn, this window is also made current
        and calls draw().
        '''
        cdef Fl_Gl_Window_ *window = <Fl_Gl_Window_ *>self.thisptr
        window.flush()
    
    def valid(self, *args):
        '''
        Is turned off when FLTK creates a new context for this window or when
        the window resizes, and is turned on after draw() is called.
        '''
        cdef Fl_Gl_Window_ *window = <Fl_Gl_Window_ *>self.thisptr
        
        if len(args) == 0:
            return window.valid()
        elif len(args) == 1:
            window.valid(args[0])
        else:
            msg = 'valid() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef char get_valid(self):
        '''
        Get the valid flag.
        '''
        cdef Fl_Gl_Window_ *window = <Fl_Gl_Window_ *>self.thisptr
        return window.valid()
        
    cpdef set_valid(self, char v):
        '''
        Changes the valid flag.
        '''
        cdef Fl_Gl_Window_ *window = <Fl_Gl_Window_ *>self.thisptr
        window.valid(v)
        
    cpdef invalidate(self):
        '''
        The invalidate() method turns off valid() and is equivalent to calling
        value(0). 
        '''
        cdef Fl_Gl_Window_ *window = <Fl_Gl_Window_ *>self.thisptr
        window.invalidate()
    
    def context_valid(self, *args):
        '''
        Will only be set if the OpenGL context is created or recreated.

        It differs from Fl_Gl_Window::valid() which is also set whenever the 
        context changes size.
        '''
        cdef Fl_Gl_Window_ *window = <Fl_Gl_Window_ *>self.thisptr
        
        if len(args) == 0:
            return window.context_valid()
        elif len(args) == 1:
            window.context_valid(args[0])
        else:
            msg = 'context_valid() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef char get_context_valid(self):
        '''
        Get context_valid status
        '''
        cdef Fl_Gl_Window_ *window = <Fl_Gl_Window_ *>self.thisptr
        return window.context_valid()
        
    cpdef set_context_valid(self, char v):
        '''
        Set context_valid status
        '''
        cdef Fl_Gl_Window_ *window = <Fl_Gl_Window_ *>self.thisptr
        window.context_valid(v)
        
    cpdef int can_do(self):
        '''
        Returns non-zero if the hardware supports the given or current OpenGL mode. 
        '''
        cdef Fl_Gl_Window_ *window = <Fl_Gl_Window_ *>self.thisptr
        return window.can_do()
    
    def mode(self, *args):
        '''
        Set or change the OpenGL capabilites of the window.
        The value can be any of the following OR'd together:

        FL_RGB - RGB color (not indexed)
        FL_RGB8 - RGB color with at least 8 bits of each color
        FL_INDEX - Indexed mode
        FL_SINGLE - not double buffered
        FL_DOUBLE - double buffered
        FL_ACCUM - accumulation buffer
        FL_ALPHA - alpha channel in color
        FL_DEPTH - depth buffer
        FL_STENCIL - stencil buffer
        FL_MULTISAMPLE - multisample antialiasing
        FL_RGB and FL_SINGLE have a value of zero, so they are "on" unless you 
        give FL_INDEX or FL_DOUBLE.

        If the desired combination cannot be done, FLTK will try turning off 
        FL_MULTISAMPLE. If this also fails the show() will call Fl::error() 
        and not show the window.

        You can change the mode while the window is displayed. This is most 
        useful for turning double-buffering on and off. Under X this will cause 
        the old X window to be destroyed and a new one to be created. If this is
        a top-level window this will unfortunately also cause the window to 
        blink, raise to the top, and be de-iconized, and the xid() will change,
        possibly breaking other code. It is best to make the GL window a child 
        of another window if you wish to do this!

        mode() must not be called within draw() since it changes the current
        context.
        '''
        cdef Fl_Gl_Window_ *window = <Fl_Gl_Window_ *>self.thisptr
        
        if len(args) == 0:
            return window.mode()
        elif len(args) == 1:
            window.mode(<int>args[0])
        else:
            msg = 'mode() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef Fl_Mode get_mode(self):
        '''
        See set_mode.
        '''
        cdef Fl_Gl_Window_ *window = <Fl_Gl_Window_ *>self.thisptr
        return window.mode()
        
    cpdef int set_mode(self, int a):
        '''
        Set or change the OpenGL capabilites of the window.
        '''
        cdef Fl_Gl_Window_ *window = <Fl_Gl_Window_ *>self.thisptr
        window.mode(a)
        
    cpdef make_current(self):
        '''
        The make_current() method selects the OpenGL context for the widget.

        It is called automatically prior to the draw() method being called and
        can also be used to implement feedback and/or selection within the
        handle() method.
        '''
        cdef Fl_Gl_Window_ *window = <Fl_Gl_Window_ *>self.thisptr
        window.make_current()
        
    cpdef swap_buffers(self):
        '''
        The swap_buffers() method swaps the back and front buffers.
        
        It is called automatically after the draw() method is called.
        '''
        cdef Fl_Gl_Window_ *window = <Fl_Gl_Window_ *>self.thisptr
        window.swap_buffers()
        
    cpdef ortho(self):
        '''
        Sets the projection so 0,0 is in the lower left of the window and each
        pixel is 1 unit wide/tall.

        If you are drawing 2D images, your draw() method may want to call this
        if valid() is false.
        '''
        cdef Fl_Gl_Window_ *window = <Fl_Gl_Window_ *>self.thisptr
        window.ortho()
        
    cpdef int can_do_overlay(self):
        '''
        Returns true if the hardware overlay is possible.
        
        If this is false, FLTK will try to simulate the overlay, with
        significant loss of update speed. Calling this will cause FLTK to open
        the display.
        '''
        cdef Fl_Gl_Window_ *window = <Fl_Gl_Window_ *>self.thisptr
        return window.can_do_overlay()
        
    cpdef redraw_overlay(self):
        '''
        This method causes draw_overlay() to be called at a later time.
        
        Initially the overlay is clear. If you want the window to display 
        something in the overlay when it first appears, you must call this 
        immediately after you show() your window.
        '''
        cdef Fl_Gl_Window_ *window = <Fl_Gl_Window_ *>self.thisptr
        window.redraw_overlay()
        
    cpdef hide_overlay(self):
        '''
        Hides the window if it is not this window, does nothing in WIN32.
        '''
        cdef Fl_Gl_Window_ *window = <Fl_Gl_Window_ *>self.thisptr
        window.hide_overlay()
        
    cpdef make_overlay_current(self):
        '''
        The make_overlay_current() method selects the OpenGL context for the
        widget's overlay.
        
        It is called automatically prior to the draw_overlay() method being 
        called and can also be used to implement feedback and/or selection 
        within the handle() method.
        '''
        cdef Fl_Gl_Window_ *window = <Fl_Gl_Window_ *>self.thisptr
        window.make_overlay_current()
        
        