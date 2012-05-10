# -*- coding: utf-8 -*-
from libc.stdlib cimport malloc, free
from VGLib cimport *

include "Enumerations.pxi"

cdef class Handle:
    cdef void *thisptr
    cdef long datatype

cpdef VGErrorCode GetError():
    '''
    Returns the oldest error pending on the current
    context and clears its error code
    '''
    return vgGetError()

cpdef Flush():
    '''
    Force execution of VG commands in finite time
    '''
    vgFlush()

cpdef Finish():
    '''
    Block until all VG execution is complete
    '''
    vgFinish()


include "Parameters.pxi"
include "Matrix.pxi"
include "Image.pxi"
include "Path.pxi"
include "Paint.pxi"
include "VGU.pxi"

cpdef Clear(VGint x, VGint y, VGint width, VGint height):
    '''
    Clear given rectangle area with color set via 
    vgSetfv(VG_CLEAR_COLOR, ...)
    '''
    vgClear(x, y, width, height)
    
cpdef DrawPath(Path path, VGbitfield paintModes):
    '''
    Tessellates / strokes the path and draws it according to
    VGContext state.
    '''
    vgDrawPath(path.ptr(), paintModes)

cpdef DrawImage(Image image):
    '''
    Draw image to current drawing surface
    '''
    vgDrawImage(image.ptr())
    
# OpenVG extensions
cpdef VGboolean CreateContextSH(VGint width, VGint height):
    '''
    Simple functions to create a VG context instance
    on top of an existing OpenGL context.
    TODO: There is no mechanics yet to asure the OpenGL
    context exists and to choose which context / window
    to bind to. 
    '''
    return vgCreateContextSH(width, height)
    
cpdef ResizeSurfaceSH(VGint width, VGint height):
    '''
    Resize VG context instance to given width and height
    '''
    vgResizeSurfaceSH(width, height)
    
cpdef DestroyContextSH():
    '''
    Disposes specified the context and all defined paths, images etc.
    '''
    vgDestroyContextSH()

cdef struct c_userdata:
    void *draw
    void *finish
    void *userdata

cdef draw_cb(c_userdata *ud):
    (<object>ud.draw)(<object>ud.userdata)

cdef finish_cb(c_userdata *ud):
    (<object>ud.finish)(<object>ud.userdata)
    
cpdef int OffscreenRender(int width, int height, draw, finish, userdata = None):
    '''
    Sets up an offscreen GL context and calls the callbacks.
    Image data can be read in the finish callback.
    '''
    cdef c_userdata data = c_userdata(<void *>draw, <void *>finish, <void *>userdata)
    return shOffscreenRender(width, height, <OffScreenCB>draw_cb, <OffScreenCB>finish_cb, &data)

cdef class PixelBuffer:
    cdef unsigned char *_buffer
    cdef int width
    cdef int height
    cdef int bytesPerPixel
    
    # buffer interface
    cdef Py_ssize_t __shape[1]
    cdef Py_ssize_t __strides[1]
    cdef __cythonbufferdefaults__ = {"ndim": 1, "mode": "c"}
    
    def __init__(self, int width, int height, int bytesPerPixel = 4):
        self.width = width
        self.height = height
        self.bytesPerPixel = bytesPerPixel
        
        self._buffer = <unsigned char *>malloc(width * height * bytesPerPixel * sizeof(unsigned char))
        if self._buffer == NULL:
            raise MemoryError('Could not allocate memory') 
        
    def __dealloc__(self):
        if not self._buffer == NULL:
            free(self._buffer)
    
    def __getbuffer__(self, Py_buffer* buffer, int flags):
        self.__shape[0] = self.width * self.height * self.bytesPerPixel
        self.__strides[0] = 1
        
        buffer.buf = <void *>self._buffer
        buffer.obj = self
        buffer.len =  self.width * self.height * self.bytesPerPixel
        buffer.readonly = 0
        buffer.format = <char*>"B"
        buffer.ndim = 1
        buffer.shape = <Py_ssize_t *>&self.__shape[0]
        buffer.strides = <Py_ssize_t *>&self.__strides[0]
        buffer.suboffsets = NULL
        buffer.itemsize = sizeof(unsigned char)
        buffer.internal = NULL
        
    def __releasebuffer__(self, Py_buffer* buffer):
        pass
    
    def __len__(self):
        return self.width * self.height * self.bytesPerPixel
        
cdef class OffScreen(Handle):
    pass

cpdef OffScreen CreateOffScreenSH():
    cdef OffScreen ret = OffScreen()
    ret.thisptr = vgCreateOffScreenSH()
    return ret

cpdef DestroyOffScreenSH(OffScreen context):
    vgDestroyOffScreenSH(context.thisptr)

cpdef StartOffScreenSH(OffScreen context, int width, int height):
    vgStartOffScreenSH(context.thisptr, width, height)

cpdef EndOffScreenSH(OffScreen context, PixelBuffer pixels):
    vgEndOffScreenSH(context.thisptr, pixels._buffer)
