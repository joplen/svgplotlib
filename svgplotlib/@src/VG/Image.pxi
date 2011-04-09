# Image
cdef class Image(Handle):
    cdef VGImage ptr(self):
        return <VGImage>self.thisptr

cpdef Image CreateImage(VGImageFormat format, VGint width, VGint height,
                        VGbitfield allowedQuality = VG_IMAGE_QUALITY_BETTER):
    '''
    Creates a new image object and returns the handle to it
    '''
    cdef Image ret = Image()
    ret.thisptr = vgCreateImage(format, width, height, allowedQuality)
    return ret

cpdef DestroyImage(Image image):
    '''
    Disposes specified image resource in the current context
    '''
    vgDestroyImage(image.ptr())

cpdef ClearImage(Image image, VGint x, VGint y, VGint width, VGint height):
    '''
    Clear given rectangle area in the image data with
    color set via vgSetfv(VG_CLEAR_COLOR, ...)
    '''
    vgClearImage(image.ptr(), x, y, width, height)

cpdef ImageSubData(Image image, data, VGint dataStride, VGImageFormat dataFormat,
                    VGint x, VGint y, VGint width, VGint height):
    '''
    Copies a rectangle area of pixels of size (width,height)
    from given data buffer to image surface at destination
    coordinates (x,y)
    '''
    cdef object [unsigned char, ndim=1] imgbuffer = data
    cdef unsigned char *c_data
    cdef int i, datasize
    
    try:
        datasize = len(data)
        c_data = <unsigned char *>malloc(datasize * sizeof(unsigned char))
        for i in range(datasize):
            c_data[i] = imgbuffer[i]
        
        vgImageSubData(image.ptr(),c_data,dataStride,dataFormat,x,y,width,height)
    finally:
        if c_data != NULL:
            free(c_data)
    
cpdef GetImageSubData(Image image, data, VGint dataStride, VGImageFormat dataFormat,
                    VGint x, VGint y, VGint width, VGint height):
    '''
    Copies a rectangle area of pixels of size (width,height)
    from image surface at source coordinates (x,y) to given
    data buffer
    '''
    cdef object [unsigned char, ndim=1] imgbuffer = data
    cdef unsigned char *c_data
    cdef int i, datasize
    
    try:
        datasize = len(data)
        c_data = <unsigned char *>malloc(datasize * sizeof(unsigned char))
        vgGetImageSubData(image.ptr(),c_data,dataStride,dataFormat,x,y,width,height)
        
        for i in range(datasize):
            imgbuffer[i] = c_data[i]
            
    finally:
        if c_data != NULL:
            free(c_data)

cpdef CopyImage(Image dst, VGint dx, VGint dy,
                Image src, VGint sx, VGint sy,
                VGint width, VGint height,
                VGboolean dither):
    '''
    Copies a rectangle area of pixels of size (width,height)
    from src image surface at source coordinates (sx,sy) to
    dst image surface at destination cordinates (dx,dy)
    '''
    vgCopyImage(dst.ptr(),dx,dy,src.ptr(),sx,sy,width,height,dither)

cpdef SetPixels(VGint dx, VGint dy, Image src, VGint sx, VGint sy,
                VGint width, VGint height):
    '''
    Copies a rectangle area of pixels of size (width,height)
    from src image surface at source coordinates (sx,sy) to
    window surface at destination coordinates (dx,dy)
    '''
    vgSetPixels(dx,dy,src.ptr(),sx,sy,width,height)

cpdef WritePixels(data, VGint dataStride, VGImageFormat dataFormat,
                  VGint dx, VGint dy, VGint width, VGint height):
    '''
    Copies a rectangle area of pixels of size (width,height)
    from given data buffer at source coordinates (sx,sy) to
    window surface at destination coordinates (dx,dy)
    '''
    cdef object [unsigned char, ndim=1] imgbuffer = data
    cdef unsigned char *c_data
    cdef int i, datasize
    
    try:
        datasize = len(data)
        c_data = <unsigned char *>malloc(datasize * sizeof(unsigned char))
        for i in range(datasize):
            c_data[i] = imgbuffer[i]
            
        vgWritePixels(c_data,dataStride,dataFormat,dx,dy,width,height)
            
    finally:
        if c_data != NULL:
            free(c_data)

cpdef GetPixels(Image dst, VGint dx, VGint dy, VGint sx, VGint sy,
                VGint width, VGint height):
    '''
    Copies a rectangle area of pixels of size (width, height)
    from window surface at source coordinates (sx, sy) to
    image surface at destination coordinates (dx, dy)
    '''
    vgGetPixels(dst.ptr(),dx,dy,sx,sy,width,height)

cpdef ReadPixels(data, VGint dataStride, VGImageFormat dataFormat,
                  VGint sx, VGint sy, VGint width, VGint height):
    '''
    Copies a rectangle area of pixels of size (width,height)
    from given data buffer at source coordinates (sx,sy) to
    window surface at destination coordinates (dx,dy)
    '''
    cdef object [unsigned char, ndim=1] imgbuffer = data
    cdef unsigned char *c_data
    cdef int i, datasize
    
    try:
        datasize = len(data)
        c_data = <unsigned char *>malloc(datasize * sizeof(unsigned char))
            
        vgReadPixels(c_data,dataStride,dataFormat,sx,sy,width,height)
        
        for i in range(datasize):
            imgbuffer[i] = c_data[i]
            
    finally:
        if c_data != NULL:
            free(c_data)

cpdef CopyPixels(VGint dx, VGint dy, VGint sx, VGint sy, VGint width, VGint height):
    '''
    Copies a rectangle area of pixels of size (width,height)
    from window surface at source coordinates (sx,sy) to
    windows surface at destination cordinates (dx,dy)
    '''
    vgCopyPixels(dx,dy,sx,sy,width,height)