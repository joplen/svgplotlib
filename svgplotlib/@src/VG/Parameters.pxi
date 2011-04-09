# Getters and Setters
cpdef Setf(VGParamType type, VGfloat value):
    '''
    Sets a parameter of a single float value
    '''
    vgSetf(type, value)
    
cpdef Seti(VGParamType type, VGint value):
    '''
    Sets a parameter of a single integer value
    '''
    vgSeti(type, value)

cpdef Setfv(VGParamType type, VGint count, values):
    '''
    Sets a parameter which takes a vector of float values
    '''
    cdef VGfloat *c_values
    cdef int i
    
    try:
        c_values = <VGfloat *>malloc(count * sizeof(VGfloat))
        for i in range(count):
            c_values[i] = values[i]
        vgSetfv(type, count, c_values)
    finally:
        if c_values != NULL:
            free(c_values)

cpdef Setiv(VGParamType type, VGint count, values):
    '''
    Sets a parameter which takes a vector of integer values
    '''
    cdef VGint *c_values
    cdef int i
    
    try:
        c_values = <VGint *>malloc(count * sizeof(VGint))
        for i in range(count):
            c_values[i] = values[i]
        vgSetiv(type, count, c_values)
    finally:
        if c_values != NULL:
            free(c_values)

cpdef VGfloat Getf(VGParamType paramtype):
    '''
    Returns a parameter of a single float value
    '''
    return vgGetf(paramtype)

cpdef VGint Geti(VGParamType paramtype):
    '''
    Returns a parameter of a single integer value
    '''
    return vgGeti(paramtype)

cpdef Getfv(VGParamType paramtype):
    '''
    Outputs a parameter of a float vector value
    '''
    cdef VGfloat *c_values
    cdef int i, count
    
    count = vgGetVectorSize(paramtype)
    ret = [None,] * count
    
    try:
        c_values = <VGfloat *>malloc(count * sizeof(VGfloat))
        vgGetfv(paramtype, count, c_values)
        
        for i in range(count):
            ret[i] = c_values[i]
    finally:
        if c_values != NULL:
            free(c_values)
    
    return tuple(ret)

cpdef Getiv(VGParamType paramtype):
    '''
    Outputs a parameter of an integer vector value
    '''
    cdef VGint *c_values
    cdef int i, count
    
    count = vgGetVectorSize(paramtype)
    ret = [None,] * count
    
    try:
        c_values = <VGint *>malloc(count * sizeof(VGint))
        vgGetiv(paramtype, count, c_values)
        
        for i in range(count):
            ret[i] = c_values[i]
    finally:
        if c_values != NULL:
            free(c_values)
    
    return tuple(ret)

cpdef SetParameterf(Handle obj, VGint paramType, VGfloat value):
    '''
    Sets a resource parameter which takes a single float value
    '''
    vgSetParameterf(obj.thisptr, paramType, value)

cpdef SetParameteri(Handle obj, VGint paramType, VGint value):
    '''
    Sets a resource parameter which takes a single integer value
    '''
    vgSetParameteri(obj.thisptr, paramType, value)
    
cpdef SetParameterfv(Handle obj, VGint paramType, VGint count, values):
    '''
    Sets a resource parameter which takes a vector of float values
    '''
    cdef VGfloat *c_values
    cdef int i
    
    try:
        c_values = <VGfloat *>malloc(count * sizeof(VGfloat))
        for i in range(count):
            c_values[i] = values[i]
        vgSetParameterfv(obj.thisptr, paramType, count, c_values)
    finally:
        if c_values != NULL:
            free(c_values)

cpdef SetParameteriv(Handle obj, VGint paramType, VGint count, values):
    '''
    Sets a resource parameter which takes a vector of integer values
    '''
    cdef VGint *c_values
    cdef int i
    
    try:
        c_values = <VGint *>malloc(count * sizeof(VGint))
        for i in range(count):
            c_values[i] = values[i]
        vgSetParameteriv(obj.thisptr, paramType, count, c_values)
    finally:
        if c_values != NULL:
            free(c_values)

cpdef VGfloat GetParameterf(Handle obj, VGint paramType):
    '''
    Returns a resource parameter of a single float value
    '''
    return vgGetParameterf(obj.thisptr, paramType)

cpdef VGint GetParameteri(Handle obj, VGint paramType):
    '''
    Returns a resource parameter of a single integer value
    '''
    return vgGetParameteri(obj.thisptr, paramType)

cpdef GetParameterfv(Handle obj, VGint paramType):
    '''
    Outputs a resource parameter of a float vector value
    '''
    cdef VGfloat *c_values
    cdef int i, count
    
    count = vgGetParameterVectorSize(obj.thisptr, paramType)
    ret = [None,] * count
    
    try:
        c_values = <VGfloat *>malloc(count * sizeof(VGfloat))
        vgGetParameterfv(obj.thisptr, paramType, count, c_values)
        
        for i in range(count):
            ret[i] = c_values[i]
    finally:
        if c_values != NULL:
            free(c_values)
    
    return tuple(ret)

cpdef GetParameteriv(Handle obj, VGint paramType):
    '''
    Outputs a resource parameter of an integer vector value
    '''
    cdef VGint *c_values
    cdef int i, count
    
    count = vgGetParameterVectorSize(obj.thisptr, paramType)
    ret = [None,] * count
    
    try:
        c_values = <VGint *>malloc(count * sizeof(VGint))
        vgGetParameteriv(obj.thisptr, paramType, count, c_values)
        
        for i in range(count):
            ret[i] = c_values[i]
    finally:
        if c_values != NULL:
            free(c_values)
    
    return tuple(ret)