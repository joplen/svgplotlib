# Path functions

cdef class Path(Handle):
    cdef VGPath ptr(self):
        return <VGPath>self.thisptr
        
cpdef Path CreatePath(VGint pathFormat = VG_PATH_FORMAT_STANDARD,
                      VGPathDatatype datatype = VG_PATH_DATATYPE_F,
                      VGfloat scale = 1., VGfloat bias = 0.,
                      VGint segmentCapacityHint = 0,
                      VGint coordCapacityHint  = 0,
                      VGbitfield capabilities = VG_PATH_CAPABILITY_ALL):
    '''
    Allocates a path resource in the current context and
    sets its capabilities.
    '''
    cdef Path ret = Path()
    ret.thisptr = vgCreatePath(pathFormat, datatype, scale, bias,
                               segmentCapacityHint, coordCapacityHint, capabilities)
    ret.datatype = datatype
    return ret

cpdef ClearPath(Path path, VGbitfield capabilities = VG_PATH_CAPABILITY_ALL):
    '''
    Clears the specified path of all data and sets new
    capabilities to it.
    '''
    vgClearPath(path.ptr(), capabilities)

cpdef DestroyPath(Path path):
    '''
    Disposes specified path resource in the current context
    '''
    vgDestroyPath(path.ptr())

cpdef RemovePathCapabilities(Path path, VGbitfield capabilities):
    '''
    Removes capabilities defined in the given bitfield
    from the specified path.
    '''
    vgRemovePathCapabilities(path.ptr(), capabilities)

cpdef VGbitfield GetPathCapabilities(Path path):
    '''
    Returns capabilities of a path resource
    '''
    return vgGetPathCapabilities(path.ptr())

cpdef AppendPath(Path src, Path dst):
    '''
    Appends path data from source to destination path resource
    '''
    vgAppendPath(src.ptr(), dst.ptr())
    
cpdef AppendPathData(Path dstPath, VGint numSegments, pathSegments, pathData):
    '''
    Appends data to destination path resource
    '''
    cdef VGubyte *c_pathSegments
    cdef VGfloat *c_pathData
    cdef int i, datasize
    
    try:
        c_pathSegments = <VGubyte *>malloc(numSegments * sizeof(VGubyte))
        for i in range(numSegments):
            c_pathSegments[i] = pathSegments[i]
        
        try:
            datasize = len(pathData)
            c_pathData = <VGfloat *>malloc(datasize * sizeof(VGfloat))
            for i in range(datasize):
                c_pathData[i] = pathData[i]
                
            vgAppendPathData(dstPath.ptr(), numSegments, c_pathSegments, c_pathData)
            
        finally:
            if c_pathData != NULL:
                free(c_pathData)
    finally:
        if c_pathSegments != NULL:
            free(c_pathSegments)

cpdef ModifyPathCoords(Path dstPath, VGint startIndex, VGint numSegments, pathData):
    '''
    Modifies the coordinates of the existing path segments
    '''
    cdef VGfloat *c_pathData
    cdef int i, datasize
    
    try:
        datasize = len(pathData)
        c_pathData = <VGfloat *>malloc(datasize * sizeof(VGfloat))
        for i in range(datasize):
            c_pathData[i] = pathData[i]
            
        vgModifyPathCoords(dstPath.ptr(), startIndex, numSegments, c_pathData)
    finally:
        if c_pathData != NULL:
            free(c_pathData)

cpdef TransformPath(Path dstPath, Path srcPath):
    '''
    Appends a copy of srcPath transformed by the current matrix
    to dstPath.
    '''
    vgTransformPath(dstPath.ptr(), srcPath.ptr())

cpdef InterpolatePath(Path dstPath, Path startPath, Path endPath, VGfloat amount):
    '''
    Appends a copy of srcPath transformed by the current matrix
    to dstPath.
    '''
    vgInterpolatePath(dstPath.ptr(), startPath.ptr(), endPath.ptr(), amount)

cpdef PathBounds(Path path):
    '''
    Outputs a tight bounding box of a path defined by its
    control points in path's own coordinate system.
    '''
    cdef VGfloat minX, minY, width, height
    
    vgPathBounds(path.ptr(), &minX, &minY, &width, &height)
    
    return minX, minY, width, height

cpdef PathTransformedBounds(Path path):
    '''
    Outputs a bounding box of a path defined by its control
    points that is guaranteed to enclose the path geometry
    after applying the current path-user-to-surface transform
    '''
    cdef VGfloat minX, minY, width, height
    
    vgPathTransformedBounds(path.ptr(), &minX, &minY, &width, &height)
    
    return minX, minY, width, height