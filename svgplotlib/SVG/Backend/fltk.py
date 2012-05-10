#!/usr/bin/env python -u

import io
import os.path
import svgplotlib.FLTK as Fl
import svgplotlib.VG as vg
from svgplotlib.SVG.Backend.VG import Renderer


def image_cb(filename):
    if filename.endswith('.png'):
        img = Fl.PNG_Image(filename) .asRGBA()
    elif filename.endswith('.jpg'):
        img = Fl.JPEG_Image(filename) .asRGBA()
    else:
        return None
    
    return img.w(), img.h(), memoryview(img)

class FLGLWidget(Fl.Gl_Window):
    def __init__(self, X, Y, W, H):
        Fl.Gl_Window.__init__(self, X, Y, W, H)
        
        # Set OpenGL mode
        flg = Fl.RGB | Fl.ALPHA | Fl.DOUBLE | Fl.DEPTH | Fl.STENCIL | \
              Fl.MULTISAMPLE
        self.mode(flg)
        
        self.vgcontext = None
        self.renderer = None
        
        self.dx, self.dy = 0., 0.
        self.scale = 1.
        
        self.mouse_x = None
        self.mouse_y = None
    
    def openFile(self, widget = None, filename = None):
        if filename is None:
            native = Fl.Native_File_Chooser()
            native.title("Select SVG file")
            native.filter('SVG\t*.svg')
            ret = native.show()
            if ret == -1 or ret == 1:
               return
            
            filename = native.filename()
        
        xmltree = readFile(filename)
        self.renderer = Renderer(xmltree, imageprovider = image_cb)
        
        if isinstance(filename, basestring):
            name = os.path.split(filename)[-1]
        else:
            name = 'unamed.svg'
            
        self.updateScale()
        self.redraw()
        
    def updateScale(self):
        # scale to bounding box
        if not self.renderer is None:
            width, height = self.w(), self.h()
            bbox = self.box = self.renderer.bounds
            self.scale = .9*min(width/bbox.width, height/bbox.height)
            
    def draw(self):
        width, height = self.w(), self.h()
       
        if not self.context_valid():
            self.vgcontext = vg.CreateContextSH(width, height)
            self.updateScale()
        
        if not self.valid():
            vg.ResizeSurfaceSH(width,height)
            self.updateScale()
        
        # Clear to white
        vg.Setfv(vg.CLEAR_COLOR, 4, [1.,1.,1.,1.])
        vg.Clear(0, 0, width, height)
        
        if self.renderer is None:
            return
        
        # setup transform
        box = self.box
        scale = self.scale
        dx, dy = self.dx, self.dy
        
        vg.Seti(vg.MATRIX_MODE, vg.MATRIX_PATH_USER_TO_SURFACE)
        vg.LoadIdentity()
        
        vg.Scale(scale, scale)
        vg.Translate(0., 1.5*box.height)
        vg.Scale(1., -1.)
        vg.Translate(-box.minx - dx, -box.miny + .5*box.height - dy)
        
        # render paths
        self.renderer.render()
        
        # fix for garbage when drawing gradients
        vg.Clear(0, 0, width, height)
        self.renderer.render()
            
    def handle(self, event):
        if event == Fl.FOCUS:
            self.redraw()
            return 1   
        elif event == Fl.MOUSEWHEEL:
            self.scale *= 1 + .1*Fl.event_dy()
            self.redraw()
            return 1
        elif event == Fl.PUSH:
            if Fl.event_button() == Fl.MIDDLE_MOUSE:
                self.mouse_x = Fl.event_x()
                self.mouse_y = Fl.event_y()
            return 1
        
        elif event == Fl.RELEASE:
            self.mouse_x = None
            self.mouse_y = None
            return 0
            
        elif event == Fl.DRAG:
            if Fl.event_button() == Fl.MIDDLE_MOUSE:
                if not self.mouse_x is None:
                    dx = Fl.event_x() - self.mouse_x
                    dy = Fl.event_y() - self.mouse_y
                    
                    mat = vg.GetMatrix()
                    sx, sy = mat[0], mat[4]
                    
                    self.dx -= dx/sx
                    self.dy += dy/sy
                    
                    self.mouse_x += dx
                    self.mouse_y += dy
                    
                    self.redraw()
                    return 1
            
        return 0

class Viewer(Fl.Double_Window):
    def __init__(self, svg=None, width=500, height=500 ):
        try:
            WIDTH, HEIGHT = width, height
            super(Viewer,self).__init__(WIDTH,HEIGHT)
            menu = Fl.Menu_Bar(0,0,WIDTH,30)

            widget = GLWidget(10,40, WIDTH - 20, HEIGHT - 50)
            
            menu.add("&File",0,None,None,Fl.SUBMENU)
            menu.add("File/&Open", 0, widget.openFile, None, Fl.MENU_DIVIDER)
            menu.add("File/&Quit", 0, lambda widget,data: Fl.exit())
            
            self.end()
            self.resizable(widget)
            self.show()
            widget.show()
            if not svg is None:
                widget.openFile( filename = svg )
            Fl.run()
                
        finally:
            vg.DestroyContextSH()

def deadViewer(filename = None):
    try:
        WIDTH, HEIGHT = 600,700
        window = Fl.Double_Window(WIDTH, HEIGHT)
        menu = Fl.Menu_Bar(0,0,WIDTH,30)

        widget = GLWidget(10,40, WIDTH - 20, HEIGHT - 50)
        
        menu.add("&File",0,None,None,Fl.SUBMENU)
        menu.add("File/&Open", 0, widget.openFile, None, Fl.MENU_DIVIDER)
        menu.add("File/&Quit", 0, lambda widget,data: Fl.exit())
        
        window.end()
        window.resizable(widget)
        window.show()
        widget.show()
        if not filename is None:
            widget.openFile(filename=filename)
        Fl.run()
            
    finally:
        vg.DestroyContextSH()

def show(svg):
    fh = io.BytesIO()
    svg.write(fh)
    fh.seek(0)
    Viewer(fh)

if __name__ == '__main__':
    try:
        import xml.etree.cElementTree as etree
    except ImportError:
        import xml.etree.ElementTree as etree
    xmltree = etree.fromstring("""<?xml
version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" 
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg width="500" height="500" viewBox="0 0 1200 400"
     xmlns="http://www.w3.org/2000/svg" version="1.1">
  <desc>Example rect02 - rounded rectangles</desc>

  <!-- Show outline of canvas using 'rect' element -->
  <rect x="1" y="1" width="1198" height="398"
        fill="none" stroke="blue" stroke-width="2"/>

  <rect x="100" y="100" width="400" height="200" rx="50"
        fill="green" />

  <g transform="translate(700 210) rotate(-30)">
    <rect x="0" y="0" width="400" height="200" rx="50"
          fill="none" stroke="purple" stroke-width="30" />
  </g>
</svg>
""")

    renderer = Renderer(xmltree)
    
    import svgplotlib.FLTK as Fl
    
    WIDTH, HEIGHT = 600,700
    window = Fl.Window(WIDTH, HEIGHT)
    
    width,height = renderer.width, renderer.height
    
    widget = Fl.Button(10, 10, width, height)
    
    pixels = vg.PixelBuffer(width,height)
    ctx = vg.CreateOffScreenSH()
    vg.StartOffScreenSH(ctx, width, height)
    
    vg.Setfv(vg.CLEAR_COLOR, 4, [1.,1.,1.,1.])
    vg.Clear(0, 0, width, height)
    
    # center on bounding box
    box = renderer.bounds
    scale = min(width/box.width, height/box.height)
    
    vg.Seti(vg.MATRIX_MODE, vg.MATRIX_PATH_USER_TO_SURFACE)
    vg.LoadIdentity()
    
    vg.Scale(scale, scale)
    vg.Translate(0., 1.5*box.height)
    vg.Scale(1., -1.)
    vg.Translate(-box.minx, -box.miny + .5*box.height)
    
    renderer.render()
    vg.EndOffScreenSH(ctx, pixels)
    vg.DestroyOffScreenSH(ctx)
    
    img = Fl.RGB_Image(width,height, 4, 0, pixels)
    
    widget.set_image(img)
    window.show()
    Fl.run()

