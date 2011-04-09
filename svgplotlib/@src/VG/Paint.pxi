cdef class Paint(Handle):
    cdef VGPaint ptr(self):
        return <VGPaint>self.thisptr
        
cpdef Paint CreatePaint():
    '''
    The vgCreatePaint function creates a new paint object that is initialized to
    a set of default values and returns a VGPaint handle to it.
    '''
    cdef Paint ret = Paint()
    ret.thisptr = vgCreatePaint()
    return ret

cpdef DestroyPaint(Paint paint):
    '''
    Disposes specified paint resource in the current context
    '''
    vgDestroyPaint(paint.ptr())
    
cpdef SetPaint(Paint paint, VGbitfield paintModes):
    '''
    The vgSetPaint function sets Paint definitions on the current context.
    The paintModes argument is a bitwise OR of values from the enumeration, 
    VG_FILL_PATH or VG_STROKE_PATH, determining whether the paint object is to 
    be used for filling ( VG_FILL_PATH ), stroking ( VG_STROKE_PATH), or both 
    ( VG_FILL_PATH | VG_STROKE_PATH).
    '''
    vgSetPaint(paint.ptr(), paintModes)

cpdef PaintPattern(Paint paint, Image pattern):
    '''
    Replace the image pattern defined for the given paint object
    '''
    vgPaintPattern(paint.ptr(), pattern.ptr())