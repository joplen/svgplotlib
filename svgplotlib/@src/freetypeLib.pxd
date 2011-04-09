# -*- coding: utf-8; -*-

cdef extern from "math.h":
    double sin(double x)
    double cos(double x)
    
cdef extern from "stdint.h":
   ctypedef int int32_t 
   ctypedef unsigned int uint32_t 

cdef extern from "freetype/fttypes.h":
    ctypedef int FT_Error
    ctypedef unsigned char FT_Bool
    ctypedef signed char FT_Char
    ctypedef unsigned char FT_Byte
    ctypedef signed short FT_Short
    ctypedef unsigned short FT_UShort
    ctypedef signed int FT_Int
    ctypedef unsigned int FT_UInt
    ctypedef signed long FT_Long
    ctypedef unsigned long FT_ULong
    ctypedef signed long FT_F26Dot6
    ctypedef signed long FT_Fixed
    ctypedef int32_t FT_Int32
    ctypedef uint32_t FT_UInt32
    ctypedef void*  FT_Pointer
    
    struct FT_Matrix_:
        FT_Fixed xx
        FT_Fixed xy
        FT_Fixed yx
        FT_Fixed yy
    
    ctypedef FT_Matrix_ FT_Matrix
    
cdef extern from "freetype/ftimage.h":
    ctypedef signed long FT_Pos
    struct FT_Vector_:
        FT_Pos x
        FT_Pos y
    ctypedef FT_Vector_ FT_Vector

    struct FT_Bitmap_:
        int rows
        int width
        int pitch
        unsigned char * buffer
        short num_grays
        char pixel_mode
        char palette_mode
        void * palette
    ctypedef FT_Bitmap_ FT_Bitmap

    struct FT_BBox_:
        FT_Pos xMin
        FT_Pos yMin
        FT_Pos xMax
        FT_Pos yMax
    ctypedef FT_BBox_ FT_BBox
    
    struct FT_Outline 'FT_Outline_':
        short n_contours
        short n_points
        FT_Vector* points
        char* tags
        short* contours
        int flags
  
cdef extern from "freetype/freetype.h":
    int FT_FACE_FLAG_SCALABLE
    int FT_FACE_FLAG_KERNING
    int FT_GLYPH_BBOX_SUBPIXELS
    int FT_GLYPH_BBOX_PIXELS
    int FT_FACE_FLAG_GLYPH_NAMES
    

    struct FT_Library_Rec_:
        pass
        
    ctypedef FT_Library_Rec_ * FT_Library

    FT_Error FT_Init_FreeType(FT_Library *)
    void FT_Done_FreeType(FT_Library)
    
    struct FT_CharMapRec_:
        pass
    ctypedef FT_CharMapRec_ * FT_CharMap
    
    struct  FT_Glyph_Metrics 'FT_Glyph_Metrics_':
        FT_Pos  width
        FT_Pos  height

        FT_Pos  horiBearingX
        FT_Pos  horiBearingY
        FT_Pos  horiAdvance

        FT_Pos  vertBearingX
        FT_Pos  vertBearingY
        FT_Pos  vertAdvance
  
    struct FT_GlyphSlotRec_:
        FT_Library library
        FT_GlyphSlotRec_ next
        FT_UInt reserved
        FT_Glyph_Metrics  metrics
        FT_Fixed linearHoriAdvance
        FT_Fixed linearVertAdvance
        FT_Vector advance
        FT_Bitmap bitmap
        FT_Int bitmap_left
        FT_Int bitmap_top
        FT_Outline outline
        FT_UInt num_subglyphs
        void* control_data
        long control_len
        FT_Pos lsb_delta
        FT_Pos rsb_delta
    ctypedef FT_GlyphSlotRec_ * FT_GlyphSlot
    
    struct FT_Face_Rec_:
        FT_Long num_faces
        FT_Long face_index
        FT_Long face_flags
        FT_Long style_flags
        FT_Long num_glyphs
        char * family_name
        char * style_name
        FT_Int num_fixed_sizes
        FT_Int num_charmaps
        FT_CharMap *charmaps
        #FT_Generic generic  
        FT_BBox bbox
        FT_UShort units_per_EM
        FT_Short ascender
        FT_Short descender
        FT_Short height
        FT_Short max_advance_width
        FT_Short max_advance_height
        FT_Short underline_position
        FT_Short underline_thickness
        FT_GlyphSlot glyph
        #FT_Size size
        FT_CharMap charmap
        
    ctypedef FT_Face_Rec_ * FT_Face
    
    enum  FT_Kerning_Mode 'FT_Kerning_Mode_':
        FT_KERNING_DEFAULT  = 0,
        FT_KERNING_UNFITTED,
        FT_KERNING_UNSCALED
  
    enum FT_Render_Mode 'FT_Render_Mode_':
        FT_RENDER_MODE_NORMAL,
        FT_RENDER_MODE_LIGHT,
        FT_RENDER_MODE_MONO,
        FT_RENDER_MODE_LCD,
        FT_RENDER_MODE_LCD_V,
        FT_RENDER_MODE_MAX

    enum:
        FT_LOAD_DEFAULT, FT_LOAD_NO_SCALE, FT_LOAD_NO_HINTING, FT_LOAD_RENDER,
        FT_LOAD_NO_BITMAP, FT_LOAD_VERTICAL_LAYOUT, FT_LOAD_FORCE_AUTOHINT,
        FT_LOAD_CROP_BITMAP, FT_LOAD_PEDANTIC,
        FT_LOAD_IGNORE_GLOBAL_ADVANCE_WIDTH, FT_LOAD_NO_RECURSE,
        FT_LOAD_IGNORE_TRANSFORM, FT_LOAD_MONOCHROME, FT_LOAD_LINEAR_DESIGN,
        FT_LOAD_NO_AUTOHINT

    FT_Error FT_New_Face(FT_Library, char *, FT_Long, FT_Face *)
    FT_Error FT_Done_Face(FT_Face face)
    
    FT_ULong FT_Get_First_Char(FT_Face face, FT_UInt *agindex)
    FT_ULong FT_Get_Next_Char(FT_Face face, FT_ULong char_code, FT_UInt *agindex )
                    
    char *FT_Get_Postscript_Name(FT_Face face)
    FT_Error FT_Set_Charmap(FT_Face face, FT_CharMap charmap)
    FT_Error FT_Get_Kerning(FT_Face face, FT_UInt left_glyph, FT_UInt right_glyph,
                            FT_UInt kern_mode, FT_Vector *akerning)
    
    FT_Error FT_Get_Glyph_Name(FT_Face face, FT_UInt glyph_index, FT_Pointer buffer, FT_UInt buffer_max)
    FT_Error FT_Set_Char_Size(FT_Face, FT_F26Dot6, FT_F26Dot6, FT_UInt, FT_UInt)
    FT_UInt FT_Get_Char_Index(FT_Face, FT_ULong)
    FT_Error FT_Load_Glyph(FT_Face, FT_UInt, FT_Int32)
    FT_Error FT_Load_Char(FT_Face, FT_ULong, FT_Int32)
    FT_Error FT_Render_Glyph(FT_GlyphSlot, FT_Render_Mode)
    void FT_Set_Transform(FT_Face, FT_Matrix *, FT_Vector *)
    FT_UInt32 * FT_Face_GetVariantsOfChar(FT_Face, FT_ULong)
    FT_Error FT_Attach_File(FT_Face, char *)
                     
cdef extern from "freetype/ftglyph.h":
    int FT_CURVE_TAG_ON
    int FT_CURVE_TAG_CONIC
    int FT_CURVE_TAG_CUBIC
    
    struct FT_GlyphRec 'FT_GlyphRec_':
        FT_Library library
        FT_Vector advance
        
    ctypedef FT_GlyphRec *FT_Glyph
    
    struct  FT_BitmapGlyphRec 'FT_BitmapGlyphRec_':
        FT_GlyphRec  root
        FT_Int       left
        FT_Int       top
        FT_Bitmap    bitmap
    
    ctypedef FT_BitmapGlyphRec *FT_BitmapGlyph
  
    FT_Error FT_Get_Glyph(FT_GlyphSlot, FT_Glyph *)
    void FT_Done_Glyph(FT_Glyph)
    FT_Error FT_Glyph_Copy(FT_Glyph, FT_Glyph *)
    FT_Error FT_Glyph_Transform(FT_Glyph, FT_Matrix *, FT_Vector *)
    void FT_Glyph_Get_CBox(FT_Glyph, FT_UInt, FT_BBox *)
    FT_Error FT_Glyph_To_Bitmap(FT_Glyph *the_glyph, FT_Int32 render_mode, 
                                FT_Vector *origin, FT_Bool destroy)

cdef extern from "freetype/tttables.h":
    enum  FT_Sfnt_Tag 'FT_Sfnt_Tag_':
        ft_sfnt_head,
        ft_sfnt_maxp,
        ft_sfnt_os2,
        ft_sfnt_hhea,
        ft_sfnt_vhea,
        ft_sfnt_post,
        ft_sfnt_pclt,
        sfnt_max
  
    void* FT_Get_Sfnt_Table(FT_Face face, FT_Sfnt_Tag tag)
    
    struct  TT_PCLT_:
        FT_Fixed   Version
        FT_ULong   FontNumber
        FT_UShort  Pitch
        FT_UShort  xHeight
        FT_UShort  Style
        FT_UShort  TypeFamily
        FT_UShort  CapHeight
        FT_UShort  SymbolSet
        FT_Char    TypeFace[16]
        FT_Char    CharacterComplement[8]
        FT_Char    FileName[6]
        FT_Char    StrokeWeight
        FT_Char    WidthType
        FT_Byte    SerifStyle
        FT_Byte    Reserved
    
    ctypedef TT_PCLT_ TT_PCLT
    
cdef inline double conv(int v):
    return v / 64.

cdef inline char FT_CURVE_TAG(char flag):
    return flag & 3

cdef inline int imax(int a, int b):
    if a < b:
        return b
    return a

cdef inline int imin(int a, int b):
    if a > b:
        return b
    return a