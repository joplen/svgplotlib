# -*- coding: utf-8 -*-
'''
To improve the hinting of the fonts, this code uses a hack
presented here:

http://antigrain.com/research/font_rasterization/index.html

The idea is to limit the effect of hinting in the x-direction, while
preserving hinting in the y-direction.  Since freetype does not
support this directly, the dpi in the x-direction is set higher than
in the y-direction, which affects the hinting grid.  Then, a global
transform is placed on the font to shrink it back to the desired
size.  While it is a bit surprising that the dpi setting affects
hinting, whereas the global transform does not, this is documented
behavior of freetype, and therefore hopefully unlikely to change.
The freetype 2 tutorial says:

  NOTE: The transformation is applied to every glyph that is
  loaded through FT_Load_Glyph and is completely independent of
  any hinting process. This means that you won't get the same
  results if you load a glyph at the size of 24 pixels, or a glyph
  at the size at 12 pixels scaled by 2 through a transform,
  because the hints will have been computed differently (except
  you have disabled hints).

This hack is enabled only when VERTICAL_HINTING is defined, and will
only be effective when load_char and set_text are called with 'flags=
LOAD_DEFAULT', which is the default.
'''
import sys

cimport cpython.buffer
from libc.stdlib cimport malloc, free
from libc.string cimport memset
from freetypeLib cimport *

# Constants
DEF HORIZ_HINTING = 8

cdef enum:
    MOVETO, LINETO, CURVE3, CURVE4, ENDPOLY
    
class FontError(BaseException):
    ERROR = (
        'OK',
        'Cannot open resource',
        'Unknown file format',
        'Invalid file format',
        'Invalid FreeType version',
        'Module version is too low',
        'Invalid argument',
    )
    def __init__(self, msg):
        self.msg = msg
        
    def __str__(self):
        args = (self.__class__.__name__, self.msg)
        return "%s(%s)" % args

cdef class GlyphRef
cdef class Glyph

cdef class FT2Image

# public constants
LOAD_NO_HINTING = FT_LOAD_NO_HINTING

cdef class FT2Font:
    '''
    Create font object from filename and sets
    default size at 12 pt at 72dpi.
    
    The following global font attributes are defined:
     - num_faces              number of faces in file
     - face_flags             face flags  (int type); see the ft2font constants
     - style_flags            style flags  (int type); see the ft2font constants
     - num_glyphs             number of glyphs in the face
     - family_name            face family name
     - style_name             face syle name
     - num_fixed_sizes        number of bitmap in the face
     - scalable               face is scalable
        
    The following are available, if scalable is true:
     - bbox                   face global bounding box (xmin, ymin, xmax, ymax)
     - units_per_EM           number of font units covered by the EM
     - ascender               ascender in 26.6 units
     - descender              descender in 26.6 units
     - height                 height in 26.6 units; used to compute a default
                              line spacing (baseline-to-baseline distance)
     - max_advance_width      maximum horizontal cursor advance for all glyphs
     - max_advance_height     same for vertical layout
     - underline_position     vertical position of the underline bar
     - underline_thickness    vertical thickness of the underline
     - postscript_name        PostScript name of the font
    '''
    cdef FT_Library lib
    cdef FT_Face face
    cdef readonly object fname
    cdef readonly list glyphs
    
    def __cinit__(self, fname, int idx = 0):
        cdef FT_Error err
        
        err = FT_Init_FreeType(&self.lib)
        if err:
            raise FontError(FontError.ERROR[err])
        
        self.fname = fname
        err = FT_New_Face(self.lib, fname, idx, &self.face)
        if err:
            raise FontError(FontError.ERROR[err])
        
        # set a default fontsize 12 pt at 72dpi
        err = FT_Set_Char_Size(self.face, 12 * 64, 0, 72 * HORIZ_HINTING, 72)
        cdef FT_Matrix transform = FT_Matrix(65536 / HORIZ_HINTING, 0, 0, 65536)
        FT_Set_Transform(self.face, &transform, NULL)
        if err:
            raise FontError('Could not set font size')
    
    def __init__(self, fname, int idx = 0):
        self.glyphs = []
        
    def __dealloc__(self):
        if self.face != NULL:
            FT_Done_Face(self.face)
            
        if self.lib != NULL:
            FT_Done_FreeType(self.lib)
    
    def __str__(self):
        return "Font(fname='%s')" % self.fname
    
    property postscript_name:
        def __get__(self):
            cdef char *ps_name
            ps_name = FT_Get_Postscript_Name(self.face)
            if ps_name == NULL:
                return 'UNAVAILABLE'
            else:
                return ps_name
    
    property family_name:
        def __get__(self):
            if self.face.family_name == NULL:
                return 'UNAVAILABLE'
            else:
                return self.face.family_name
    
    property style_name:
        def __get__(self):
            if self.face.style_name == NULL:
                return 'UNAVAILABLE'
            else:
                return self.face.style_name
    
    property num_faces:
        def __get__(self):
            return self.face.num_faces
    
    property face_flags:
        def __get__(self):
            return self.face.face_flags
    
    property style_flags:
        def __get__(self):
            return self.face.style_flags
            
    property num_glyphs:
        def __get__(self):
            return self.face.num_glyphs
    
    property num_fixed_sizes:
        def __get__(self):
            return self.face.num_fixed_sizes
    
    property num_charmaps:
        def __get__(self):
            return self.face.num_charmaps
    
    property scalable:
        def __get__(self):
            return bool(self.face.face_flags & FT_FACE_FLAG_SCALABLE)
    
    property units_per_EM:
        def __get__(self):
            if self.face.face_flags & FT_FACE_FLAG_SCALABLE:
                return self.face.units_per_EM
            else:
                raise FontError('Font not scalable')
    
    property bbox:
        def __get__(self):
            if self.face.face_flags & FT_FACE_FLAG_SCALABLE:
                return (self.face.bbox.xMin,
                         self.face.bbox.yMin,
                         self.face.bbox.xMax,
                         self.face.bbox.yMax)
            else:
                raise FontError('Font not scalable')
    
    property ascender:
        def __get__(self):
            if self.face.face_flags & FT_FACE_FLAG_SCALABLE:
                return self.face.ascender
            else:
                raise FontError('Font not scalable')
    
    property descender:
        def __get__(self):
            if self.face.face_flags & FT_FACE_FLAG_SCALABLE:
                return self.face.descender
            else:
                raise FontError('Font not scalable')
    
    property max_advance_width:
        def __get__(self):
            if self.face.face_flags & FT_FACE_FLAG_SCALABLE:
                return self.face.max_advance_width
            else:
                raise FontError('Font not scalable')
    
    property max_advance_height:
        def __get__(self):
            if self.face.face_flags & FT_FACE_FLAG_SCALABLE:
                return self.face.max_advance_height
            else:
                raise FontError('Font not scalable')
    
    property underline_position:
        def __get__(self):
            if self.face.face_flags & FT_FACE_FLAG_SCALABLE:
                return self.face.underline_position
            else:
                raise FontError('Font not scalable')
    
    property underline_thickness:
        def __get__(self):
            if self.face.face_flags & FT_FACE_FLAG_SCALABLE:
                return self.face.underline_thickness
            else:
                raise FontError('Font not scalable')

    cpdef set_size(self, double ptsize, double dpi = 72):
        '''
        Set the point size and dpi of the text.
        '''
        cdef FT_Error err = FT_Set_Char_Size(self.face,
                                             <long>(ptsize * 64),
                                             0,
                                             <unsigned int>(dpi * HORIZ_HINTING),
                                             <unsigned int>dpi)
                                             
        cdef FT_Matrix transform = FT_Matrix(65536 / HORIZ_HINTING, 0, 0, 65536)
        FT_Set_Transform(self.face, &transform, NULL)
        
        if err:
            raise FontError('Could not set font size')
    
    cpdef set_charmap(self, int i):
        '''
        Make the i-th charmap current
        '''
        if i >= self.face.num_charmaps:
            raise FontError('i exceeds the available number of char maps')
        
        cdef FT_CharMap charmap = self.face.charmaps[i]
        
        if FT_Set_Charmap(self.face, charmap):
            raise FontError('Could not set the charmap')
        
    cpdef set_text(self, unicode text, double angle  = 0., long flags = FT_LOAD_FORCE_AUTOHINT):
        '''
        Set the text string and angle.
        You must call this before draw_glyphs_to_bitmap
        A sequence of x,y positions is returned
        '''
        cdef GlyphRef thisGlyph
        cdef FT_Error error
        cdef FT_Matrix matrix
        cdef FT_Vector delta, pen
        cdef FT_UInt glyph_index, previous = 0
        cdef bint use_kerning = self.face.face_flags & FT_FACE_FLAG_KERNING
        
        # clear old data
        self.glyphs = []
        
        angle = angle / 360. * 2 * 3.14159265359
        
        # this computes width and height in subpixels so we have to divide by 64
        matrix = FT_Matrix(
            <FT_Fixed>(cos(angle)   * 65536),
            <FT_Fixed>(-sin(angle)  * 65536),
            <FT_Fixed>(sin(angle)   * 65536),
            <FT_Fixed>(cos(angle)   * 65536),
        )
        
        pen.x = 0
        pen.y = 0
        xys = []
        
        for c in text:
            glyph_index = FT_Get_Char_Index(self.face, <FT_ULong>ord(c))
            
            if use_kerning and previous and glyph_index:
                FT_Get_Kerning(self.face, previous, glyph_index,
                               FT_KERNING_DEFAULT, &delta)
            
                pen.x += delta.x / HORIZ_HINTING
            
            error = FT_Load_Glyph(self.face, glyph_index, flags)
            if error:
                print >>sys.stderr, 'Failed loading glyph ', glyph_index
                continue
            
            thisGlyph = GlyphRef(self, glyph_index)
            error = FT_Get_Glyph(self.face.glyph, &thisGlyph.glyph)
            if error:
                print >>sys.stderr, 'Failed loading glyph ', glyph_index
                continue
            
            # advance pen
            error = FT_Glyph_Transform(thisGlyph.glyph, NULL, &pen)
            xys.append((pen.x, pen.y))
            pen.x += self.face.glyph.advance.x
        
            previous = glyph_index
            self.glyphs.append(thisGlyph)
        
        # now apply the rotation
        for thisGlyph in self.glyphs:
            FT_Glyph_Transform(thisGlyph.glyph, &matrix, NULL)
        
        return xys
    
    cdef FT_BBox compute_string_bbox(self):
        cdef GlyphRef glyph
        cdef FT_BBox glyph_bbox, bbox
        cdef int right_side = 0
        
        # initialize string bbox to "empty" values
        bbox.xMin = bbox.yMin = 32000;
        bbox.xMax = bbox.yMax = -32000;
        
        for glyph in self.glyphs:
            FT_Glyph_Get_CBox(glyph.glyph, FT_GLYPH_BBOX_SUBPIXELS, &glyph_bbox)
            
            if glyph_bbox.xMin < bbox.xMin:
                bbox.xMin = glyph_bbox.xMin
                
            if glyph_bbox.yMin < bbox.yMin:
                bbox.yMin = glyph_bbox.yMin
                
            if glyph_bbox.xMin == glyph_bbox.xMax:
                right_side += glyph.glyph.advance.x >> 10
                if right_side > bbox.xMax:
                    bbox.xMax = right_side
                    
            else:
                if glyph_bbox.xMax > bbox.xMax:
                    bbox.xMax = glyph_bbox.xMax
            
            if glyph_bbox.yMax > bbox.yMax:
                bbox.yMax = glyph_bbox.yMax
        
        if bbox.xMin > bbox.xMax:
            bbox.xMin = 0
            bbox.yMin = 0
            bbox.xMax = 0
            bbox.yMax = 0
        
        return bbox
    
    cpdef load_char(self, FT_UInt charcode, long flags = FT_LOAD_FORCE_AUTOHINT):
        '''
        Load character with charcode in current fontfile and set glyph.
        The flags argument can be a bitwise-or of the LOAD_XXX constants.
        Return value is a Glyph object, with attributes
         - width          # glyph width
         - height         # glyph height
         - bbox           # the glyph bbox (xmin, ymin, xmax, ymax)
         - horiBearingX   # left side bearing in horizontal layouts
         - horiBearingY   # top side bearing in horizontal layouts
         - horiAdvance    # advance width for horizontal layout
         - vertBearingX   # left side bearing in vertical layouts
         - vertBearingY   # top side bearing in vertical layouts
         - vertAdvance    # advance height for vertical layout
        '''
        cdef GlyphRef glyphRef
        cdef Glyph glyph
        cdef FT_Error error
        cdef FT_UInt glyph_index
        
        glyph_index = FT_Get_Char_Index(self.face, charcode)
        
        error = FT_Load_Char(self.face, charcode, flags)
        if error:
            raise FontError("Could not load charcode %d" % charcode)
        
        glyphRef = GlyphRef(self, glyph_index)
        error = FT_Get_Glyph(self.face.glyph, &glyphRef.glyph)
        if error:
            raise FontError("Failed loading glyph %d" % charcode)
        
        self.glyphs.append(glyphRef)
        
        glyph = Glyph(self)
        error = FT_Get_Glyph(self.face.glyph, &glyph.glyph)
        if error:
            raise FontError("Failed loading glyph %d" % charcode)
        
        glyph.setGlyph(self.face, glyph_index)
        
        return glyph
    
    cpdef load_glyph(self, FT_UInt glyph_index, long flags = FT_LOAD_FORCE_AUTOHINT):
        '''
        Load character with glyphindex in current fontfile and set glyph.
        The flags argument can be a bitwise-or of the LOAD_XXX constants.
        Return value is a Glyph object, with attributes
         - width          # glyph width
         - height         # glyph height
         - bbox           # the glyph bbox (xmin, ymin, xmax, ymax)
         - horiBearingX   # left side bearing in horizontal layouts
         - horiBearingY   # top side bearing in horizontal layouts
         - horiAdvance    # advance width for horizontal layout
         - vertBearingX   # left side bearing in vertical layouts
         - vertBearingY   # top side bearing in vertical layouts
         - vertAdvance    # advance height for vertical layout
        '''
        cdef GlyphRef glyphRef
        cdef Glyph glyph
        cdef FT_Error error
        
        error = FT_Load_Glyph(self.face, glyph_index, flags)
        if error:
            raise FontError("Could not load glyph_index %d" % glyph_index)
        
        glyphRef = GlyphRef(self, glyph_index)
        error = FT_Get_Glyph(self.face.glyph, &glyphRef.glyph)
        if error:
            raise FontError("Failed loading glyph %d" % glyph_index)
        
        self.glyphs.append(glyphRef)
        
        glyph = Glyph(self)
        error = FT_Get_Glyph(self.face.glyph, &glyph.glyph)
        if error:
            raise FontError("Failed loading glyph %d" % glyph_index)
        
        glyph.setGlyph(self.face, glyph_index)
        
        return glyph
        
    cpdef get_width_height(self):
        '''
        Get the width and height in 26.6 subpixels of the current string set by
        set_text The rotation of the string is accounted for. To get width and
        height in pixels, divide these values by 64
        '''
        cdef FT_BBox bbox = self.compute_string_bbox()
    
        return bbox.xMax - bbox.xMin, bbox.yMax - bbox.yMin
    
    cpdef double get_descent(self):
        '''
        Get the descent of the current string set by set_text in 26.6 subpixels.
        The rotation of the string is accounted for.  To get the descent
        in pixels, divide this value by 64.
        '''
        cdef FT_BBox bbox = self.compute_string_bbox()
        
        return -bbox.yMin
    
    cpdef double get_kerning(self, FT_UInt left, FT_UInt right, FT_UInt mode = FT_KERNING_DEFAULT):
        '''
        Get the kerning between left char and right glyph indices
        mode is a kerning mode constant:
        
         - KERNING_DEFAULT  : Return scaled and grid-fitted kerning distances
         - KERNING_UNFITTED : Return scaled but un-grid-fitted kerning distances
         - KERNING_UNSCALED : Return the kerning vector in original font units
        '''
        cdef FT_Vector delta
        
        if not self.face.face_flags & FT_FACE_FLAG_KERNING:
            return 0.
        
        if not FT_Get_Kerning(self.face, left, right, mode, &delta):
            return delta.x / HORIZ_HINTING
        
        return 0.
    
    cpdef FT2Image draw_glyphs_to_bitmap(self):
        '''
        Draw the glyphs that were loaded by set_text to the bitmap
        The bitmap size will be automatically set to include the glyphs
        '''
        cdef GlyphRef glyph
        cdef FT_BitmapGlyph bitmap
        cdef FT_Int x, y
        
        cdef FT_BBox bbox, string_bbox = self.compute_string_bbox()
        
        cdef size_t width = (string_bbox.xMax - string_bbox.xMin) / 64 + 2
        cdef size_t height = (string_bbox.yMax - string_bbox.yMin) / 64 + 2
    
        cdef FT2Image image = FT2Image(width, height)
        
        for glyph in self.glyphs:
            FT_Glyph_Get_CBox(glyph.glyph, FT_GLYPH_BBOX_PIXELS, &bbox)
            
            if FT_Glyph_To_Bitmap(&glyph.glyph, FT_RENDER_MODE_NORMAL, NULL, 1):
                raise FontError("Could not convert glyph to bitmap")
            
            bitmap = <FT_BitmapGlyph>glyph.glyph
            
            # now, draw to our target surface (convert position)
            # bitmap left and top in pixel, string bbox in subpixel
            x = <FT_Int>(bitmap.left - (string_bbox.xMin / 64.))
            y = <FT_Int>((string_bbox.yMax / 64.) - bitmap.top + 1)
            
            image.draw_bitmap(&bitmap.bitmap, x, y)
            
        return image
    
    cpdef get_xys(self):
        '''
        Get the xy locations of the current glyphs
        '''
        cdef GlyphRef glyph
        cdef FT_BitmapGlyph bitmap
        cdef FT_Int x, y
        
        cdef FT_BBox bbox, string_bbox = self.compute_string_bbox()
        
        xys = []
        for glyph in self.glyphs:
            FT_Glyph_Get_CBox(glyph.glyph, FT_GLYPH_BBOX_PIXELS, &bbox)
            
            if FT_Glyph_To_Bitmap(&glyph.glyph, FT_RENDER_MODE_NORMAL, NULL, 1):
                raise FontError("Could not convert glyph to bitmap")
            
            bitmap = <FT_BitmapGlyph>glyph.glyph
            
            x = <FT_Int>(bitmap.left - (string_bbox.xMin / 64.))
            y = <FT_Int>((string_bbox.yMax / 64.) - bitmap.top + 1)
            
            xys.append((imax(0, x), imax(0, y)))
        
        return tuple(xys)
    
    cpdef draw_glyph_to_bitmap(self, FT2Image image, long x, long y, Glyph glyph):
        '''
        Draw a single glyph to the bitmap at pixel locations x,y
        Note it is your responsibility to set up the bitmap manually
        with set_bitmap_size(w,h) before this call is made.
        
        If you want automatic layout, use set_text in combinations with
        draw_glyphs_to_bitmap.  This function is intended for people who
        want to render individual glyphs at precise locations, eg, a
        a glyph returned by load_char
        '''
        cdef FT_BitmapGlyph bitmap
        
        if FT_Glyph_To_Bitmap(&glyph.glyph, FT_RENDER_MODE_NORMAL, NULL, 1):
                raise FontError("Could not convert glyph to bitmap")
            
        bitmap = <FT_BitmapGlyph>glyph.glyph
        
        image.draw_bitmap(&bitmap.bitmap, x + bitmap.left, y)
        
    cpdef get_glyph_name(self, FT_UInt index):
        '''
        Retrieves the ASCII name of a given glyph in a face.
        '''
        cdef char buffer[128]
        
        if not self.face.face_flags & FT_FACE_FLAG_GLYPH_NAMES:
            raise FontError("Face has no glyph names")
        
        if FT_Get_Glyph_Name(self.face, index, buffer, 128):
            raise FontError("Could not get glyph names.")
        
        return str(buffer)
    
    cpdef get_charmap(self):
        '''
        Returns a dictionary that maps the character codes of the selected charmap
        (Unicode by default) to their corresponding glyph indices.
        '''
        cdef FT_ULong code
        cdef FT_UInt index
        
        charmap = {}
        code = FT_Get_First_Char(self.face, &index)
        while index != 0:
            charmap[<long>code] = <int>index
            code = FT_Get_Next_Char(self.face, code, &index)
            
        return charmap
    
    cpdef get_sfnt_table(self, name):
        '''
        Return one of the following SFNT tables: head, maxp, OS/2, hhea,
        vhea, post, or pclt.
        '''
        cdef int tag
        cdef void *table
        cdef TT_PCLT *t
        
        tags = "head", "maxp", "OS/2", "hhea", "vhea", "post", "pclt"
        tag = tags.index(name)
        
        table = FT_Get_Sfnt_Table(self.face, <FT_Sfnt_Tag>tag)
        if table == NULL:
            return
        
        if tag == 6:
            # pclt
            t = <TT_PCLT *>table;
            
            tt_pclt = dict(
                version = (<FT_UShort>(t.Version >> 16), <FT_UShort>t.Version),
                fontNumber = <long>t.FontNumber,
                pitch = <short>t.Pitch,
                xHeight = <short>t.xHeight,
                style = <short>t.Style,
                typeFamily = <short>t.TypeFamily,
                capHeight = <short>t.CapHeight,
                symbolSet = <short>t.SymbolSet,
                symbolSet = <short>t.SymbolSet,
                typeFace = (<char *>t.TypeFace)[:15],
                characterComplement = (<char *>t.CharacterComplement)[:7],
                filename = (<char *>t.FileName)[:5],
                strokeWeight = <int>t.StrokeWeight,
                widthType = <int>t.WidthType,
                serifStyle = <int>t.SerifStyle,
            )

            return tt_pclt
        else:
            raise NotImplementedError("Missing support for '%s'" % name)
                          
cdef class GlyphRef:
    cdef FT2Font font
    cdef FT_Glyph glyph
    cdef readonly FT_ULong glyph_index
    
    def __cinit__(self, FT2Font font, FT_ULong glyph_index):
        self.font = font
        self.glyph_index = glyph_index
        self.glyph = <FT_Glyph>malloc(sizeof(FT_GlyphRec))
        
    def __dealloc__(self):
        if self.glyph != NULL:
            free(self.glyph)
            
    def __str__(self):
        return self.__repr__()
    
    def __repr__(self):
        args = (self.font.fname, self.glyph_index)
        return "GlyphRef(fname='%s', glyph_index=%d)" % args

cdef class Glyph:
    cdef FT2Font font
    cdef FT_Glyph glyph
    cdef FT_BBox _bbox
    
    cdef readonly FT_Pos  width
    cdef readonly FT_Pos  height

    cdef readonly FT_Pos  horiBearingX
    cdef readonly FT_Pos  horiBearingY
    cdef readonly FT_Pos  horiAdvance
    cdef readonly FT_Fixed linearHoriAdvance
    cdef readonly FT_Pos  vertBearingX
    cdef readonly FT_Pos  vertBearingY
    cdef readonly FT_Pos  vertAdvance
    
    cdef readonly tuple path
    cdef readonly FT_ULong glyph_index
    cdef readonly bint valid
    
    def __cinit__(self, FT2Font font):
        self.font = font
        self.glyph_index = -1
        self.glyph = <FT_Glyph>malloc(sizeof(FT_GlyphRec))
        self.valid = False
        
    def __dealloc__(self):
        if self.glyph != NULL:
            free(self.glyph)
            
    def __str__(self):
        return self.__repr__()
    
    def __repr__(self):
        args = (self.font.fname, self.glyph_index)
        return "Glyph(fname='%s', glyph_index=%d)" % args
    
    property bbox:
        def __get__(self):
            if not self.valid:
                raise FontError('Glyph not valid')
            
            return (self._bbox.xMin,
                     self._bbox.yMin,
                     self._bbox.xMax,
                     self._bbox.yMax)
    
    cdef list get_path(self, FT_Face face, bint flip_y = False):
        '''
        get the glyph as a path, a list of (COMMAND, *args) as desribed in matplotlib.path
        this code is from agg's decompose_ft_outline with minor modifications
        '''
        cdef FT_Outline outline = face.glyph.outline
        cdef FT_Vector v_last, v_control, v_start
        cdef FT_Vector vec, vec1, vec2, v_middle
        cdef FT_Vector *point, *limit
        cdef double x, y
        cdef double xctl, yctl, xto, yto
        cdef double xctl1, yctl1, xctl2, yctl2
        cdef char *tags
        cdef bint closepoly, cont

        cdef int n          # index of contour in outline
        cdef int first      # index of first point in contour
        cdef int last       # index of last point in contour
        cdef char tag       # current point's state

        path = []
        
        first = 0
        for n in range(outline.n_contours):
            last  = outline.contours[n]
            limit = outline.points + last
            
            v_start = outline.points[first]
            v_last  = outline.points[last]
            
            v_control = v_start
            
            point = outline.points + first
            tags  = outline.tags  + first
            tag   = FT_CURVE_TAG(tags[0])
            
            # A contour cannot start with a cubic control point!
            if tag == FT_CURVE_TAG_CUBIC:
                return []
            
            # check first point to determine origin
            if tag == FT_CURVE_TAG_CONIC:
                # first point is conic control. Yes, this happens.
                if FT_CURVE_TAG(outline.tags[last]) == FT_CURVE_TAG_ON:
                    # start at last point if it is on the curve
                    v_start = v_last
                    limit -= 1
                else:
                    # if both first and last points are conic,
                    # start at their middle and record its position
                    # for closure
                    v_start.x = (v_start.x + v_last.x) / 2
                    v_start.y = (v_start.y + v_last.y) / 2
                    
                    v_last = v_start
                
                point -= 1
                tags -= 1
            
            x = conv(v_start.x);
            y = -conv(v_start.y) if flip_y else conv(v_start.y)
            path.append((MOVETO, x, y))
            
            while point < limit:
                point += 1
                tags += 1
                closepoly = True
                
                tag = FT_CURVE_TAG(tags[0])
                
                if tag == FT_CURVE_TAG_ON:
                    # emit a single line_to
                    x = conv(point.x)
                    y = -conv(point.y) if flip_y else conv(point.y)
                    path.append((LINETO, x, y))
                    continue
                
                elif tag == FT_CURVE_TAG_CONIC:
                    # consume conic arcs
                    v_control.x = point.x
                    v_control.y = point.y
                    
                    cont = False
                    while point < limit:
                        point += 1
                        tags += 1
                        tag = FT_CURVE_TAG(tags[0])
                        
                        vec.x = point.x
                        vec.y = point.y
                        
                        if tag == FT_CURVE_TAG_ON:
                            xctl = conv(v_control.x)
                            yctl = -conv(v_control.y) if flip_y else conv(v_control.y)
                            xto = conv(vec.x)
                            yto = -conv(vec.y) if flip_y else conv(vec.y)
                            path.append((CURVE3, xctl, yctl, xto, yto))
                            cont = True
                            break
                        
                        else:
                            if tag != FT_CURVE_TAG_CONIC:
                                return []
                            
                            v_middle.x = (v_control.x + vec.x) / 2
                            v_middle.y = (v_control.y + vec.y) / 2
                            
                            xctl = conv(v_control.x)
                            yctl = -conv(v_control.y) if flip_y else conv(v_control.y)
                            xto = conv(v_middle.x)
                            yto = -conv(v_middle.y) if flip_y else conv(v_middle.y)
                            path.append((CURVE3, xctl, yctl, xto, yto))
                            
                            v_control = vec
                    
                    # continue from FT_CURVE_TAG_ON?
                    if cont:
                        continue
                        
                    xctl = conv(v_control.x)
                    yctl = -conv(v_control.y) if flip_y else conv(v_control.y)
                    xto = conv(v_start.x)
                    yto = -conv(v_start.y) if flip_y else conv(v_start.y)
                    path.append((CURVE3, xctl, yctl, xto, yto))
                    
                    closepoly = False
                
                else:
                    # FT_CURVE_TAG_CUBIC
                    if point + 1 > limit or FT_CURVE_TAG(tags[1]) != FT_CURVE_TAG_CUBIC:
                        return []
                    
                    vec1.x = point[0].x
                    vec1.y = point[0].y
                    vec2.x = point[1].x
                    vec2.y = point[1].y
                    
                    point += 2
                    tags  += 2
                    
                    if point <= limit:
                        vec.x = point.x
                        vec.y = point.y
                        
                        xctl1 = conv(vec1.x)
                        yctl1 = -conv(vec1.y) if flip_y else conv(vec1.y)
                        xctl2 = conv(vec2.x)
                        yctl2 = -conv(vec2.y) if flip_y else conv(vec2.y)
                        xto = conv(vec.x)
                        yto = -conv(vec.y) if flip_y else conv(vec.y)
                        path.append((CURVE4, xctl1, yctl1, xctl2, yctl2, xto, yto))
                        continue
                    
                    xctl1 = conv(vec1.x)
                    yctl1 = -conv(vec1.y) if flip_y else conv(vec1.y)
                    xctl2 = conv(vec2.x)
                    yctl2 = -conv(vec2.y) if flip_y else conv(vec2.y)
                    xto = conv(v_start.x)
                    yto = -conv(v_start.y) if flip_y else conv(v_start.y)
                    path.append((CURVE4, xctl1, yctl1, xctl2, yctl2, xto, yto))
                    closepoly = False
            
            if closepoly:
                path.append((ENDPOLY, 0))
            
            first = last + 1
                
        return path
        
        
    cdef setGlyph(self, FT_Face face, FT_ULong glyph_index):
        # find bounding box
        FT_Glyph_Get_CBox(self.glyph, FT_GLYPH_BBOX_SUBPIXELS, &self._bbox)
        
        # save metrics
        self.width = face.glyph.metrics.width / HORIZ_HINTING
        self.height = face.glyph.metrics.height
        self.horiBearingX = face.glyph.metrics.horiBearingX / HORIZ_HINTING
        self.horiBearingY = face.glyph.metrics.horiBearingY
        self.horiAdvance = face.glyph.metrics.horiAdvance
        self.linearHoriAdvance = face.glyph.linearHoriAdvance / HORIZ_HINTING
        self.vertBearingX = face.glyph.metrics.vertBearingX
        self.vertBearingY = face.glyph.metrics.vertBearingY
        self.vertAdvance = face.glyph.metrics.vertAdvance
        
        # build path
        self.path = tuple(self.get_path(face))
        
        self.glyph_index = glyph_index
        self.valid = True
        
cdef class FT2Image:
    cdef unsigned char *_buffer
    cdef readonly bint isDirty
    cdef readonly unsigned long width
    cdef readonly unsigned long height
    
    # buffer interface
    cdef Py_ssize_t __shape[2]
    cdef Py_ssize_t __strides[2]
    cdef Py_ssize_t __suboffsets[2]
    cdef __cythonbufferdefaults__ = {"ndim": 2, "mode": "c"}
    
    def __cinit__(self, unsigned long width, unsigned long height):
        self.isDirty = True
        self.width = width
        self.height = height
        
        self._buffer = <unsigned char *>malloc(width*height*sizeof(unsigned char))
        if self._buffer == NULL:
            raise RuntimeError('Could not get memory for image')
        
        memset(self._buffer, 0, width*height)
        
    def __dealloc__(self):
        if self._buffer != NULL:
            free(self._buffer)
    
    def __getbuffer__(self, Py_buffer* buffer, int flags):
        self.__shape[0] = self.height
        self.__shape[1] = self.width
        self.__strides[0] = self.width
        self.__strides[1] = 1
        
        buffer.buf = self._buffer
        buffer.obj = self
        buffer.len = self.height * self.width * sizeof(unsigned char)
        buffer.readonly = 0
        buffer.format = <char*>"B"
        buffer.ndim = 2
        buffer.shape = <Py_ssize_t *>&self.__shape
        buffer.strides = <Py_ssize_t *>&self.__strides
        buffer.suboffsets = NULL
        buffer.itemsize = sizeof(unsigned char)
        buffer.internal = NULL
    
    def __str__(self):
        return self.__repr__()
    
    def __repr__(self):
        args = (self.width, self.height)
        return "FT2Image(width = %d, height = %d)" % args
    
    def tobytes(self):
        cdef int length = self.height * self.width
        return (<char *>self._buffer)[:length]
        
    cpdef draw_rect(self, FT_ULong x0, FT_ULong y0, FT_ULong x1, FT_ULong y1):
        '''
        Draw a rect to the image.
        '''
        cdef size_t top, bottom, i, j
        
        if x0 >= self.width or x1 >= self.width or y0 >= self.height or y1 >= self.height:
            raise FontError('Rect coords outside image bounds')
        
        top = y0 * self.width
        bottom = y1 * self.width
        
        i = x0
        while i < x1 + 1:
            self._buffer[i + top] = 255
            self._buffer[i + bottom] = 255
            i += 1
        
        j = y0 + 1
        while j < y1:
            self._buffer[x0 + j*self.width] = 255
            self._buffer[x1 + j*self.width] = 255
            j += 1
        
        self.isDirty = True
    
    cpdef draw_rect_filled(self, FT_ULong x0, FT_ULong y0, FT_ULong x1, FT_ULong y1):
        '''
        Draw a filled rect to the image.
        '''
        cdef size_t i, j
        
        x0 = x0 if x0 < self.width else self.width
        y0 = y0 if y0 < self.height else self.height
        x1 = x1 if x1 < self.width else self.width
        y1 = y1 if y1 < self.height else self.height
        
        j = y0
        while j < y1 + 1:
            i = x0
            while i < x1 + 1:
                self._buffer[i + j*self.width] = 255
                i += 1
            j += 1
            
                
        self.isDirty = True
    
    cdef draw_bitmap(self, FT_Bitmap *bitmap, FT_Int x, FT_Int y):
        cdef FT_Int i, j
        cdef unsigned char *dst, *src
        
        cdef FT_Int image_width = <FT_Int>self.width
        cdef FT_Int image_height = <FT_Int>self.height
        cdef FT_Int char_width =  bitmap.width
        cdef FT_Int char_height = bitmap.rows
        
        cdef FT_Int x1 = imin(imax(x, 0), image_width)
        cdef FT_Int y1 = imin(imax(y, 0), image_height)
        cdef FT_Int x2 = imin(imax(x + char_width, 0), image_width)
        cdef FT_Int y2 = imin(imax(y + char_height, 0), image_height)
        
        cdef FT_Int x_start = imax(0, -x)
        cdef FT_Int y_offset = y1 - imax(0, -y)
    
        i = y1
        while i < y2:
            dst = self._buffer + (i * image_width + x1)
            src = bitmap.buffer + (((i - y_offset) * bitmap.pitch) + x_start)
            
            j = x1
            while j < x2:
                dst[0] |= src[0]
                j += 1
                dst += 1
                src += 1
            
            i += 1
        
        self.isDirty = True