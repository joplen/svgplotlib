cpdef int Line(Path path, VGfloat x0, VGfloat y0, VGfloat x1, VGfloat y1):
    '''
    The vguLine appends a line segment to a path.
    '''
    return vguLine(path.ptr(), x0, y0, x1, y1)

cpdef int Polygon(Path path, points, VGint count, VGboolean closed):
    '''
    The vguPolygon appends a polyline or polygon to a path.
    '''
    cdef VGfloat *c_points
    cdef int i, ret
    
    try:
        c_points = <VGfloat *>malloc(2 * count * sizeof(VGfloat))
        for i in range(count*2):
            c_points[i] = points[i]
        
        ret = vguPolygon(path.ptr(), c_points, count, closed)
    finally:
        if c_points != NULL:
            free(c_points)
    
    return ret

cpdef int Rect(Path path, VGfloat x, VGfloat y, VGfloat width, VGfloat height):
    '''
    The vguRect appends an axis-aligned rectangle to a path.
    '''
    return vguRect(path.ptr(), x, y, width, height)

cpdef int RoundRect(Path path, VGfloat x, VGfloat y, VGfloat width, VGfloat height,
                     VGfloat arcWidth, VGfloat arcHeight):
    '''
    The vguRoundRect appends an axis-aligned round-cornered rectangle to a path.
    '''
    return vguRoundRect(path.ptr(), x, y, width, height, arcWidth, arcHeight)

cpdef int Ellipse(Path path, VGfloat cx, VGfloat cy, VGfloat width, VGfloat height):
    '''
    The vguEllipse appends an axis-aligned ellipse to a path.
    '''
    return vguEllipse(path.ptr(), cx, cy, width, height)

cpdef int Arc(Path path, VGfloat x, VGfloat y, VGfloat width, VGfloat height,
               VGfloat startAngle, VGfloat angleExtent, VGUArcType arcType):
    '''
    The vguEllipse appends an elliptical arc to a path, possibly along with one
    or two line segments, according to the arcType parameter.
    '''
    return vguArc(path.ptr(), x, y, width, height, startAngle, angleExtent, arcType)