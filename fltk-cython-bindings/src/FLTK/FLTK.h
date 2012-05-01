#ifndef __PYX_HAVE__FLTK
#define __PYX_HAVE__FLTK


#ifndef __PYX_HAVE_API__FLTK

#ifndef __PYX_EXTERN_C
  #ifdef __cplusplus
    #define __PYX_EXTERN_C extern "C"
  #else
    #define __PYX_EXTERN_C extern
  #endif
#endif

__PYX_EXTERN_C DL_IMPORT(PyObject) *Widget_ext_callback(Fl_Widget *, PyObject *, char *, int *);
__PYX_EXTERN_C DL_IMPORT(PyObject) *GL_Window_ext_callback(Fl_Gl_Window *, PyObject *, char *, int *);

#endif /* !__PYX_HAVE_API__FLTK */

#if PY_MAJOR_VERSION < 3
PyMODINIT_FUNC initFLTK(void);
#else
PyMODINIT_FUNC PyInit_FLTK(void);
#endif

#endif /* !__PYX_HAVE__FLTK */
