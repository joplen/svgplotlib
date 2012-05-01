#!/usr/bin/python
# -*- coding: utf-8 -*-
from xml.etree import cElementTree

from svgplotlib.SVG.VGParser import Parser, Box

class Renderer(Parser):
    LINK = '{http://www.w3.org/1999/xlink}href'
    
    SVG_NS = '{http://www.w3.org/2000/svg}'
    SVG_ROOT            = SVG_NS + 'svg'
    SVG_A               = SVG_NS + 'a'
    SVG_G               = SVG_NS + 'g'
    SVG_TITLE           = SVG_NS + 'title'
    SVG_DESC            = SVG_NS + 'desc'
    SVG_DEFS            = SVG_NS + 'defs'
    SVG_SYMBOL          = SVG_NS + 'symbol'
    SVG_USE             = SVG_NS + 'use'
    SVG_RECT            = SVG_NS + 'rect'
    SVG_CIRCLE          = SVG_NS + 'circle'
    SVG_ELLIPSE         = SVG_NS + 'ellipse'
    SVG_LINE            = SVG_NS + 'line'
    SVG_POLYLINE        = SVG_NS + 'polyline'
    SVG_POLYGON         = SVG_NS + 'polygon'
    SVG_PATH            = SVG_NS + 'path'
    SVG_LINEARGRADIENT  = SVG_NS + 'linearGradient'
    SVG_RADIALGRADIENT  = SVG_NS + 'radialGradient'
    SVG_TEXT            = SVG_NS + 'text'
    SVG_TSPAN           = SVG_NS + 'tspan'
    SVG_IMAGE           = SVG_NS + 'image'
    
    SVG_NODES = frozenset((
        SVG_ROOT, SVG_A, SVG_G, SVG_TITLE, SVG_DESC, SVG_DEFS, SVG_SYMBOL,
        SVG_USE, SVG_RECT, SVG_CIRCLE, SVG_ELLIPSE, SVG_LINE, SVG_POLYLINE,
        SVG_POLYGON, SVG_PATH, SVG_TEXT, SVG_TSPAN, SVG_IMAGE,
        SVG_LINEARGRADIENT, SVG_RADIALGRADIENT
    ))
    
    SKIP_NODES = frozenset((SVG_TITLE, SVG_DESC, SVG_DEFS, SVG_SYMBOL))
    PATH_NODES = frozenset((SVG_RECT, SVG_CIRCLE, SVG_ELLIPSE, SVG_LINE, 
                            SVG_POLYLINE, SVG_POLYGON, SVG_PATH, SVG_TEXT))
    
    GRADIENT_NODES = frozenset((SVG_LINEARGRADIENT, SVG_RADIALGRADIENT))
    
    def __init__(self, xmltree, imageprovider = None):
        self.root = None
        self.imageprovider = imageprovider
        self.stroke = None
        self.fill = None
        
        self.level = 0
        self.seen = set()
        self.skip = set()
        self.styles = {}
        self.hasFill = False
        self.gradient = None
        self.hasStroke = False
        
        self.bounds = Box()
        
        self.xmltree = xmltree
        
        # svg fragment?
        if cElementTree.iselement(xmltree) and xmltree.tag == self.SVG_ROOT:
            root = xmltree
        else:
            root = xmltree.getroot()
            if not root.tag == self.SVG_ROOT:
                raise ValueError("Expected SVG fragment as root object")
            
        # parse svg constructs for quicker display
        self.preparse(root)
    
    def findLink(self, link_id, section = None):
        if section is None:
            section = self.SVG_DEFS
        
        if link_id.startswith('#'):
            link_id = link_id[1:]
        
        target = None
        for defs in self.root.getiterator(section):
            for element in defs:
                if element.get('id') == link_id:
                    target = element
                    break
        
        return target
    
    def render(self, node = None, data = None): 
        if node is None:
            self.level = 0
            
            vg.Seti(vg.MATRIX_MODE, vg.MATRIX_PATH_USER_TO_SURFACE)
            
            # Set up painters with default values
            self.gradientFill = vg.CreatePaint()
            
            stroke = self.stroke = vg.CreatePaint()
            vg.SetParameterfv(stroke, vg.PAINT_COLOR, 4, [0.,0.,0.,1.])
            vg.SetPaint(stroke, vg.STROKE_PATH)
            
            fill = self.fill = vg.CreatePaint()
            vg.SetParameterfv(fill, vg.PAINT_COLOR, 4, [0.,0.,0.,1.])
            vg.SetPaint(fill, vg.FILL_PATH)
            
            self.render(self.root)
            return
        
        # Skip non SVG nodes, hidden or malformed nodes
        if node.tag not in self.SVG_NODES or node in self.skip:
            return
            
        if node.tag == self.SVG_ROOT:
            nodedata = node.tail
            
            # iterate children
            for child in node:
                self.render(child)
                
        elif node.tag in (self.SVG_G, self.SVG_A, self.SVG_USE):
            self.level += 1
            
            nodedata = node.tail
            saved_style = None
            if 'style' in nodedata:
                saved_style = self.applyStyle(nodedata['style'])
            
            transform = nodedata.get('transform')
            saved_transform = self.applyTransform(transform)
            
            if node.tag == self.SVG_USE:
                self.render(nodedata['target'])
            else:
                # iterate children
                for child in node:
                    self.render(child)
            
            if not saved_style is None:
                self.applyStyle(saved_style, save = False)
            
            if not saved_transform is None:
                vg.LoadMatrix(saved_transform)
            
            self.level -= 1
            
        elif node.tag in self.SKIP_NODES:
            # Skip non-graphics elements
            return
        
        elif node.tag in self.GRADIENT_NODES:
            nodedata = node.tail
            
            if nodedata['unit'] != "objectBoundingBox":
                if node.tag == self.SVG_LINEARGRADIENT:
                    args = nodedata['x1'], nodedata['y1'], \
                           nodedata['x2'], nodedata['y2']
                    mode = vg.PAINT_LINEAR_GRADIENT
                else:
                    args = nodedata['cx'], nodedata['cy'], \
                           nodedata['fx'], nodedata['fy'], \
                           nodedata['radius']
                    mode = vg.PAINT_RADIAL_GRADIENT
                
                vg.SetParameterfv(self.gradientFill, mode, len(args), args)
                
            
            stops = nodedata['stops']
            vg.SetParameteri(self.gradientFill, vg.PAINT_COLOR_RAMP_SPREAD_MODE, nodedata['spreadMode'])
            
            if node.tag == self.SVG_LINEARGRADIENT:
                vg.SetParameteri(self.gradientFill, vg.PAINT_TYPE, vg.PAINT_TYPE_LINEAR_GRADIENT)
            else:
                vg.SetParameteri(self.gradientFill, vg.PAINT_TYPE, vg.PAINT_TYPE_RADIAL_GRADIENT)
                
            vg.SetParameterfv(self.gradientFill, vg.PAINT_COLOR_RAMP_STOPS, len(stops), stops)
        
        elif node.tag == self.SVG_TEXT:
            return
        
        elif node.tag == self.SVG_IMAGE:
            nodedata = node.tail
            
            if not 'image' in nodedata:
                rgba_data = nodedata['rgba_data']
                if rgba_data is None:
                    return
                
                # create image
                w, h, rgba_data = rgba_data
                image = vg.CreateImage(vg.lABGR_8888, w, h)
                vg.ImageSubData(image, rgba_data, w*4, vg.lABGR_8888, 0, 0, w, h)
                nodedata['image'] = image
                
                # remove raw data
                del nodedata['rgba_data']
            
            transform = nodedata.get('transform')
            saved_transform = self.applyTransform(transform)
            
            modelmat = vg.GetMatrix()
            vg.Seti(vg.MATRIX_MODE, vg.MATRIX_IMAGE_USER_TO_SURFACE)
            vg.LoadMatrix(modelmat)
            vg.DrawImage(nodedata['image'])
            vg.Seti(vg.MATRIX_MODE, vg.MATRIX_PATH_USER_TO_SURFACE)
            
            if not saved_transform is None:
                vg.LoadMatrix(saved_transform)
                
        elif node.tag in self.PATH_NODES:
            nodedata = node.tail
            if not 'path' in nodedata:
                nodedata['path'] = self.createPath(node)
            
            style = nodedata.get('style')
            saved_style = self.applyStyle(style)
            
            transform = nodedata.get('transform')
            saved_transform = self.applyTransform(transform)
            
            if self.hasStroke:
                vg.DrawPath(nodedata['path'], vg.STROKE_PATH)
                
            if self.hasFill:
                if not self.gradient is None:
                    gdata = self.gradient.tail
                    if gdata['unit'] == "objectBoundingBox":
                        self.updateGradient(nodedata['bounds'])
                    
                    vg.SetPaint(self.gradientFill, vg.FILL_PATH)
                    
                    transform = gdata.get('transform')
                    saved_paint = self.applyTransform(transform, vg.MATRIX_FILL_PAINT_TO_USER)
                    
                    vg.DrawPath(nodedata['path'], vg.FILL_PATH)
                    
                    if not saved_paint is None:
                        vg.Seti(vg.MATRIX_MODE, vg.MATRIX_FILL_PAINT_TO_USER)
                        vg.LoadMatrix(saved_paint)
                        vg.Seti(vg.MATRIX_MODE, vg.MATRIX_PATH_USER_TO_SURFACE)
                        
                    vg.SetPaint(self.fill, vg.FILL_PATH)
                else:
                    vg.DrawPath(nodedata['path'], vg.FILL_PATH)
            
            self.applyStyle(saved_style, save = False)
            
            if not saved_transform is None:
                vg.LoadMatrix(saved_transform)
    
    def createPath(self, node):
        nodedata = node.tail
        args = nodedata['args']
            
        path = vg.CreatePath(vg.PATH_FORMAT_STANDARD, vg.PATH_DATATYPE_F,
                             1,0,0,0, vg.PATH_CAPABILITY_ALL)
        
        if node.tag == self.SVG_LINE:
            vg.Line(path, args[0], args[1], args[2], args[3])
        
        elif node.tag == self.SVG_RECT:
            if args[4] == 0. and args[5] == 0.:
                vg.Rect(path, args[0], args[1], args[2], args[3])
            else:
                vg.RoundRect(path, args[0], args[1], args[2], args[3],
                             args[4], args[5])
        
        elif node.tag == self.SVG_CIRCLE:
            cx, cy, r = args
            vg.Ellipse(path, cx, cy, 2*r, 2*r)
        
        elif node.tag == self.SVG_ELLIPSE:
            vg.Ellipse(path, args[0], args[1], args[2], args[3])
        
        elif node.tag == self.SVG_POLYLINE:
            if len(args) == 4:
                vg.Line(path, args[0], args[1], args[2], args[3])
            else:
                vg.Polygon(path, args, len(args)/2, False)
        
        elif node.tag == self.SVG_POLYGON:
            vg.Polygon(path, args, len(args)/2, True)
        
        elif node.tag == self.SVG_PATH:
            segs, data = args
            vg.AppendPathData(path, len(segs), segs, data)
            
        else:
            raise SVGError("Tag '%s' not implemented!" % node.tag)
            
        return path
        
    def updateGradient(self, bounds):
        '''
        Update gradient to element bounding box
        '''
        gdata = self.gradient.tail
        
        x0, y0 = bounds.minx, bounds.miny
        w, h = bounds.width, bounds.height
            
        if self.gradient.tag == self.SVG_LINEARGRADIENT:
            x1,y1 = gdata['x1'], gdata['y1']
            x2,y2 = gdata['x2'], gdata['y2']
            
            if "%" in x1:
                x1 = x0 + float(x1[:-1])/100 * w
            else:
                x1 = x0 + parseLength(x1)
            
            if "%" in x2:
                x2 = x0 + float(x2[:-1])/100 * w
            else:
                x2 = x0 + parseLength(x2)
            
            if "%" in y1:
                y1 = y0 + float(y1[:-1])/100 * h
            else:
                y1 = y0 + parseLength(y1)
            
            if "%" in y2:
                y2 = y0 + float(y2[:-1])/100 * h
            else:
                y2 = y0 + parseLength(y2)
            
            data = (x1,y1,x2,y2)
            vg.SetParameterfv(self.gradientFill, vg.PAINT_LINEAR_GRADIENT, 4, data)
        else:
            cx, cy = gdata['cx'], gdata['cy']
            fx, fy = gdata['fx'], gdata['fy']
            radius = gdata['radius']
                           
            if "%" in fx:
                fx = x0 + float(fx[:-1])/100 * w
            else:
                fx = x0 + parseLength(fx)
            
            if "%" in fy:
                fy = y0 + float(fy[:-1])/100 *h
            else:
                fy = y0 + parseLength(fy)
            
            if "%" in cx:
                cx = x0 + float(cx[:-1])/100 * w
            else:
                cx = x0 + parseLength(cx)
            
            if "%" in cy:
                cy = y0 + float(cy[:-1])/100 * h
            else:
                cy = y0 + parseLength(cy)
            
            if "%" in radius:
                r = float(radius[:-1])/100 * w
            else:
                r = parseLength(radius)
            
            if (fx - cx)**2 + (fy - cy)**2 > r**2:
                angle = math.atan2(fy - cy, fx - cx)
                fx = cx + r*math.cos(angle)
                fy = cy + r*math.sin(angle)
                
            data = (cx,cy,fx,fy,r)
            vg.SetParameterfv(self.gradientFill, vg.PAINT_RADIAL_GRADIENT, 5, data)
            
    def applyStyle(self, style, save = True):
        if style is None:
            return
            
        saved = {}
        for name, value in style.iteritems():
            if name == 'hasFill':
                if save:
                    saved[name] = self.hasFill
                    
                self.hasFill = value
            
            elif name == 'hasStroke':
                if save:
                    saved[name] = self.hasStroke
                    
                self.hasStroke = value
            
            elif name == 'gradient':
                if save:
                    saved[name] = self.gradient
                    
                self.gradient = value
                
            elif name == 'fill':
                if cElementTree.iselement(value):
                    self.render(value)
                else:
                    if save:
                        saved[name] = vg.GetParameterfv(self.fill, vg.PAINT_COLOR)
                    
                    if 'fill-opacity' in style:
                        value = value[0], value[1], value[2], style['fill-opacity']
                    
                    vg.SetParameterfv(self.fill, vg.PAINT_COLOR, 4, value)
            
            elif name == 'fill-rule':
                if save:
                    saved[name] = vg.Geti(vg.FILL_RULE)
                vg.Seti(vg.FILL_RULE, value)
                
            elif name == 'stroke':
                if save:
                    saved[name] = vg.GetParameterfv(self.stroke, vg.PAINT_COLOR)
                
                if 'stroke-opacity' in style:
                    value = value[0], value[1], value[2], style['stroke-opacity']
                
                vg.SetParameterfv(self.stroke, vg.PAINT_COLOR, 4, value)
            
            elif name == 'stroke-linecap':
                if save:
                    saved[name] = vg.Geti(vg.STROKE_CAP_STYLE)
                vg.Seti(vg.STROKE_CAP_STYLE, value)
            
            elif name == 'stroke-linejoin':
                if save:
                    saved[name] = vg.Geti(vg.STROKE_JOIN_STYLE)
                vg.Seti(vg.STROKE_JOIN_STYLE, value)
            
            elif name == 'stroke-dasharray':
                if save:
                    saved[name] = vg.Getfv(vg.STROKE_DASH_PATTERN)
                vg.Setfv(vg.STROKE_DASH_PATTERN, len(value), value)
            
            elif name == 'stroke-width':
                if save:
                    saved[name] = vg.Getf(vg.STROKE_LINE_WIDTH)
                vg.Setf(vg.STROKE_LINE_WIDTH, value)
                
            elif name == 'stroke-dashoffset':
                if save:
                    saved[name] = vg.Getf(vg.STROKE_DASH_PHASE)
                vg.Setf(vg.STROKE_DASH_PHASE, value)
            
            elif name == 'stroke-miterlimit':
                if save:
                    saved[name] = vg.Getf(vg.STROKE_MITER_LIMIT)
                vg.Setf(vg.STROKE_MITER_LIMIT, value)
        
        return saved
    
    def applyTransform(self, transform, mode = None):
        if transform is None:
            return
            
        if mode is None:
            mode = vg.MATRIX_PATH_USER_TO_SURFACE
        
        if vg.Geti(vg.MATRIX_MODE) != mode:
            vg.Seti(vg.MATRIX_MODE, mode)
        
        saved = vg.GetMatrix()
        vg.MultMatrix(transform)
        
        return saved

if __name__ == '__main__':
    xmltree = cElementTree.fromstring("""<?xml
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
    
    import FLTK as Fl
    
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
    
    