# Matrix Manipulation
cdef class Matrix:
    """
    3x3 Transformation matrix
    
               m11 m12 m13
    Matrix =   m21 m22 m23
               m31 m32 m33
    """
    cdef VGfloat m[3][3]
    
    def __init__(self, *args):
        cdef int size = len(args)
        assert size == 0 or size == 6
        
        if size == 6:
            self.m[0][0] = args[0]
            self.m[1][0] = args[1]
            self.m[0][1] = args[2]
            self.m[1][1] = args[3]
            self.m[0][2] = args[4]
            self.m[1][2] = args[5]
            self.m[2][2] = 1.
            
    def __str__(self):
        return 'Matrix%s' % self.__repr__()
    
    def __repr__(self):
        return '(\n  (%s, %s, %s),\n  (%s, %s, %s),\n  (%s, %s, %s)\n)\n' % \
                (str(self.m[0][0]), str(self.m[0][1]), str(self.m[0][2]), 
                 str(self.m[1][0]), str(self.m[1][1]), str(self.m[1][2]), 
                 str(self.m[2][0]), str(self.m[2][1]), str(self.m[2][2]))
    
    def __getitem__(self, int i):
        cdef VGfloat *ptr = &self.m[0][0]
        assert i >= 0 and i <= 8
        return ptr[i]
    
    def __setitem__(self, int i, VGfloat value):
        cdef VGfloat *ptr = &self.m[0][0]
        assert i >= 0 and i <= 8
        ptr[i] = value
        
    def __len__(self):
        return 9
    
    def __imul__(Matrix a, Matrix b):
        """
        Matrix multiplication
        """
        cdef VGfloat res[3][3]
        cdef int i, j
        
        for i in range(3):
            for j in range(3):
                res[i][j] = a.m[i][0] * b.m[0][j] + \
                            a.m[i][1] * b.m[1][j] + \
                            a.m[i][2] * b.m[2][j]
        
        for i in range(3):
            for j in range(3):
                a.m[i][j] = res[i][j]
        
        return a
            
    
    cpdef Matrix Copy(self):
        """
        Create copy of Matrix
        """
        cdef Matrix ret = Matrix.__new__(Matrix, None)
        cdef int i, j

        for i in range(3):
            for j in range(3):
                ret.m[i][j] = self.m[i][j]
        
        return ret
                
    cpdef Map(self, VGfloat x, VGfloat y):
        """
        Apply transform to point x, y
        """
        return x * self.m[0][0] + y * self.m[0][1] + self.m[0][2], \
                x * self.m[1][0] + y * self.m[1][1] +self. m[1][2]
        
    cpdef Matrix Zero(self):
        """
        Set all values to zero
        """
        self.m[0][0] = 0.; self.m[0][1] = 0.; self.m[0][2] = 0.
        self.m[1][0] = 0.; self.m[1][1] = 0.; self.m[1][2] = 0.
        self.m[2][0] = 0.; self.m[2][1] = 0.; self.m[2][2] = 0.
        return self
        
    cpdef Matrix Identity(self):
        """
        Create identity matrix
        """
        self.m[0][0] = 1.; self.m[0][1] = 0.; self.m[0][2] = 0.
        self.m[1][0] = 0.; self.m[1][1] = 1.; self.m[1][2] = 0.
        self.m[2][0] = 0.; self.m[2][1] = 0.; self.m[2][2] = 1.
        return self
    
    cpdef Matrix Translate(self, VGfloat dx, VGfloat dy = 0.):
        '''
        Create translation matrix
        '''
        self.m[0][0] = 1.; self.m[0][1] = 0.; self.m[0][2] = dx
        self.m[1][0] = 0.; self.m[1][1] = 1.; self.m[1][2] = dy
        self.m[2][0] = 0.; self.m[2][1] = 0.; self.m[2][2] = 1.
        return self
    
    cpdef Matrix Scale(self, VGfloat sx, VGfloat sy):
        '''
        Create scale matrix
        '''
        self.m[0][0] = sx; self.m[0][1] = 0.; self.m[0][2] = 0
        self.m[1][0] = 0.; self.m[1][1] = sy; self.m[1][2] = 0
        self.m[2][0] = 0.; self.m[2][1] = 0.; self.m[2][2] = 1.
        return self
    
    cpdef Matrix Rotate(self, VGfloat angle):
        '''
        Create rotation matrix
        '''
        cdef VGfloat cx, sx
        cdef VGfloat PI = 3.14159265358979323846
        cdef VGfloat DEG2RAD = PI/180.
        
        angle *= DEG2RAD
        
        cx = cos(angle)
        sx = sin(angle)
        
        self.m[0][0] = cx ; self.m[0][1] = -sx; self.m[0][2] = 0
        self.m[1][0] = sx ; self.m[1][1] = cx ; self.m[1][2] = 0
        self.m[2][0] = 0. ; self.m[2][1] = 0. ; self.m[2][2] = 1.
        
        return self
    
    cpdef Matrix Skew(self, VGfloat x, VGfloat y = 0.):
        '''
        Create scale matrix
        '''
        cdef VGfloat xs, ys
        cdef VGfloat PI = 3.14159265358979323846
        cdef VGfloat DEG2RAD = PI/180.
        
        xs = tan(x*DEG2RAD)
        ys = tan(y*DEG2RAD)
            
        self.m[0][0] = 1.; self.m[0][1] = xs; self.m[0][2] = 0
        self.m[1][0] = ys; self.m[1][1] = 1.; self.m[1][2] = 0
        self.m[2][0] = 0.; self.m[2][1] = 0.; self.m[2][2] = 1.
        return self

cpdef MultMatrix(Matrix m):
    '''
    Right-multiplies the current matrix with the one specified
    in the given array. Matrix affinity is preserved if an
    affine matrix is begin multiplied.
    '''
    cdef VGfloat mat[9]
    cdef int i, j, k
    
    k = 0
    for i in range(3):
        for j in range(3):
            mat[k] = m.m[j][i]
            k += 1
    
    vgMultMatrix(mat)
    
cpdef LoadMatrix(Matrix m):
    '''
    Loads values into the current matrix from the given array.
    Matrix affinity is preserved if an affine matrix is loaded.
    '''
    cdef VGfloat mat[9]
    cdef int i, j, k
    
    k = 0
    for i in range(3):
        for j in range(3):
            mat[k] = m.m[j][i]
            k += 1
    
    vgLoadMatrix(mat)

cpdef GetMatrix():
    '''
    Outputs the values of the current matrix into the given array
    '''
    cdef Matrix ret = Matrix.__new__(Matrix, None)
    cdef VGfloat mat[9]
    cdef int i, j, k
    
    vgGetMatrix(mat)
    
    k = 0
    for i in range(3):
        for j in range(3):
            ret.m[j][i] = mat[k]
            k += 1
    
    return ret
    
cpdef LoadIdentity():
    '''
    Sets the current matrix to identity
    '''
    vgLoadIdentity()

cpdef Translate(VGfloat tx, VGfloat ty):
    '''
    Modifies the current transformation by appending a translation.
    '''
    vgTranslate(tx, ty)
    
cpdef Scale(VGfloat sx, VGfloat sy):
    '''
    Modifies the current transformation by appending a scale.
    '''
    vgScale(sx, sy)
    
cpdef Shear(VGfloat shx, VGfloat shy):
    '''
    Modifies the current transformation by appending a shear. 
    '''
    vgShear(shx, shy)
    
cpdef Rotate(VGfloat angle):
    '''
    The vgRotate function modifies the current transformation by appending a 
    counter-clockwise rotation by a given angle (expressed in degrees) about 
    the origin.
    '''
    vgRotate(angle)