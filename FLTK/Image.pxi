cdef class Image:
    '''
    Fl_Image is the base class used for caching and drawing all kinds of images in FLTK.
    This class keeps track of common image data such as the pixels, colormap, 
    width, height, and depth. Virtual methods are used to provide type-specific
    image handling.

    Since the Fl_Image class does not support image drawing by itself, calling
    the draw() method results in a box with an X in it being drawn instead.
    '''
    cdef void *thisptr
        
    cpdef Image copy(self, int W = 0, int H = 0):
        '''
        Create copy of image
        '''
        cdef Fl_Image *cpy, *img = <Fl_Image *>self.thisptr
        cdef Image ret = Image.__new__(Image, None)
        
        if W == 0:
            W = img.w()
            
        if H == 0:
            H = img.h()
            
        cpy = img.copy(W,H)
        ret.thisptr = cpy
        return ret
        
    cpdef int w(self):
        '''
        The first form of the w() method returns the current
        image width in pixels.

        The second form is a protected method that sets the current
        image width.
        '''
        cdef Fl_Image *img = <Fl_Image *>self.thisptr
        return img.w()
        
    cpdef int h(self):
        '''
        The first form of the h() method returns the current
        image height in pixels.

        The second form is a protected method that sets the current
        image height.
        '''
        cdef Fl_Image *img = <Fl_Image *>self.thisptr
        return img.h()
    
    cpdef int d(self):
        '''
        The first form of the d() method returns the current
        image depth. The return value will be 0 for bitmaps, 1 for
        pixmaps, and 1 to 4 for color images.

        The second form is a protected method that sets the current
        image depth.
        '''
        cdef Fl_Image *img = <Fl_Image *>self.thisptr
        return img.d()
    
    cpdef int ld(self):
        '''
        The first form of the ld() method returns the current line data size in bytes.
        
        Line data is extra data that is included after each line of color image
        data and is normally not present.
        
        The second form is a protected method that sets the current line data
        size in bytes.
        '''
        cdef Fl_Image *img = <Fl_Image *>self.thisptr
        return img.ld()
    
    cpdef int count(self):
        '''
        The count() method returns the number of data values associated with the image.
        
        The value will be 0 for images with no associated data, 1 for bitmap and
        color images, and greater than 2 for pixmap images.
        '''
        cdef Fl_Image *img = <Fl_Image *>self.thisptr
        return img.count()

cdef class RGB_Image_(Image):
    cdef Py_ssize_t __shape[1]
    cdef Py_ssize_t __strides[1]
    cdef __cythonbufferdefaults__ = {"ndim": 1, "mode": "c"}
    
    def __len__(self):
        cdef Fl_RGB_Image *img = <Fl_RGB_Image *>self.thisptr
        return img.w()*img.h()*img.d()
        
    def __getbuffer__(self, Py_buffer* buffer, int flags):
        cdef Fl_RGB_Image *img = <Fl_RGB_Image *>self.thisptr
        cdef const_char_ptr c_data = img.data()[0]
        
        self.__shape[0] = img.w()*img.h()*img.d()
        self.__strides[0] = 1
        
        buffer.buf = <void *>c_data
        buffer.obj = self
        buffer.len = self.__shape[0]*sizeof(uchar)
        buffer.readonly = 0
        buffer.format = <char*>"B"
        buffer.ndim = 1
        buffer.shape = <Py_ssize_t *>&self.__shape[0]
        buffer.strides = <Py_ssize_t *>&self.__strides[0]
        buffer.suboffsets = NULL
        buffer.itemsize = sizeof(uchar)
        buffer.internal = NULL
        
    def __releasebuffer__(self, Py_buffer* buffer):
        pass
        
    cpdef color_average(self, Fl_Color c, float i):
        '''
        The color_average() method averages the colors in the image with the
        FLTK color value c.
        '''
        cdef Fl_RGB_Image *img = <Fl_RGB_Image *>self.thisptr
        img.color_average(c, i)
    
    cpdef inactive(self):
        '''
        The inactive() method calls color_average(FL_BACKGROUND_COLOR, 0.33f)
        to produce an image that appears grayed out.
        '''
        cdef Fl_RGB_Image *img = <Fl_RGB_Image *>self.thisptr
        img.inactive()
    
    cpdef desaturate(self):
        '''
        The desaturate() method converts an image to grayscale. 
        '''
        cdef Fl_RGB_Image *img = <Fl_RGB_Image *>self.thisptr
        img.desaturate()
    
    cpdef draw(self, int X, int Y, int W = 0, int H = 0, int cx = 0, int cy = 0):
        '''
        The draw() methods draw the image. 
        '''
        cdef Fl_RGB_Image *img = <Fl_RGB_Image *>self.thisptr
        
        if W == 0:
            W = img.w()
            
        if H == 0:
            H = img.h()
        
        img.draw(X,Y,W,H,cx,cy)
        
cdef class RGB_Image(RGB_Image_):
    def __init__(self, int W, int H, int D = 3, int LD = 0, data = None):
        cdef object [unsigned char, ndim=1] pbuffer
        cdef uchar *bits
        cdef int i
        
        assert LD == 0
        bits = <uchar *>malloc(W*H*D*sizeof(uchar))
        
        if not data is None:
            pbuffer = data
            for i in range(W*H*D):
                bits[i] = pbuffer[i]
        
        self.thisptr = new Fl_RGB_Image(bits,W,H,D,LD)
        
                    
    def __dealloc__(self):
        cdef Fl_RGB_Image *tmp
        cdef const_char_ptr c_data
        
        if self.thisptr != NULL:
            tmp = <Fl_RGB_Image *>self.thisptr
            del tmp
            
            c_data = tmp.data()[0]
            if c_data != NULL:
                free(<void *>c_data)

cdef RGBtoRGBA(int w, int h, int src_d, const_char_ptr src_data, uchar *dst_data):
    cdef int i, j, k, l, row, col, depth

    l = 0
    for row in range(h):
        i = row*w*4
        for col in range(w):
            j = i + col*4
            for depth in range(4):
                k = j + depth
                if depth >= src_d:
                    dst_data[k] = 255
                else:
                    dst_data[k] = src_data[l]
                    l += 1
        
    
cdef class PNG_Image(RGB_Image_):
    def __init__(self, char* filename):
        self.thisptr = new Fl_PNG_Image(filename)
    
    cpdef RGB_Image asRGBA(self):
        cdef RGB_Image ret
        cdef Fl_RGB_Image *src
        cdef const_char_ptr src_data
        cdef uchar *dst_data
        
        if self.d() == 4:
            return <RGB_Image>self
        
        src = <Fl_RGB_Image *>self.thisptr
        src_data = src.data()[0]
        dst_data = <uchar *>malloc(src.w()*src.h()*4*sizeof(uchar))
        
        RGBtoRGBA(src.w(), src.h(), src.d(), src_data, dst_data)
        
        ret = RGB_Image.__new__(RGB_Image, None)
        ret.thisptr = new Fl_RGB_Image(dst_data,src.w(),src.h(),4,0)
        return ret
        
cdef class JPEG_Image(RGB_Image_):
    def __init__(self, char* filename):
        self.thisptr = new Fl_JPEG_Image(filename)
    
    cpdef RGB_Image asRGBA(self):
        cdef RGB_Image ret
        cdef Fl_RGB_Image *src
        cdef const_char_ptr src_data
        cdef uchar *dst_data
        
        if self.d() == 4:
            return <RGB_Image>self
        
        src = <Fl_RGB_Image *>self.thisptr
        src_data = src.data()[0]
        dst_data = <uchar *>malloc(src.w()*src.h()*4*sizeof(uchar))
        
        RGBtoRGBA(src.w(), src.h(), src.d(), src_data, dst_data)
        
        ret = RGB_Image.__new__(RGB_Image, None)
        ret.thisptr = new Fl_RGB_Image(dst_data,src.w(),src.h(),4,0)
        return ret
        
        
        