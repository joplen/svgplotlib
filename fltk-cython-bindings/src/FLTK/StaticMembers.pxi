# Dialogs
cpdef message(char *msg):
    fl_message(msg)

cpdef alert(char *msg):
    fl_alert(msg)

cpdef int choice(char *q, char *b0, char *b1 = NULL, char *b2 = NULL):
    return fl_choice(q, b0, b1, b2)

cpdef input(char *label, char *deflt = NULL):
    return fl_input(label, deflt)
    
# Color functions
cpdef Fl_Color inactive(Fl_Color c):
    return fl_inactive(c)

cpdef Fl_Color contrast(Fl_Color fg, Fl_Color bg):
    return fl_contrast(fg,bg)

cpdef Fl_Color color_average(Fl_Color c1, Fl_Color c2, float weight):
    return fl_color_average(c1,c2,weight)
    
cpdef Fl_Color lighter(Fl_Color c):
    return fl_lighter(c)

cpdef Fl_Color darker(Fl_Color c):
    return fl_darker(c)

cpdef Fl_Color rgb_color(uchar r, uchar g, uchar b):
    '''
    Return 24-bit color value closest r,g,b.
    '''
    return fl_rgb_color(r,g,b)

# Event information
cpdef int event():
    '''
    Returns the last event that was processed. This can be used
    to determine if a callback is being done in response to a
    keypress, mouse click, etc.
    '''
    return Fl_event()
    
cpdef int event_x():
    '''
    Returns the mouse position of the event relative to the Fl_Window
    it was passed to.
    '''
    return Fl_event_x()
    
cpdef int event_y() :
    '''
    Returns the mouse position of the event relative to the Fl_Window
    it was passed to.
    '''
    return Fl_event_y()
    
cpdef int event_x_root():
    '''
    Returns the mouse position on the screen of the event.  To find the
    absolute position of an Fl_Window on the screen, use the
    difference between event_x_root(),event_y_root() and 
    event_x(),event_y().
    '''
    return Fl_event_x_root()
    
cpdef int event_y_root():
    '''
    Returns the mouse position on the screen of the event.  To find the
    absolute position of an Fl_Window on the screen, use the
    difference between event_x_root(),event_y_root() and 
    event_x(),event_y().
    '''
    return Fl_event_y_root()
    
cpdef int event_dx():
    '''
    Returns the current horizontal mouse scrolling associated with the
    FL_MOUSEWHEEL event. Right is positive.
    '''
    return Fl_event_dx()
    
cpdef int event_dy():
    '''
    Returns the current vertical mouse scrolling associated with the
    FL_MOUSEWHEEL event. Down is positive.
    '''
    return Fl_event_dy()
    
cpdef int event_clicks():
    '''
    Returns non zero if we had a double click event.
    Return non-zero if the most recent FL_PUSH or FL_KEYBOARD was a "double click".  
    Return  N-1 for  N clicks. 
    A double click is counted if the same button is pressed
    again while event_is_click() is true.
    '''
    return Fl_event_clicks()
    
cpdef int event_button():
    '''
    Gets which particular mouse button caused the current event. 
    This returns garbage if the most recent event was not a FL_PUSH or FL_RELEASE event.
    
    Returns
     * FL_LEFT_MOUSE
     * FL_MIDDLE_MOUSE
     * FL_RIGHT_MOUSE.
    '''
    return Fl_event_button()
    
cpdef int event_key():
    '''
    Gets which key on the keyboard was last pushed.

    The returned integer 'key code' is not necessarily a text
    equivalent for the keystroke. For instance: if someone presses '5' on the 
    numeric keypad with numlock on, Fl::event_key() may return the 'key code'
    for this key, and NOT the character '5'. To always get the '5', use 
    Fl::event_text() instead.
    '''
    return Fl_event_key()

# Misc
cpdef double version():
    '''
     API version number
    '''
    return Fl_version()

cpdef int run():
    '''
    Execute
    '''
    return Fl_run()

cpdef int wait():
    '''
    Waits until "something happens" and then returns.
    '''
    return Fl_wait()

cpdef exit():
    '''
    Close top level window
    '''
    cdef Fl_Window *window = Fl_first_window()
    if not window == NULL:
        Fl_handle(FL_CLOSE, window)

cpdef unsigned long xid(Window w):
    cdef Fl_Window *window = <Fl_Window *>w.thisptr
    return fl_xid(window)
