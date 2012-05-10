# Drawing functions

def color(*args):
    if len(args) == 0:
        return fl_color()
    elif len(args) == 1:
        fl_color(args[0])
    else:
        msg = 'color() takes at most one argument (%d given)'
        raise ValueError(msg % len(args))
            
cpdef Fl_Color get_color():
    '''
    Get current color
    '''
    return fl_color()

cpdef set_color(Fl_Color c):
    '''
    Get current color
    '''
    fl_color(c)
    
cpdef point(int x, int y):
    '''
    Draw a single pixel at the given coordinates.
    '''
    fl_point(x, y)

cpdef line_style(int style, int width, char* dashes):
    '''
    Sets line style
    '''
    fl_line_style(style, width, dashes)

cpdef rect(int x, int y, int w, int h):
    '''
    Draw a 1-pixel border inside this bounding box.
    '''
    fl_rect(x, y, w, h)

cpdef rectf(int x, int y, int w, int h):
    '''
    Color a rectangle that exactly fills the given bounding box.
    '''
    fl_rectf(x, y, w, h)

cpdef line(int x, int y, int x1, int y1):
    '''
    Draw one between the given points.
    '''
    fl_line(x, y, x1, y1)

cpdef loop(int x, int y, int x1, int y1, int x2, int y2):
    '''
    Outline a 3 sided polygon with lines.
    '''
    fl_loop(x, y, x1, y1, x2, y2)

cpdef polygon(int x, int y, int x1, int y1, int x2, int y2):
    '''
    Fill a 3 sided polygon. The polygon must be convex.
    '''
    fl_polygon(x, y, x1, y1, x2, y2)

cpdef arc_(int x, int y, int w, int h, double a1, double a2):
    '''
    fl_arc() draws a series of lines to approximate the arc.
    '''
    fl_arc(x, y, w, h, a1, a2)
    
cpdef pie(int x, int y, int w, int h, double a1, double a2):
    '''
    draws a filled-in pie slice.
    This slice may extend outside the line drawn by fl_arc();
    to avoid this use w-1 and h-1.
    '''
    fl_pie(x, y, w, h, a1, a2)

cpdef push_matrix():
    '''
    Save and restore the current transformation.
    The maximum depth of the stack is 4.
    '''
    fl_push_matrix()
    
cpdef pop_matrix():
    '''
    Save and restore the current transformation.
    The maximum depth of the stack is 4.
    '''
    fl_pop_matrix()
    
cpdef scale(double x, double y = 1.):
    '''
    Concatenate another transformation onto the current one.
    '''
    fl_scale(x, y)
    
cpdef translate(double x, double y):
    '''
    Concatenate another transformation onto the current one.
    '''
    fl_translate(x, y)
    
cpdef rotate(double d):
    '''
    Concatenate another transformation onto the current one.
    The rotation angle is in degrees (not radians) and is counter-clockwise.
    '''
    fl_rotate(d)
    
cpdef mult_matrix(double a, double b, double c, double d, double x,double y):
    '''
    Concatenate another transformation onto the current one.
    '''
    fl_mult_matrix(a, b, c, d, x,y)
    
cpdef begin_points():
    '''
    Start and end drawing a list of points.
    Points are added to the list with fl_vertex().
    '''
    fl_begin_points()

cpdef end_points():
    '''
    Start and end drawing a list of points.
    Points are added to the list with fl_vertex().
    '''
    fl_end_points()
    
cpdef begin_line():
    '''
    Start and end drawing lines.
    '''
    fl_begin_line()

cpdef end_line():
    '''
    Start and end drawing lines.
    '''
    fl_end_line()
    
cpdef begin_loop():
    '''
    Start and end drawing a closed sequence of lines.
    '''
    fl_begin_loop()

cpdef end_loop():
    '''
    Start and end drawing a closed sequence of lines.
    '''
    fl_end_loop()
    
cpdef begin_polygon():
    '''
    Start and end drawing a convex filled polygon.
    '''
    fl_begin_polygon()

cpdef end_polygon():
    '''
    Start and end drawing a convex filled polygon.
    '''
    fl_end_polygon()
    
cpdef begin_complex_polygon():
    '''
    Start and end drawing a complex filled polygon.
    This polygon may be concave, may have holes in it, or may be several
    disconnected pieces. Call fl_gap() to separate loops of the path.
    It is unnecessary but harmless to call fl_gap() before the first vertex,
    after the last one, or several times in a row.
    
    fl_gap() should only be called between fl_begin_complex_polygon() and 
    fl_end_complex_polygon(). To outline the polygon, use fl_begin_loop()
    and replace each fl_gap() with a fl_end_loop();fl_begin_loop() pair.
    '''
    fl_begin_complex_polygon()

cpdef end_complex_polygon():
    '''
    Start and end drawing a complex filled polygon.
    This polygon may be concave, may have holes in it, or may be several
    disconnected pieces. Call fl_gap() to separate loops of the path.
    It is unnecessary but harmless to call fl_gap() before the first vertex,
    after the last one, or several times in a row.
    
    fl_gap() should only be called between fl_begin_complex_polygon() and 
    fl_end_complex_polygon(). To outline the polygon, use fl_begin_loop()
    and replace each fl_gap() with a fl_end_loop();fl_begin_loop() pair.
    '''
    fl_end_complex_polygon()

cpdef vertex(double x, double y):
    '''
    Add a single vertex to the current path.
    '''
    fl_vertex(x, y)
    
cpdef curve(double X0, double Y0, double X1, double Y1, double X2, double Y2, double X3, double Y3):
    '''
    Add a series of points on a Bezier curve to the path.
    The curve ends (and two of the points) are at X0,Y0 and X3,Y3.
    '''
    fl_curve(X0, Y0, X1, Y1, X2, Y2, X3, Y3)
    
cpdef arc(double x, double y, double r, double start, double end):
    '''
    Add a series of points to the current path on the arc of a circle; 
    you can get elliptical paths by using scale and rotate before calling fl_arc().
    The center of the circle is given by x and y, and r is its radius.
    fl_arc() takes start and end angles that are measured in degrees
    counter-clockwise from 3 o'clock. If end is less than start then it draws
    the arc in a clockwise direction.
    '''
    fl_arc(x, y, r, start, end)
    
cpdef circle(double x, double y, double r):
    '''
    fl_circle(...) is equivalent to fl_arc(...,0,360) but may be faster.
    It must be the only thing in the path: if you want a circle as part of a
    complex polygon you must use fl_arc().
    Note: fl_circle() draws incorrectly if the transformation is both rotated
    and non-square scaled.
    '''
    fl_circle(x, y, r)
    
cpdef gap():
    '''
    Separate loops of the path.
    '''
    fl_gap()
    
cpdef double transform_x(double x, double y):
    '''
    Transform a coordinate or a distance using the current transformation matrix.
    After transforming a coordinate pair, it can be added to the vertex list
    without any further translations using fl_transformed_vertex().
    '''
    return fl_transform_x(x, y)
    
cpdef double transform_y(double x, double y):
    '''
    Transform a coordinate or a distance using the current transformation matrix.
    After transforming a coordinate pair, it can be added to the vertex list
    without any further translations using fl_transformed_vertex().
    '''
    return fl_transform_y(x, y)
    
cpdef double transform_dx(double x, double y):
    '''
    Transform a coordinate or a distance using the current transformation matrix.
    After transforming a coordinate pair, it can be added to the vertex list
    without any further translations using fl_transformed_vertex().
    '''
    return fl_transform_dx(x, y)
    
cpdef double transform_dy(double x, double y):
    '''
    Transform a coordinate or a distance using the current transformation matrix.
    After transforming a coordinate pair, it can be added to the vertex list
    without any further translations using fl_transformed_vertex().
    '''
    return fl_transform_dy(x, y)
    
cpdef transformed_vertex(double xf, double yf):
    '''
    Transform a coordinate or a distance using the current transformation matrix.
    After transforming a coordinate pair, it can be added to the vertex list
    without any further translations using fl_transformed_vertex().
    '''
    fl_transformed_vertex(xf, yf)

def font(*args):
    if len(args) == 0:
        return fl_font()
    elif len(args) == 2:
        fl_font(args[0], args[1])
    else:
        msg = 'font() takes zero or two arguments (%d given)'
        raise TypeError(msg % len(args))
        
cpdef set_font(Fl_Font face, Fl_Fontsize size):
    '''
    Set the current font, which is then used by the routines described above.
    You may call this outside a draw context if necessary to call fl_width(),
    but on X this will open the display.
    The font is identified by a face and a size. The size of the font is measured
    in pixels and not "points". Lines should be spaced size pixels apart or more.
    '''
    fl_font(face, size)

cpdef Fl_Font get_font():
    '''
    Get font face
    '''
    return fl_font()

cpdef Fl_Fontsize size():
    '''
    Get font size
    '''
    return fl_size()

cpdef double width(char *st):
    '''
    Return the typographical width of a nul-terminated string
    '''
    return fl_width(st)
    
cpdef draw_string(char *st, int x, int y):
    '''
    Draw a nul-terminated string or an array of n characters starting at the
    given location. Text is aligned to the left and to the baseline of the font.
    To align to the bottom, subtract fl_descent() from y. To align to the top,
    subtract fl_descent() and add fl_height(). This version of fl_draw() provides
    direct access to the text drawing function of the underlying OS. It does not
    apply any special handling to control characters.
    '''
    fl_draw(st, x, y)

cdef class Offscreen:
    '''
    Class to hold reference to Fl_Offscreen
    '''
    cdef unsigned long thisptr
    
cpdef Offscreen create_offscreen(int w, int h):
    '''
    Create an RGB offscreen buffer with w*h pixels.
    '''
    cdef Fl_Offscreen os = fl_create_offscreen(w, h)
    cdef Offscreen ret = Offscreen()
    ret.thisptr = os
    return ret

cpdef delete_offscreen(Offscreen os):
    '''
    Delete a previously created offscreen buffer.
    All drawings are lost.
    '''
    fl_delete_offscreen(<Fl_Offscreen>os.thisptr)

cpdef begin_offscreen(Offscreen os):
    '''
    Send all subsequent drawing commands to this offscreen buffer. FLTK can draw
    into a buffer at any time. There is no need to wait for an 
    Fl_Widget::draw() to occur.
    '''
    fl_begin_offscreen(<Fl_Offscreen>os.thisptr)
    
cpdef end_offscreen():
    '''
    Quit sending drawing commands to this offscreen buffer.
    '''
    pass
    # Fixme!
    #fl_end_offscreen_()
    
cpdef copy_offscreen(int x, int y, int w, int h, Offscreen osrc, int srcx, int srcy):
    '''
    Copy a rectangular area of the size w*h from srcx,srcy in the offscreen
    buffer into the current buffer at x,y.
    '''
    fl_copy_offscreen(x, y, w, h, <Fl_Offscreen>osrc.thisptr, srcx, srcy)
