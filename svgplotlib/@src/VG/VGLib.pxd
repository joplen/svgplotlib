# -*- coding: utf-8 -*-

cdef extern from "math.h":
    double fabs(double x)
    double sqrt(double x)
    double sin(double x)
    double cos(double x)
    double tan(double x)
    
ctypedef float               VGfloat
ctypedef char                VGbyte
ctypedef unsigned char       VGubyte
ctypedef short               VGshort
ctypedef int                 VGint
ctypedef unsigned int        VGuint
ctypedef unsigned int        VGbitfield
ctypedef void                *VGHandle

cdef extern from "vg/openvg.h":
    VGHandle VG_INVALID_HANDLE
    
    ctypedef enum VGboolean:
        pass
    
    VGboolean VG_FALSE
    VGboolean VG_TRUE
    
    ctypedef enum VGErrorCode:
        pass
        
    VGErrorCode VG_NO_ERROR
    VGErrorCode VG_BAD_HANDLE_ERROR
    VGErrorCode VG_ILLEGAL_ARGUMENT_ERROR
    VGErrorCode VG_OUT_OF_MEMORY_ERROR
    VGErrorCode VG_PATH_CAPABILITY_ERROR
    VGErrorCode VG_UNSUPPORTED_IMAGE_FORMAT_ERROR
    VGErrorCode VG_UNSUPPORTED_PATH_FORMAT_ERROR
    VGErrorCode VG_IMAGE_IN_USE_ERROR
    VGErrorCode VG_NO_CONTEXT_ERROR
    
    ctypedef enum VGParamType:
        pass
    
    # Mode settings
    VGParamType VG_MATRIX_MODE
    VGParamType VG_FILL_RULE
    VGParamType VG_IMAGE_QUALITY
    VGParamType VG_RENDERING_QUALITY
    VGParamType VG_BLEND_MODE
    VGParamType VG_IMAGE_MODE

    # Scissoring rectangles
    VGParamType VG_SCISSOR_RECTS

    # Stroke parameters
    VGParamType VG_STROKE_LINE_WIDTH
    VGParamType VG_STROKE_CAP_STYLE
    VGParamType VG_STROKE_JOIN_STYLE
    VGParamType VG_STROKE_MITER_LIMIT
    VGParamType VG_STROKE_DASH_PATTERN
    VGParamType VG_STROKE_DASH_PHASE
    VGParamType VG_STROKE_DASH_PHASE_RESET

    # Edge fill color for VG_TILE_FILL tiling mode
    VGParamType VG_TILE_FILL_COLOR 

    # Color for vgClear
    VGParamType VG_CLEAR_COLOR

    # Enable/disable alpha masking and scissoring
    VGParamType VG_MASKING
    VGParamType VG_SCISSORING

    # Pixel layout information
    VGParamType VG_PIXEL_LAYOUT
    VGParamType VG_SCREEN_LAYOUT

    # Source format selection for image filters
    VGParamType VG_FILTER_FORMAT_LINEAR
    VGParamType VG_FILTER_FORMAT_PREMULTIPLIED

    # Destination write enable mask for image filters
    VGParamType VG_FILTER_CHANNEL_MASK

    # Implementation limits (read-only)
    VGParamType VG_MAX_SCISSOR_RECTS
    VGParamType VG_MAX_DASH_COUNT
    VGParamType VG_MAX_KERNEL_SIZE
    VGParamType VG_MAX_SEPARABLE_KERNEL_SIZE
    VGParamType VG_MAX_COLOR_RAMP_STOPS
    VGParamType VG_MAX_IMAGE_WIDTH
    VGParamType VG_MAX_IMAGE_HEIGHT
    VGParamType VG_MAX_IMAGE_PIXELS
    VGParamType VG_MAX_IMAGE_BYTES
    VGParamType VG_MAX_FLOAT
    VGParamType VG_MAX_GAUSSIAN_STD_DEVIATION
    
    ctypedef enum VGRenderingQuality:
        pass
    
    VGRenderingQuality VG_RENDERING_QUALITY_NONANTIALIASED
    VGRenderingQuality VG_RENDERING_QUALITY_FASTER
    VGRenderingQuality VG_RENDERING_QUALITY_BETTER
    
    ctypedef enum VGPixelLayout:
        pass
    
    VGPixelLayout VG_PIXEL_LAYOUT_UNKNOWN
    VGPixelLayout VG_PIXEL_LAYOUT_RGB_VERTICAL
    VGPixelLayout VG_PIXEL_LAYOUT_BGR_VERTICAL
    VGPixelLayout VG_PIXEL_LAYOUT_RGB_HORIZONTAL
    VGPixelLayout VG_PIXEL_LAYOUT_BGR_HORIZONTAL
    
    ctypedef enum VGMatrixMode:
        pass
    
    VGMatrixMode VG_MATRIX_PATH_USER_TO_SURFACE
    VGMatrixMode VG_MATRIX_IMAGE_USER_TO_SURFACE
    VGMatrixMode VG_MATRIX_FILL_PAINT_TO_USER
    VGMatrixMode VG_MATRIX_STROKE_PAINT_TO_USER
    
    ctypedef enum VGMaskOperation:
        pass
    
    VGMaskOperation VG_CLEAR_MASK
    VGMaskOperation VG_FILL_MASK
    VGMaskOperation VG_SET_MASK
    VGMaskOperation VG_UNION_MASK
    VGMaskOperation VG_INTERSECT_MASK
    VGMaskOperation VG_SUBTRACT_MASK
    
    int VG_PATH_FORMAT_STANDARD
    
    ctypedef enum VGPathDatatype:
        pass
    
    VGPathDatatype VG_PATH_DATATYPE_S_8
    VGPathDatatype VG_PATH_DATATYPE_S_16
    VGPathDatatype VG_PATH_DATATYPE_S_32
    VGPathDatatype VG_PATH_DATATYPE_F
    
    
    ctypedef enum VGPathAbsRel:
        pass
    
    VGPathAbsRel VG_ABSOLUTE
    VGPathAbsRel VG_RELATIVE
    
    ctypedef enum VGPathSegment:
        pass
    
    VGPathSegment VG_CLOSE_PATH
    VGPathSegment VG_MOVE_TO
    VGPathSegment VG_LINE_TO
    VGPathSegment VG_HLINE_TO
    VGPathSegment VG_VLINE_TO
    VGPathSegment VG_QUAD_TO
    VGPathSegment VG_CUBIC_TO
    VGPathSegment VG_SQUAD_TO
    VGPathSegment VG_SCUBIC_TO
    VGPathSegment VG_SCCWARC_TO
    VGPathSegment VG_SCWARC_TO
    VGPathSegment VG_LCCWARC_TO
    VGPathSegment VG_LCWARC_TO
    
    ctypedef enum VGPathCommand:
        pass
    
    VGPathCommand VG_MOVE_TO_ABS
    VGPathCommand VG_MOVE_TO_REL
    VGPathCommand VG_LINE_TO_ABS
    VGPathCommand VG_LINE_TO_REL
    VGPathCommand VG_HLINE_TO_ABS
    VGPathCommand VG_HLINE_TO_REL
    VGPathCommand VG_VLINE_TO_ABS
    VGPathCommand VG_VLINE_TO_REL
    VGPathCommand VG_QUAD_TO_ABS
    VGPathCommand VG_QUAD_TO_REL
    VGPathCommand VG_CUBIC_TO_ABS
    VGPathCommand VG_CUBIC_TO_REL
    VGPathCommand VG_SQUAD_TO_ABS
    VGPathCommand VG_SQUAD_TO_REL
    VGPathCommand VG_SCUBIC_TO_ABS
    VGPathCommand VG_SCUBIC_TO_REL
    VGPathCommand VG_SCCWARC_TO_ABS
    VGPathCommand VG_SCCWARC_TO_REL
    VGPathCommand VG_SCWARC_TO_ABS
    VGPathCommand VG_SCWARC_TO_REL
    VGPathCommand VG_LCCWARC_TO_ABS
    VGPathCommand VG_LCCWARC_TO_REL
    VGPathCommand VG_LCWARC_TO_ABS
    VGPathCommand VG_LCWARC_TO_REL
    
    ctypedef VGHandle VGPath
    
    ctypedef enum VGPathCapabilities:
        pass
        
    VGPathCapabilities VG_PATH_CAPABILITY_APPEND_FROM
    VGPathCapabilities VG_PATH_CAPABILITY_APPEND_TO
    VGPathCapabilities VG_PATH_CAPABILITY_MODIFY
    VGPathCapabilities VG_PATH_CAPABILITY_TRANSFORM_FROM
    VGPathCapabilities VG_PATH_CAPABILITY_TRANSFORM_TO
    VGPathCapabilities VG_PATH_CAPABILITY_INTERPOLATE_FROM
    VGPathCapabilities VG_PATH_CAPABILITY_INTERPOLATE_TO
    VGPathCapabilities VG_PATH_CAPABILITY_PATH_LENGTH
    VGPathCapabilities VG_PATH_CAPABILITY_POINT_ALONG_PATH
    VGPathCapabilities VG_PATH_CAPABILITY_TANGENT_ALONG_PATH
    VGPathCapabilities VG_PATH_CAPABILITY_PATH_BOUNDS
    VGPathCapabilities VG_PATH_CAPABILITY_PATH_TRANSFORMED_BOUNDS
    VGPathCapabilities VG_PATH_CAPABILITY_ALL

    ctypedef enum VGPathParamType:
        pass
        
    VGPathParamType VG_PATH_FORMAT
    VGPathParamType VG_PATH_DATATYPE
    VGPathParamType VG_PATH_SCALE
    VGPathParamType VG_PATH_BIAS
    VGPathParamType VG_PATH_NUM_SEGMENTS
    VGPathParamType VG_PATH_NUM_COORDS

    ctypedef enum VGCapStyle:
        pass
        
    VGCapStyle VG_CAP_BUTT
    VGCapStyle VG_CAP_ROUND
    VGCapStyle VG_CAP_SQUARE

    ctypedef enum VGJoinStyle:
        pass
        
    VGJoinStyle VG_JOIN_MITER
    VGJoinStyle VG_JOIN_ROUND
    VGJoinStyle VG_JOIN_BEVEL

    ctypedef enum VGFillRule:
        pass
        
    VGFillRule VG_EVEN_ODD
    VGFillRule VG_NON_ZERO

    ctypedef enum VGPaintMode:
        pass
        
    VGPaintMode VG_STROKE_PATH
    VGPaintMode VG_FILL_PATH
    
    ctypedef VGHandle VGPaint
    
    ctypedef enum VGPaintParamType:
        pass
        
    # Color paint parameters
    VGPaintParamType VG_PAINT_TYPE
    VGPaintParamType VG_PAINT_COLOR
    VGPaintParamType VG_PAINT_COLOR_RAMP_SPREAD_MODE
    VGPaintParamType VG_PAINT_COLOR_RAMP_PREMULTIPLIED
    VGPaintParamType VG_PAINT_COLOR_RAMP_STOPS

    # Linear gradient paint parameters
    VGPaintParamType VG_PAINT_LINEAR_GRADIENT

    # Radial gradient paint parameters
    VGPaintParamType VG_PAINT_RADIAL_GRADIENT

    # Pattern paint parameters
    VGPaintParamType VG_PAINT_PATTERN_TILING_MODE

    ctypedef enum VGPaintType:
        pass
        
    VGPaintType VG_PAINT_TYPE_COLOR
    VGPaintType VG_PAINT_TYPE_LINEAR_GRADIENT
    VGPaintType VG_PAINT_TYPE_RADIAL_GRADIENT
    VGPaintType VG_PAINT_TYPE_PATTERN

    ctypedef enum VGColorRampSpreadMode:
        pass
        
    VGColorRampSpreadMode VG_COLOR_RAMP_SPREAD_PAD
    VGColorRampSpreadMode VG_COLOR_RAMP_SPREAD_REPEAT
    VGColorRampSpreadMode VG_COLOR_RAMP_SPREAD_REFLECT

    ctypedef enum VGTilingMode:
        pass
        
    VGTilingMode VG_TILE_FILL
    VGTilingMode VG_TILE_PAD
    VGTilingMode VG_TILE_REPEAT
    VGTilingMode VG_TILE_REFLECT

    ctypedef enum VGImageFormat:
        pass
        
    # RGB{A,X} channel ordering
    VGImageFormat VG_sRGBX_8888
    VGImageFormat VG_sRGBA_8888
    VGImageFormat VG_sRGBA_8888_PRE
    VGImageFormat VG_sRGB_565
    VGImageFormat VG_sRGBA_5551
    VGImageFormat VG_sRGBA_4444
    VGImageFormat VG_sL_8
    VGImageFormat VG_lRGBX_8888
    VGImageFormat VG_lRGBA_8888
    VGImageFormat VG_lRGBA_8888_PRE
    VGImageFormat VG_lL_8
    VGImageFormat VG_A_8
    VGImageFormat VG_BW_1

    # {A,X}RGB channel ordering
    VGImageFormat VG_sXRGB_8888
    VGImageFormat VG_sARGB_8888
    VGImageFormat VG_sARGB_8888_PRE
    VGImageFormat VG_sARGB_1555
    VGImageFormat VG_sARGB_4444
    VGImageFormat VG_lXRGB_8888
    VGImageFormat VG_lARGB_8888
    VGImageFormat VG_lARGB_8888_PRE

    # BGR{A,X} channel ordering
    VGImageFormat VG_sBGRX_8888
    VGImageFormat VG_sBGRA_8888
    VGImageFormat VG_sBGRA_8888_PRE
    VGImageFormat VG_sBGR_565
    VGImageFormat VG_sBGRA_5551
    VGImageFormat VG_sBGRA_4444
    VGImageFormat VG_lBGRX_8888
    VGImageFormat VG_lBGRA_8888
    VGImageFormat VG_lBGRA_8888_PRE

    # {A,X}BGR channel ordering
    VGImageFormat VG_sXBGR_8888
    VGImageFormat VG_sABGR_8888
    VGImageFormat VG_sABGR_8888_PRE
    VGImageFormat VG_sABGR_1555
    VGImageFormat VG_sABGR_4444
    VGImageFormat VG_lXBGR_8888
    VGImageFormat VG_lABGR_8888
    VGImageFormat VG_lABGR_8888_PRE

    ctypedef VGHandle VGImage

    ctypedef enum VGImageQuality:
        pass
        
    VGImageQuality VG_IMAGE_QUALITY_NONANTIALIASED
    VGImageQuality VG_IMAGE_QUALITY_FASTER
    VGImageQuality VG_IMAGE_QUALITY_BETTER

    ctypedef enum VGImageParamType:
        pass
        
    VGImageParamType VG_IMAGE_FORMAT
    VGImageParamType VG_IMAGE_WIDTH
    VGImageParamType VG_IMAGE_HEIGHT

    ctypedef enum VGImageMode:
        pass
        
    VGImageMode VG_DRAW_IMAGE_NORMAL
    VGImageMode VG_DRAW_IMAGE_MULTIPLY
    VGImageMode VG_DRAW_IMAGE_STENCIL

    ctypedef enum VGImageChannel:
        pass
        
    VGImageChannel VG_RED
    VGImageChannel VG_GREEN
    VGImageChannel VG_BLUE
    VGImageChannel VG_ALPHA

    ctypedef enum VGBlendMode:
        pass
        
    VGBlendMode VG_BLEND_SRC
    VGBlendMode VG_BLEND_SRC_OVER
    VGBlendMode VG_BLEND_DST_OVER
    VGBlendMode VG_BLEND_SRC_IN
    VGBlendMode VG_BLEND_DST_IN
    VGBlendMode VG_BLEND_MULTIPLY
    VGBlendMode VG_BLEND_SCREEN
    VGBlendMode VG_BLEND_DARKEN
    VGBlendMode VG_BLEND_LIGHTEN
    VGBlendMode VG_BLEND_ADDITIVE
    VGBlendMode VG_BLEND_SRC_OUT_SH
    VGBlendMode VG_BLEND_DST_OUT_SH
    VGBlendMode VG_BLEND_SRC_ATOP_SH
    VGBlendMode VG_BLEND_DST_ATOP_SH

    ctypedef enum VGHardwareQueryType:
        pass
        
    VGHardwareQueryType VG_IMAGE_FORMAT_QUERY
    VGHardwareQueryType VG_PATH_DATATYPE_QUERY

    ctypedef enum VGHardwareQueryResult:
        pass
        
    VGHardwareQueryResult VG_HARDWARE_ACCELERATED
    VGHardwareQueryResult VG_HARDWARE_UNACCELERATED

    ctypedef enum VGStringID:
        pass
        
    VGStringID VG_VENDOR
    VGStringID VG_RENDERER
    VGStringID VG_VERSION
    VGStringID VG_EXTENSIONS

    VGErrorCode vgGetError()

    void vgFlush()
    void vgFinish()

    # Getters and Setters
    void vgSetf (VGParamType type, VGfloat value)
    void vgSeti (VGParamType type, VGint value)
    void vgSetfv(VGParamType type, VGint count, VGfloat *values)
    void vgSetiv(VGParamType type, VGint count, VGint *values)
    
    VGfloat vgGetf(VGParamType type)
    VGint   vgGeti(VGParamType type)
    VGint   vgGetVectorSize(VGParamType type)
    void    vgGetfv(VGParamType type, VGint count, VGfloat * values)
    void    vgGetiv(VGParamType type, VGint count, VGint * values)

    void vgSetParameterf(VGHandle object,
                                 VGint paramType,
                                 VGfloat value)
    void vgSetParameteri(VGHandle object,
                                 VGint paramType,
                                 VGint value)
    void vgSetParameterfv(VGHandle object,
                                  VGint paramType,
                                  VGint count, VGfloat * values)
    void vgSetParameteriv(VGHandle object,
                                  VGint paramType,
                                  VGint count, VGint * values)

    VGfloat vgGetParameterf(VGHandle object,
                                    VGint paramType)
    VGint vgGetParameteri(VGHandle object,
                                  VGint paramType)
    VGint vgGetParameterVectorSize(VGHandle object,
                                           VGint paramType)
    void vgGetParameterfv(VGHandle object,
                                  VGint paramType,
                                  VGint count, VGfloat * values)
    void vgGetParameteriv(VGHandle object,
                                  VGint paramType,
                                  VGint count, VGint * values)
    
    # Matrix Manipulation
    void vgLoadIdentity()
    void vgLoadMatrix(VGfloat * m)
    void vgGetMatrix(VGfloat * m)
    void vgMultMatrix(VGfloat * m)
    void vgTranslate(VGfloat tx, VGfloat ty)
    void vgScale(VGfloat sx, VGfloat sy)
    void vgShear(VGfloat shx, VGfloat shy)
    void vgRotate(VGfloat angle)

    # Masking and Clearing
    void vgMask(VGImage mask, VGMaskOperation operation,
                VGint x, VGint y, VGint width, VGint height)
    void vgClear(VGint x, VGint y, VGint width, VGint height)
    
    # Paths
    VGPath vgCreatePath(VGint pathFormat,
                        VGPathDatatype datatype,
                        VGfloat scale, VGfloat bias,
                        VGint segmentCapacityHint,
                        VGint coordCapacityHint,
                        VGbitfield capabilities)
    void vgClearPath(VGPath path, VGbitfield capabilities)
    void vgDestroyPath(VGPath path)
    void vgRemovePathCapabilities(VGPath path, VGbitfield capabilities)
    VGbitfield vgGetPathCapabilities(VGPath path)
    void vgAppendPath(VGPath dstPath, VGPath srcPath)
    void vgAppendPathData(VGPath dstPath,
                          VGint numSegments,
                          VGubyte * pathSegments,
                          void * pathData)
    void vgModifyPathCoords(VGPath dstPath, VGint startIndex,
                            VGint numSegments,
                            void * pathData)
    void vgTransformPath(VGPath dstPath, VGPath srcPath)
    VGboolean vgInterpolatePath(VGPath dstPath,
                                VGPath startPath,
                                VGPath endPath,
                                VGfloat amount)
    VGfloat vgPathLength(VGPath path, VGint startSegment, VGint numSegments)
    void vgPointAlongPath(VGPath path,
                          VGint startSegment, VGint numSegments,
                          VGfloat distance,
                          VGfloat * x, VGfloat * y,
                          VGfloat * tangentX, VGfloat * tangentY)
    void vgPathBounds(VGPath path,
                      VGfloat * minX, VGfloat * minY,
                      VGfloat * width, VGfloat * height)
    void vgPathTransformedBounds(VGPath path,
                                 VGfloat * minX, VGfloat * minY,
                                 VGfloat * width, VGfloat * height)
    void vgDrawPath(VGPath path, VGbitfield paintModes)

    # Paint
    VGPaint vgCreatePaint()
    void vgDestroyPaint(VGPaint paint)
    void vgSetPaint(VGPaint paint, VGbitfield paintModes)
    VGPaint vgGetPaint(VGPaintMode paintMode)
    void vgSetColor(VGPaint paint, VGuint rgba)
    VGuint vgGetColor(VGPaint paint)
    void vgPaintPattern(VGPaint paint, VGImage pattern)

    # Images
    VGImage vgCreateImage(VGImageFormat format,
                          VGint width, VGint height,
                          VGbitfield allowedQuality)
    void vgDestroyImage(VGImage image)
    void vgClearImage(VGImage image, VGint x, VGint y, VGint width, VGint height)
    void vgImageSubData(VGImage image,
                        void * data, VGint dataStride,
                        VGImageFormat dataFormat,
                        VGint x, VGint y, VGint width, VGint height)
    void vgGetImageSubData(VGImage image,
                           void * data, VGint dataStride,
                           VGImageFormat dataFormat,
                           VGint x, VGint y,
                           VGint width, VGint height)
    VGImage vgChildImage(VGImage parent, VGint x, VGint y, VGint width, VGint height)
    VGImage vgGetParent(VGImage image) 
    void vgCopyImage(VGImage dst, VGint dx, VGint dy,
                     VGImage src, VGint sx, VGint sy,
                     VGint width, VGint height,
                     VGboolean dither)
    void vgDrawImage(VGImage image)
    void vgSetPixels(VGint dx, VGint dy,
                     VGImage src, VGint sx, VGint sy,
                     VGint width, VGint height)
    void vgWritePixels(void * data, VGint dataStride,
                       VGImageFormat dataFormat,
                       VGint dx, VGint dy,
                       VGint width, VGint height)
    void vgGetPixels(VGImage dst, VGint dx, VGint dy,
                     VGint sx, VGint sy,
                     VGint width, VGint height)
    void vgReadPixels(void * data, VGint dataStride,
                      VGImageFormat dataFormat,
                      VGint sx, VGint sy,
                      VGint width, VGint height)
    void vgCopyPixels(VGint dx, VGint dy,
                      VGint sx, VGint sy,
                      VGint width, VGint height)

    # Image Filters
    void vgColorMatrix(VGImage dst, VGImage src,
                               VGfloat * matrix)
    void vgConvolve(VGImage dst, VGImage src,
                    VGint kernelWidth, VGint kernelHeight,
                    VGint shiftX, VGint shiftY,
                    VGshort * kernel,
                    VGfloat scale,
                    VGfloat bias,
                    VGTilingMode tilingMode)
    void vgSeparableConvolve(VGImage dst, VGImage src,
                             VGint kernelWidth,
                             VGint kernelHeight,
                             VGint shiftX, VGint shiftY,
                             VGshort * kernelX,
                             VGshort * kernelY,
                             VGfloat scale,
                             VGfloat bias,
                             VGTilingMode tilingMode)
    void vgGaussianBlur(VGImage dst, VGImage src,
                        VGfloat stdDeviationX,
                        VGfloat stdDeviationY,
                        VGTilingMode tilingMode)
    void vgLookup(VGImage dst, VGImage src,
                  VGubyte * redLUT,
                  VGubyte * greenLUT,
                  VGubyte * blueLUT,
                  VGubyte * alphaLUT,
                  VGboolean outputLinear,
                  VGboolean outputPremultiplied)
    void vgLookupSingle(VGImage dst, VGImage src,
                        VGuint * lookupTable,
                        VGImageChannel sourceChannel,
                        VGboolean outputLinear,
                        VGboolean outputPremultiplied)
    
    # Hardware Queries
    VGHardwareQueryResult vgHardwareQuery(VGHardwareQueryType key,
                                                  VGint setting)

    # Renderer and Extension Information
    VGubyte * vgGetString(VGStringID name)

    # Extensions
    int OVG_SH_blend_src_out
    int OVG_SH_blend_dst_out
    int OVG_SH_blend_src_atop
    int OVG_SH_blend_dst_atop

    VGboolean vgCreateContextSH(VGint width, VGint height)
    void vgResizeSurfaceSH(VGint width, VGint height)
    void vgDestroyContextSH()
    
    ctypedef void (*OffScreenCB)(void *userdata)
    VGboolean shOffscreenRender(int width, int height, OffScreenCB draw, OffScreenCB finish, void *userdata)
    void *vgCreateOffScreenSH()
    void vgDestroyOffScreenSH(void *oscontext)
    void vgStartOffScreenSH(void *oscontext, int width, int height)
    void vgEndOffScreenSH(void *oscontext, unsigned char *pixels)

cdef extern from "vg/vgu.h":
    ctypedef enum VGUErrorCode:
        pass
    
    VGUErrorCode VGU_NO_ERROR
    VGUErrorCode VGU_BAD_HANDLE_ERROR
    VGUErrorCode VGU_ILLEGAL_ARGUMENT_ERROR
    VGUErrorCode VGU_OUT_OF_MEMORY_ERROR
    VGUErrorCode VGU_PATH_CAPABILITY_ERROR
    VGUErrorCode VGU_BAD_WARP_ERROR
    
    ctypedef enum VGUArcType:
        pass
    
    VGUArcType VGU_ARC_OPEN
    VGUArcType VGU_ARC_CHORD
    VGUArcType VGU_ARC_PIE
    
    VGUErrorCode vguLine(VGPath path,
                          VGfloat x0, VGfloat y0,
                          VGfloat x1, VGfloat y1)
    
    VGUErrorCode vguPolygon(VGPath path,
                            VGfloat *points, VGint count,
                            VGboolean closed)
    
    VGUErrorCode vguRect(VGPath path,
                         VGfloat x, VGfloat y,
                         VGfloat width, VGfloat height)
    
    VGUErrorCode vguRoundRect(VGPath path,
                              VGfloat x, VGfloat y,
                              VGfloat width, VGfloat height,
                              VGfloat arcWidth, VGfloat arcHeight)
    
    VGUErrorCode vguEllipse(VGPath path,
                            VGfloat cx, VGfloat cy,
                            VGfloat width, VGfloat height)
    
    VGUErrorCode vguArc(VGPath path,
                        VGfloat x, VGfloat y,
                        VGfloat width, VGfloat height,
                        VGfloat startAngle, VGfloat angleExtent,
                        VGUArcType arcType)
                        
    VGUErrorCode vguComputeWarpQuadToSquare(VGfloat sx0, VGfloat sy0,
                                            VGfloat sx1, VGfloat sy1,
                                            VGfloat sx2, VGfloat sy2,
                                            VGfloat sx3, VGfloat sy3,
                                            VGfloat *matrix)
    
    VGUErrorCode vguComputeWarpSquareToQuad(VGfloat dx0, VGfloat dy0,
                                            VGfloat dx1, VGfloat dy1,
                                            VGfloat dx2, VGfloat dy2,
                                            VGfloat dx3, VGfloat dy3,
                                            VGfloat *matrix)

    VGUErrorCode vguComputeWarpQuadToQuad(VGfloat dx0, VGfloat dy0,
                                          VGfloat dx1, VGfloat dy1,
                                          VGfloat dx2, VGfloat dy2,
                                          VGfloat dx3, VGfloat dy3,
                                          VGfloat sx0, VGfloat sy0,
                                          VGfloat sx1, VGfloat sy1,
                                          VGfloat sx2, VGfloat sy2,
                                          VGfloat sx3, VGfloat sy3,
                                          VGfloat *matrix)