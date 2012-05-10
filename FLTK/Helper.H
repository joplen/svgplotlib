
#include <FL/Fl.H>
#include <FL/Fl_Widget.H>
#include <FL/Fl_Gl_Window.H>
#include <FL/Fl_Help_View.H>
#include <FL/x.H>
#include <Fl/fl_draw.H>

#include "FLTK.h"
extern "C" DL_IMPORT(PyObject) *Widget_ext_callback(Fl_Widget *, PyObject *, char *, int *);
extern "C" DL_IMPORT(PyObject) *GL_Window_ext_callback(Fl_Gl_Window *, PyObject *, char *, int *);

class Fl_Widget_ : public Fl_Widget {
    void *py_self;
public:
	Fl_Widget_(int X, int Y, int W, int H, const char *L = NULL, void *self = NULL)
: py_self(self), Fl_Widget(X,Y,W,H,L) {} 
	void draw() {
        PyObject *ret;
        if (py_self != NULL) {
            ret = ::Widget_ext_callback(this, (PyObject *)py_self, "draw", NULL);
        }
	}
    int handle(int event) { 
		PyObject *ret;
        if (py_self != NULL) {
            ret = ::Widget_ext_callback(this, (PyObject *)py_self, "handle", &event);
            return event;
        }
	} 
};

class Fl_Gl_Window_ : public Fl_Gl_Window {
    void *py_self;
public:
    Fl_Gl_Window_(int X, int Y, int W, int H, const char *l=0, void *self = NULL)
: py_self(self), Fl_Gl_Window(X,Y,W,H,l) {}
    Fl_Gl_Window_(int W, int H, const char *l=0, void *self = NULL)
: py_self(self), Fl_Gl_Window(W,H,l) {}
	void draw() {
        PyObject *ret;
        if (py_self != NULL) {
            ret = ::GL_Window_ext_callback(this, (PyObject *)py_self, "draw", NULL);
        }
	}
    int handle(int event) { 
		PyObject *ret;
        if (py_self != NULL) {
            ret = ::GL_Window_ext_callback(this, (PyObject *)py_self, "handle", &event);
            return event;
        }
	} 
};

// Patch 1767434, interactive pyFltk
#if (defined(_WIN32) || defined(__WIN32__)) && !defined(__CYGWIN__)
#include <conio.h>
#else
static void _exit_wait_loop(int fd, void* data)
{
    int* stdin_ready = (int*)data;
    *stdin_ready = 1;
}
#endif

static int _run_loop_interactive(void)
{
  PyGILState_STATE gstate;
#if (defined(_WIN32) || defined(__WIN32__)) && !defined(__CYGWIN__)
  gstate = PyGILState_Ensure();
  while (! _kbhit()) Fl::wait(0.1);
  PyGILState_Release(gstate);
#else
  int result;
  int stdin_ready = 0;
  const int fd = fileno(stdin);
  Fl::add_fd(fd, _exit_wait_loop, &stdin_ready);
  gstate = PyGILState_Ensure();
  while (!stdin_ready)
  {
      result = Fl::wait();
      if (!result) break;
  }
  PyGILState_Release(gstate);
  Fl::remove_fd(fd);
#endif
  return 0;
}

static void set_input_hook()
{
    if (PyOS_InputHook==NULL) 
        PyOS_InputHook = _run_loop_interactive;
    else 
        PyErr_Warn(PyExc_RuntimeWarning, "PyOS_InputHook is not available for interactive use of pyFltk");
}
