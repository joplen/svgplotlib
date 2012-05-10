#include "openvg.h"

#if defined(WIN32)
#include <windows.h>
#include <GL/gl.h>
#include <GL/glext.h>
#include <GL/wglext.h>
#else
#include <GL/gl.h>
#include <GL/glext.h>
#endif

#include <stdio.h>

typedef struct
{
#if defined(WIN32)
    HDC dc, saved_dc;
    HGLRC rc, saved_rc;
    WNDCLASSEX wndClass;
    HWND wnd;
#endif
    int width, height;
    int hasFBO;
    GLuint fb, cb, db;
} OffScreen;

#if defined(WIN32)
PFNGLWINDOWPOS2DPROC glWindowPos2d = NULL;
PFNGLGENFRAMEBUFFERSPROC glGenFramebuffers = NULL;
PFNGLDELETEFRAMEBUFFERSPROC glDeleteFramebuffers = NULL;
PFNGLBINDFRAMEBUFFERPROC glBindFramebuffer = NULL;
PFNGLGENRENDERBUFFERSPROC glGenRenderbuffers = NULL;
PFNGLDELETERENDERBUFFERSPROC glDeleteRenderbuffers = NULL;
PFNGLBINDRENDERBUFFERPROC glBindRenderbuffer = NULL;
PFNGLRENDERBUFFERSTORAGEPROC glRenderbufferStorage = NULL;
PFNGLFRAMEBUFFERRENDERBUFFERPROC glFramebufferRenderbuffer = NULL;
PFNGLCHECKFRAMEBUFFERSTATUSPROC glCheckFramebufferStatus = NULL;
#endif

void checkFBO(OffScreen *os)
{
#if defined(WIN32)
    os->hasFBO = 0;
    glWindowPos2d = (PFNGLWINDOWPOS2DPROC)wglGetProcAddress("glWindowPos2d");
    if (glWindowPos2d != NULL) {
        glGenFramebuffers = (PFNGLGENFRAMEBUFFERSPROC)wglGetProcAddress("glGenFramebuffers");
        if (glGenFramebuffers != NULL) {
            os->hasFBO = 1;
            glDeleteFramebuffers = (PFNGLDELETEFRAMEBUFFERSPROC)wglGetProcAddress("glDeleteFramebuffers");
            glBindFramebuffer = (PFNGLBINDFRAMEBUFFERPROC)wglGetProcAddress("glBindFramebuffer");
            glGenRenderbuffers = (PFNGLGENRENDERBUFFERSPROC)wglGetProcAddress("glGenRenderbuffers");
            glDeleteRenderbuffers = (PFNGLDELETERENDERBUFFERSPROC)wglGetProcAddress("glDeleteRenderbuffers");
            glBindRenderbuffer = (PFNGLBINDRENDERBUFFERPROC)wglGetProcAddress("glBindRenderbuffer");
            glRenderbufferStorage = (PFNGLRENDERBUFFERSTORAGEPROC)wglGetProcAddress("glRenderbufferStorage");
            glFramebufferRenderbuffer = (PFNGLFRAMEBUFFERRENDERBUFFERPROC)wglGetProcAddress("glFramebufferRenderbuffer");
            glCheckFramebufferStatus = (PFNGLCHECKFRAMEBUFFERSTATUSPROC)wglGetProcAddress("glCheckFramebufferStatus");
        } else {
            glGenFramebuffers = (PFNGLGENFRAMEBUFFERSPROC)wglGetProcAddress("glGenFramebuffersEXT");
            if (glGenFramebuffers != NULL) {
                os->hasFBO = 1;
                glDeleteFramebuffers = (PFNGLDELETEFRAMEBUFFERSPROC)wglGetProcAddress("glDeleteFramebuffersEXT");
                glBindFramebuffer = (PFNGLBINDFRAMEBUFFERPROC)wglGetProcAddress("glBindFramebufferEXT");
                glGenRenderbuffers = (PFNGLGENRENDERBUFFERSPROC)wglGetProcAddress("glGenRenderbuffersEXT");
                glDeleteRenderbuffers = (PFNGLDELETERENDERBUFFERSPROC)wglGetProcAddress("glDeleteRenderbuffersEXT");
                glBindRenderbuffer = (PFNGLBINDRENDERBUFFERPROC)wglGetProcAddress("glBindRenderbufferEXT");
                glRenderbufferStorage = (PFNGLRENDERBUFFERSTORAGEPROC)wglGetProcAddress("glRenderbufferStorageEXT");
                glFramebufferRenderbuffer = (PFNGLFRAMEBUFFERRENDERBUFFERPROC)wglGetProcAddress("glFramebufferRenderbufferEXT");
                glCheckFramebufferStatus = (PFNGLCHECKFRAMEBUFFERSTATUSPROC)wglGetProcAddress("glCheckFramebufferStatusEXT");
            }
        }
    }
#else
    printf("checkFBO not implemented!\n");
#endif
}


void setupFBO(OffScreen *os, int width, int height)
{
#if defined(WIN32)
    glGenFramebuffers(1, &os->fb);
    glBindFramebuffer(GL_FRAMEBUFFER_EXT, os->fb);
    glGenRenderbuffers(1, &os->cb);
    glBindRenderbuffer(GL_RENDERBUFFER_EXT, os->cb);
    glRenderbufferStorage(GL_RENDERBUFFER_EXT, GL_RGBA8, width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_RENDERBUFFER_EXT, os->cb);
    
    glGenRenderbuffers(1, &os->db);
    glBindRenderbuffer(GL_RENDERBUFFER_EXT, os->db);
    glRenderbufferStorage(GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT24, width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, os->db);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER_EXT) == GL_FRAMEBUFFER_COMPLETE_EXT) {
        glBindFramebuffer(GL_FRAMEBUFFER_EXT, os->fb);
        glWindowPos2d(0,0);
    }
#else
    printf("setupFBO not implemented!\n");
#endif
}

void destroyFBO(OffScreen *os)
{
#if defined(WIN32)
    glBindFramebuffer(GL_FRAMEBUFFER_EXT, 0);
    glDeleteRenderbuffers(1, &os->cb);
    glDeleteRenderbuffers(1, &os->db);
    glDeleteFramebuffers(1, &os->fb);
#else
    printf("destroyFBO not implemented!\n");
#endif
}


VG_API_CALL VGboolean shOffscreenRender(int width, int height, OffScreenCB draw, OffScreenCB finish, void *userdata)
{
#if defined(WIN32)
    VGboolean ret = VG_TRUE;
    
    HGLRC rc = 0;
    HDC saved_dc = wglGetCurrentDC();
    HGLRC saved_rc = wglGetCurrentContext();
    
    WNDCLASSEX wndClass;
	wndClass.cbSize			= sizeof(WNDCLASSEX);
	wndClass.style			= CS_HREDRAW | CS_VREDRAW | CS_OWNDC | CS_DBLCLKS;
	wndClass.lpfnWndProc	= DefWindowProc;
	wndClass.cbClsExtra		= 0;
	wndClass.cbWndExtra		= 0;
	wndClass.hInstance		= GetModuleHandle(0);
	wndClass.hIcon			= 0;
	wndClass.hCursor		= LoadCursor(0, IDC_ARROW);
	wndClass.hbrBackground	= (HBRUSH)GetStockObject(BLACK_BRUSH);
	wndClass.lpszMenuName	= 0;
	wndClass.lpszClassName	= "WndClass";
	wndClass.hIconSm		= 0;
    
	if (RegisterClassEx(&wndClass)) {
        // Style the window and remove the caption bar (WS_POPUP)
        DWORD style = WS_CLIPSIBLINGS | WS_CLIPCHILDREN | WS_POPUP;
        
        // Create the window. Position and size it.
        HWND wnd = CreateWindowEx(0,
                      "WndClass",
                      "",
                      style,
                      CW_USEDEFAULT, CW_USEDEFAULT, width, height,
                      0, 0, 0, 0);
        
        if(wnd != NULL) {
            HDC dc = GetDC(wnd);
            
            if(dc != NULL) {
                // Setup OpenGL
                PIXELFORMATDESCRIPTOR pfd;
                memset(&pfd, 0, sizeof(PIXELFORMATDESCRIPTOR));

                pfd.nSize = sizeof(pfd);
                pfd.nVersion = 1;
                pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
                pfd.iPixelType = PFD_TYPE_RGBA;
                pfd.cColorBits = 32;
                pfd.cDepthBits = 16;
                pfd.cStencilBits = 8;
                pfd.iLayerType = PFD_MAIN_PLANE;

                int pixelFormat = ChoosePixelFormat(dc, &pfd);
                SetPixelFormat(dc, pixelFormat, &pfd);

                rc = wglCreateContext(dc);
                
                if(rc != NULL) {
                    wglMakeCurrent(dc, rc);
                    
                    if (vgCreateContextSH(width, height) == VG_TRUE) {
                    
                        draw(userdata);
                        SwapBuffers(dc);
                        finish(userdata);
                    
                        vgDestroyContextSH();
                    } else {
                        ret = VG_FALSE;
                    }
                } else {
                    ret = VG_FALSE;
                }
                wglMakeCurrent(dc, 0);
                ReleaseDC(wnd, dc);
                
            } else {
                ret = VG_FALSE;
            }
            
        } else {
            ret = VG_FALSE;
        }
        DestroyWindow (wnd);
        UnregisterClass("WndClass", wndClass.hInstance);
        if (rc != 0) wglDeleteContext(rc);
    } else {
        ret = VG_FALSE;
    }
    wglMakeCurrent(saved_dc,saved_rc);
    return ret;
#else
    printf("shOffscreenRender not implemented!\n");
#endif
}

VG_API_CALL void *vgCreateOffScreenSH(void)
{
#if defined(WIN32)
    OffScreen *os = (OffScreen *)malloc(sizeof(OffScreen));
    
    os->saved_dc = wglGetCurrentDC();
    os->saved_rc = wglGetCurrentContext();
    
    if (os != NULL) {
        os->wndClass.cbSize			= sizeof(WNDCLASSEX);
        os->wndClass.style			= CS_HREDRAW | CS_VREDRAW | CS_OWNDC | CS_DBLCLKS;
        os->wndClass.lpfnWndProc	= DefWindowProc;
        os->wndClass.cbClsExtra		= 0;
        os->wndClass.cbWndExtra		= 0;
        os->wndClass.hInstance		= GetModuleHandle(0);
        os->wndClass.hIcon			= 0;
        os->wndClass.hCursor		= LoadCursor(0, IDC_ARROW);
        os->wndClass.hbrBackground	= (HBRUSH)GetStockObject(BLACK_BRUSH);
        os->wndClass.lpszMenuName	= 0;
        os->wndClass.lpszClassName	= "WndClass";
        os->wndClass.hIconSm		= 0;
        
        if (RegisterClassEx(&os->wndClass)) {
            // Style the window and remove the caption bar (WS_POPUP)
            DWORD style = WS_CLIPSIBLINGS | WS_CLIPCHILDREN | WS_POPUP;
            
            // Create the window. Position and size it.
            os->wnd = CreateWindowEx(0,
                          "WndClass",
                          "",
                          style,
                          CW_USEDEFAULT, CW_USEDEFAULT, 640, 480,
                          0, 0, 0, 0);
            if(os->wnd != NULL) {
                // Create drawing context
                os->dc = GetDC(os->wnd);
                if(os->dc != NULL) {
                    // Setup OpenGL
                    PIXELFORMATDESCRIPTOR pfd;
                    memset(&pfd, 0, sizeof(PIXELFORMATDESCRIPTOR));

                    pfd.nSize = sizeof(pfd);
                    pfd.nVersion = 1;
                    pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
                    pfd.iPixelType = PFD_TYPE_RGBA;
                    pfd.cColorBits = 32;
                    pfd.cDepthBits = 16;
                    pfd.cStencilBits = 8;
                    pfd.iLayerType = PFD_MAIN_PLANE;

                    int pixelFormat = ChoosePixelFormat(os->dc, &pfd);
                    SetPixelFormat(os->dc, pixelFormat, &pfd);

                    os->rc = wglCreateContext(os->dc);
                    if(os->rc != NULL) {
                        ;
                        //wglMakeCurrent(os->dc, os->rc);
                        //checkFBO(os);
                        //wglMakeCurrent(os->saved_dc, os->saved_rc);
                    } else {
                        ReleaseDC(os->wnd, os->dc);
                        DestroyWindow(os->wnd);
                        UnregisterClass("WndClass", os->wndClass.hInstance);
                        free(os);
                        os = NULL;
                    }
                } else {
                    DestroyWindow(os->wnd);
                    UnregisterClass("WndClass", os->wndClass.hInstance);
                    free(os);
                    os = NULL;
                }
            } else {
                UnregisterClass("WndClass", os->wndClass.hInstance);
                free(os);
                os = NULL;
            }
        } else {
            free(os);
            os = NULL;
        }
    }
    return (void *)os;
#else
    printf("vgCreateOffScreenSH not implemented!\n");
#endif
}


VG_API_CALL void vgDestroyOffScreenSH(void *oscontext)
{
#if defined(WIN32)
    OffScreen *os = (OffScreen *)oscontext;
    if (os != NULL) {
        //if (os->hasFBO != 0) {
        //    destroyFBO(os);
        //}
        if (os->rc != NULL) {
            wglMakeCurrent(os->dc, 0);
            wglDeleteContext(os->rc);
        }
        if (os->dc != NULL) ReleaseDC(os->wnd, os->dc);
        if (os->wnd != NULL) {
            DestroyWindow(os->wnd);
            UnregisterClass("WndClass", os->wndClass.hInstance);
        }
        free(os);
    }
    wglMakeCurrent(os->saved_dc, os->saved_rc);
#else
    printf("shOffscreenRender not implemented!\n");
#endif
}

VG_API_CALL void vgStartOffScreenSH(void *oscontext, int width, int height)
{
#if defined(WIN32)
    OffScreen *os = (OffScreen *)oscontext;
    if (os != NULL) {
        os->width = width;
        os->height = height;
        wglMakeCurrent(os->dc, os->rc);
        //if (os->hasFBO != 0) {
        //    setupFBO(os, width, height);
        //} else {
        //    MoveWindow(os->wnd, 0, 0, width, height, FALSE);
        //}
        if (MoveWindow(os->wnd, 0, 0, width, height, FALSE)) {
            vgCreateContextSH(width, height);
            vgResizeSurfaceSH(width, height);
        }
    }
#else
    printf("vgStartOffScreenSH not implemented!\n");
#endif
}

VG_API_CALL void vgEndOffScreenSH(void *oscontext, unsigned char *pixels)
{
#if defined(WIN32)
    OffScreen *os = (OffScreen *)oscontext;
    unsigned char tmp1, tmp2;
    int x, y, z, offset, swapY, swapOffset;

    if (os != NULL) {
        if (pixels != NULL) {
            glPixelStorei(GL_PACK_ALIGNMENT, 1);
            //if (os->hasFBO != 0) {
            //    glDrawBuffer(GL_COLOR_ATTACHMENT0_EXT);
            //    glReadPixels(0, 0, os->width, os->height, GL_BGRA, GL_UNSIGNED_BYTE, pixels);
            //} else {
            SwapBuffers(os->dc);
            glReadPixels(0, 0, os->width, os->height, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
            //}
            // glReadPixels reads the given rectangle from bottom-left to top-right
            for (y = 0; y < os->height/2; y++) {
                swapY = os->height - y - 1;
                for (x = 0; x < os->width; x++) {
                    offset = 4 * (x + y * os->width);
                    swapOffset =  4 * (x + swapY * os->width);
                    for (z = 0; z < 4; z++) {
                        tmp1 = pixels[offset + z];
                        tmp2 = pixels[swapOffset + z];
                        pixels[offset + z] = tmp2;
                        pixels[swapOffset + z] = tmp1;
                        
                    }
                }
            }
        }
        vgDestroyContextSH();
    }
#else
    printf("vgEndOffScreenSH not implemented!\n");
#endif
}
