# -*- coding: utf-8 -*-
# This is code is commercial software.
# Copyright 2011 by Runar Tenfjord, Tenko.
#
from cython.view cimport array
    
cdef extern from "cairo.h":
    int CAIRO_STATUS_SUCCESS
    
    int CAIRO_FORMAT_ARGB32
    int CAIRO_FORMAT_RGB24
    int CAIRO_FORMAT_A8
    int CAIRO_FORMAT_A1
    int CAIRO_FORMAT_RGB16_565
    
    int CAIRO_OPERATOR_CLEAR
    
    cdef struct _cairo:
        pass
    
    cdef struct _cairo_surface:
        pass
    
    ctypedef _cairo_surface cairo_surface_t
    ctypedef _cairo cairo_t
    ctypedef int (*cairo_write_func_t) (void *, unsigned char *, unsigned int)
    
    cairo_surface_t *cairo_image_surface_create (int    format,
                                                 int	width,
                                                 int	height)
    
    unsigned char *cairo_image_surface_get_data(cairo_surface_t *surface)

    void cairo_surface_destroy(cairo_surface_t *surface)
    
    cairo_t *cairo_create(cairo_surface_t *target)
    void cairo_destroy (cairo_t *cr)
    
    void cairo_save(cairo_t *cr)
    void cairo_restore(cairo_t *cr)
    void cairo_show_page (cairo_t *cr)
    
    void cairo_translate(cairo_t *cr, double tx, double ty)
    void cairo_scale(cairo_t *cr, double sx, double sy)
    void cairo_set_operator(cairo_t *cr, int op)
    void cairo_set_source_rgb(cairo_t *cr, double red, double green, double blue)
    void cairo_paint(cairo_t *cr)
    
    int cairo_surface_write_to_png_stream (cairo_surface_t *surface,
                                           cairo_write_func_t write_func,
                                           void	*closure)
                   

cdef extern from "svg-cairo.h":
    int SVG_CAIRO_STATUS_SUCCESS
    int SVG_CAIRO_STATUS_NO_MEMORY
    int SVG_CAIRO_STATUS_IO_ERROR
    int SVG_CAIRO_STATUS_FILE_NOT_FOUND
    int SVG_CAIRO_STATUS_INVALID_VALUE
    int SVG_CAIRO_STATUS_INVALID_CALL
    int SVG_CAIRO_STATUS_PARSE_ERROR
    
    cdef struct svg_cairo:
        pass
        
    ctypedef svg_cairo svg_cairo_t

    int svg_cairo_create(svg_cairo_t **svg_cairo)
    int svg_cairo_destroy (svg_cairo_t *svg_cairo)
    int svg_cairo_parse_buffer(svg_cairo_t *svg_cairo, char *buf, size_t count)
    void svg_cairo_get_size(svg_cairo_t  *svg_cairo,
                            unsigned int *width,
                            unsigned int *height)
    int svg_cairo_render(svg_cairo_t *svg_cairo, cairo_t *xrs)

cdef extern from "cairo-pdf.h":
    cairo_surface_t *cairo_pdf_surface_create_for_stream (cairo_write_func_t write_func,
                                                          void *closure,
                                                          double	width_in_points,
                                                          double	height_in_points)
                     
class CairoSVGError(Exception):
    pass

cdef int write_callback(void *closure, unsigned char *data, unsigned int length):
    cdef object fh = <object>closure
    
    pydata = str(data[:length])
    fh.write(pydata)
    
    return CAIRO_STATUS_SUCCESS
    
cdef class CairoSVG:
    cdef char *svgdata
    cdef svg_cairo_t *svgc
    cdef readonly unsigned int width
    cdef readonly unsigned int height
    
    def __init__(self, svgdata):
        cdef int status
        
        status = svg_cairo_create(&self.svgc)
        if status:
            raise CairoSVGError("Failed to create svg_cairo_t")
        
        if isinstance(svgdata, basestring):
            self.svgdata = svgdata
        else:
            svgdata = svgdata.read()
            self.svgdata = svgdata
        
        status = svg_cairo_parse_buffer(self.svgc, self.svgdata, len(svgdata))
        if status:
            raise CairoSVGError("Failed to parse svg data")

        svg_cairo_get_size(self.svgc, &self.width, &self.height)
    
    def __dealloc__(self):
        if self.svgc != NULL:
            svg_cairo_destroy(self.svgc)
    
    def __str__(self):
        return "CairoSVG%s" % repr(self)
    
    def __repr__(self):
        args = self.width, self.height
        return "(width = %d, height = %d)" % args
    
    def toPDF(self, object fh, int width = -1, int height = -1,
               double scale = 1.):
        cdef cairo_t *cr
        cdef cairo_surface_t *surface
        cdef unsigned char *data
        cdef double dx = 0., dy = 0.
        cdef int i, size, status
        
        if width < 0 and height < 0:
            width = <int>(self.width * scale + .5)
            height = <int>(self.height * scale + .5)
        elif width < 0:
            scale = height / <double>self.height
            width = <int>(self.width * scale + .5)
        elif height < 0:
            scale = <double>width / <double>self.width
            height = <int>(self.height * scale + .5)
        else:
            scale = min(width / <double>self.width, height / <double>self.height)
            dx = (width - <int>(self.width * scale + .5)) / 2
            dy = (height - <int>(self.height * scale + .5)) / 2
        
        surface = cairo_pdf_surface_create_for_stream(write_callback, <void *>fh,
                                                      width, height)
        
        cr = cairo_create(surface)
        
        cairo_translate (cr, dx, dy)
        cairo_scale (cr, scale, scale)

        cairo_set_source_rgb(cr, 1, 1, 1)
        
        status = svg_cairo_render(self.svgc, cr)
        if status:
            raise CairoSVGError("Failed to render svg data")
        
        cairo_show_page(cr)
        
        cairo_surface_destroy(surface)
        cairo_destroy(cr)
    
    def toPNG(self, object fh, int width = -1, int height = -1,
              double scale = 1.):
        cdef cairo_t *cr
        cdef cairo_surface_t *surface
        cdef unsigned char *data
        cdef double dx = 0., dy = 0.
        cdef int i, size, status
        
        if width < 0 and height < 0:
            width = <int>(self.width * scale + .5)
            height = <int>(self.height * scale + .5)
        elif width < 0:
            scale = height / <double>self.height
            width = <int>(self.width * scale + .5)
        elif height < 0:
            scale = <double>width / <double>self.width
            height = <int>(self.height * scale + .5)
        else:
            scale = min(width / <double>self.width, height / <double>self.height)
            dx = (width - <int>(self.width * scale + .5)) / 2
            dy = (height - <int>(self.height * scale + .5)) / 2
        
        surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, width, height)
        
        cr = cairo_create(surface)

        cairo_save (cr)
        cairo_set_operator(cr, CAIRO_OPERATOR_CLEAR);
        cairo_paint (cr)
        cairo_restore (cr)
        
        cairo_translate (cr, dx, dy)
        cairo_scale (cr, scale, scale)

        cairo_set_source_rgb(cr, 1, 1, 1)
        
        status = svg_cairo_render(self.svgc, cr)
        
        status = cairo_surface_write_to_png_stream (surface, write_callback, <void *>fh)
        
        if status:
            raise CairoSVGError("Failed to render svg data")
            
        cairo_surface_destroy(surface)
        cairo_destroy(cr)
        
    def toRGBA(self, int width = -1, int height = -1,
               double scale = 1.):
        cdef array ret
        cdef cairo_t *cr
        cdef cairo_surface_t *surface
        cdef unsigned char *data
        cdef double dx = 0., dy = 0.
        cdef int i, size, status
        
        if width < 0 and height < 0:
            width = <int>(self.width * scale + .5)
            height = <int>(self.height * scale + .5)
        elif width < 0:
            scale = height / <double>self.height
            width = <int>(self.width * scale + .5)
        elif height < 0:
            scale = <double>width / <double>self.width
            height = <int>(self.height * scale + .5)
        else:
            scale = min(width / <double>self.width, height / <double>self.height)
            dx = (width - <int>(self.width * scale + .5)) / 2
            dy = (height - <int>(self.height * scale + .5)) / 2
        
        surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, width, height)
        
        cr = cairo_create(surface)

        cairo_save (cr)
        cairo_set_operator(cr, CAIRO_OPERATOR_CLEAR);
        cairo_paint (cr)
        cairo_restore (cr)
        
        cairo_translate (cr, dx, dy)
        cairo_scale (cr, scale, scale)

        cairo_set_source_rgb(cr, 1, 1, 1)
        
        status = svg_cairo_render(self.svgc, cr)
        if status:
            raise CairoSVGError("Failed to render svg data")
        
        ret = array(
            (width*height*4,),
            itemsize=sizeof(unsigned char),
            format='B',
        )
        
        data = cairo_image_surface_get_data(surface)
        
        # BRGA to RGBA
        i = 0
        size = width*height*4
        while i < size:
            ret.data[i + 0] = data[i + 2]
            ret.data[i + 1] = data[i + 1]
            ret.data[i + 2] = data[i + 0]
            ret.data[i + 3] = data[i + 3]
            i += 4
            
        cairo_surface_destroy(surface)
        cairo_destroy(cr)
        
        return ret, width, height