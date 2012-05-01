# -*- coding: utf-8 -*-'
from libc.stdlib cimport malloc, free
from cpython.ref cimport Py_INCREF, Py_DECREF
from cpython.exc cimport PyErr_Occurred, PyErr_Print

from FLTKLib cimport *

include "Enumerations.pxi"
include "StaticMembers.pxi"
include "Drawing.pxi"
include "Image.pxi"
include "Widget.pxi"
include "Buttons.pxi"
include "Menu.pxi"
include "InputOutput.pxi"
include "Text.pxi"

TREE_REASON_NONE = FL_TREE_REASON_NONE
TREE_REASON_SELECTED = FL_TREE_REASON_SELECTED
TREE_REASON_DESELECTED = FL_TREE_REASON_DESELECTED
TREE_REASON_OPENED = FL_TREE_REASON_OPENED
TREE_REASON_CLOSED = FL_TREE_REASON_CLOSED

# install input hook
# set_input_hook()

cdef class Tree

cdef class Tree_Item:
    cdef void *thisptr
    cdef Tree tree
    
    def label(self, *args):
        cdef Fl_Tree_Item *item = <Fl_Tree_Item *>self.thisptr
        
        if len(args) == 0:
            return item.label()
        elif len(args) == 1:
            item.label(args[0])
        else:
            msg = 'label() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef get_label(self):
        cdef Fl_Tree_Item *item = <Fl_Tree_Item *>self.thisptr
        return item.label()
    
    cpdef set_label(self, char *new_label):
        cdef Fl_Tree_Item *item = <Fl_Tree_Item *>self.thisptr
        item.label(new_label)
    
    cpdef Tree_Item parent(self):
        cdef Fl_Tree_Item *item = <Fl_Tree_Item *>self.thisptr
        cdef Tree_Item ret = Tree_Item()
        
        ret.thisptr = item.parent()
        ret.tree = self.tree
        
        if ret.thisptr == NULL:
            return None
        else:
            return ret
        
cdef class Tree(Group):
    def __init__(self, int xx, int yy, int ww, int hh, char *l = NULL):
        self.thisptr = new Fl_Tree(xx,yy,ww,hh,l)
    
        # This object is owned by parent class
        Py_INCREF(self)
    
    cpdef clear(self):
        '''
        Clear all children from the tree.
        The tree will be left completely empty.
        '''
        cdef Fl_Tree *tree = <Fl_Tree *>self.thisptr
        tree.clear()
        
    cpdef add(self, char *path):
        '''
        Add item to tree
        '''
        cdef Fl_Tree *tree = <Fl_Tree *>self.thisptr
        cdef Fl_Tree_Item *item = tree.add(path)
    
    def showroot(self, *args):
        cdef Fl_Tree *tree = <Fl_Tree *>self.thisptr
        
        if len(args) == 0:
            return tree.showroot()
        elif len(args) == 1:
            tree.showroot(args[0])
        else:
            msg = 'showroot() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef int get_showroot(self):
        '''
        Returns 1 if the root item is to be shown, or 0 if not. 
        '''
        cdef Fl_Tree *tree = <Fl_Tree *>self.thisptr
        return tree.showroot()
    
    cpdef set_showroot(self, int val):
        '''
        Set if the root item should be shown or not.
        '''
        cdef Fl_Tree *tree = <Fl_Tree *>self.thisptr
        tree.showroot(val)
    
    cpdef int callback_reason(self):
        '''
         The callback() can use this value to see why it was called.
        '''
        cdef Fl_Tree *tree = <Fl_Tree *>self.thisptr
        return <int>tree.callback_reason()
    
    cpdef Tree_Item callback_item(self):
        '''
        Gets the item that caused the callback.
        The callback() can use this value to see which item changed.
        '''
        cdef Fl_Tree *tree = <Fl_Tree *>self.thisptr
        cdef Tree_Item ret = Tree_Item()
        
        ret.thisptr = tree.callback_item()
        ret.tree = self
        return ret
        
cdef class Native_File_Chooser:
    cdef void *thisptr
    
    def __init__(self, int val = 0):
        self.thisptr = new Fl_Native_File_Chooser(val)
        
    def __dealloc__(self):
        cdef Fl_Native_File_Chooser *tmp
        
        if self.thisptr != NULL:
            tmp = <Fl_Native_File_Chooser *>self.thisptr
            del tmp
    
    def type(self, *args):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        
        if len(args) == 0:
            return nfc.type()
        elif len(args) == 1:
            nfc.type(args[0])
        else:
            msg = 'type() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef int get_type(self):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        return nfc.type()
    
    cpdef set_type(self, int val):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        nfc.type(val)
    
    def options(self, *args):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        
        if len(args) == 0:
            return nfc.options()
        elif len(args) == 1:
            nfc.options(args[0])
        else:
            msg = 'options() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef int get_options(self):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        return nfc.options()
    
    cpdef set_options(self, int val):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        nfc.options(val)
    
    cpdef int count(self):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        return nfc.count()
    
    cpdef filename(self, i = 0):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        return nfc.filename(i)
    
    def directory(self, *args):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        
        if len(args) == 0:
            return nfc.directory()
        elif len(args) == 1:
            nfc.directory(args[0])
        else:
            msg = 'directory() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef get_directory(self):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        return nfc.directory()
    
    cpdef set_directory(self, char *val):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        nfc.directory(val)
    
    def title(self, *args):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        
        if len(args) == 0:
            return nfc.title()
        elif len(args) == 1:
            nfc.title(args[0])
        else:
            msg = 'title() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef get_title(self):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        return nfc.title()
    
    cpdef set_title(self, char *val):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        nfc.title(val)
    
    def filter(self, *args):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        
        if len(args) == 0:
            return nfc.filter()
        elif len(args) == 1:
            nfc.filter(args[0])
        else:
            msg = 'filter() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef get_filter(self):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        return nfc.filter()
    
    cpdef set_filter(self, char *val):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        nfc.filter(val)
    
    cpdef int filters(self):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        return nfc.filters()
    
    def preset_file(self, *args):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        
        if len(args) == 0:
            return nfc.preset_file()
        elif len(args) == 1:
            nfc.preset_file(args[0])
        else:
            msg = 'preset_file() takes at most one argument (%d given)'
            raise TypeError(msg % len(args))
            
    cpdef get_preset_file(self):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        return nfc.preset_file()
    
    cpdef set_preset_file(self, char *val):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        nfc.preset_file(val)
        
    cpdef errmsg(self):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        return nfc.errmsg()
        
    cpdef int show(self):
        cdef Fl_Native_File_Chooser *nfc = <Fl_Native_File_Chooser *>self.thisptr
        return nfc.show()
    