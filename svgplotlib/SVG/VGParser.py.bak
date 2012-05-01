#!/usr/bin/python
# -*- coding: utf-8 -*-
import re
import math

import svgplotlib.VG as vg
from svgplotlib.SVG.Parsers import parseLength, parseAngle, parseOpacity
from svgplotlib.SVG.Parsers import parseDashArray, SVGParseError
from svgplotlib.SVG.Colors import parseColor, SVGColorError
from svgplotlib.SVG.Path import parsePath, ParsePathError
from svgplotlib.SVG.Style import parseStyle, ParseStyleError
from svgplotlib.SVG.Transform import parseTransform, ParseTransformError

INF = float('inf')

class Box:
    '''
    2d bounding box
    '''
    def __init__(self, minx = INF, miny = INF, maxx = -INF, maxy = -INF):
        self.minx = minx
        self.miny = miny
        self.maxx = maxx
        self.maxy = maxy
        
        self.transform = vg.Matrix().Identity()
    
    def __str__(self):
        args = self.minx, self.miny, self.maxx, self.maxy
        return 'Box(minx = %f, miny = %f, maxx = %f, maxy = %f)' % args
        
    @property
    def width(self):
        return self.maxx - self.minx
    
    @property
    def height(self):
        return self.maxy - self.miny
    
    @property
    def center(self):
        return .5*(self.maxx + self.minx), .5*(self.maxy + self.miny)
    
    def copy(self):
        ret = Box(self.minx, self.miny, self.maxx, self.maxy)
        ret.transform = self.transform.Copy()
        
    def update(self, x, y):
        x, y = self.transform.Map(x, y)
        
        self.minx = min(x, self.minx)
        self.miny = min(y, self.miny)
        self.maxx = max(x, self.maxx)
        self.maxy = max(y, self.maxy)
    
    def iterUpdate(self, coords):
        for x, y in coords:
            x, y = self.transform.Map(x, y)
            
            self.minx = min(x, self.minx)
            self.miny = min(y, self.miny)
            self.maxx = max(x, self.maxx)
            self.maxy = max(x, self.maxy)
    
    def union(self, other):
        self.minx = min(self.minx, other.minx)
        self.miny = min(self.miny, other.miny)
        self.maxx = max(self.maxx, other.maxx)
        self.maxy = max(self.maxy, other.maxy)

class ParserError(Exception):
    pass
    
class Parser:
    def preparse(self, node):
        # Skip non SVG nodes
        if node.tag not in self.SVG_NODES:
            return
        
        # skip seen nodes to avoid duplicate
        # parsing of referenced node in defs section
        if node in self.seen:
            return
        
        # ignore if display = none
        display = node.get('display')
        if display == "none":
            self.skip.add(node)
            return
        
        if node.tag == self.SVG_ROOT:
            self.pathtime = 0.
            
            if self.level == 0:
                self.root = node
            self.level += 1
            
            nodedata = node.tail = {}
            
            # iterate children
            for child in node:
                self.preparse(child)
            
            # find width and height
            width = node.get('width', '100%')
            if '%' in width:
                width = float(width[:-1]) / 100. * self.bounds.width
            else:
                width = parseLength(width)
                
            height = node.get('height', '100%')
            if '%' in height:
                height = float(height[:-1]) / 100. * self.bounds.height
            else:
                height = parseLength(height)
            
            self.width = width
            self.height = height
            
            # TODO: Add correct drawing width and height
            self.level -= 1
        
        elif node.tag in (self.SVG_G, self.SVG_A):
            self.level += 1
            
            nodedata = node.tail = {}
            
            # find style & transform
            self.nodeStyle(node)
            self.nodeTransform(node)
            
            savedtr = None
            if 'transform' in nodedata:
                savedtr = self.bounds.transform.Copy()
                self.bounds.transform *= nodedata['transform']
                
            # iterate children
            for child in node:
                self.preparse(child)
            
            if not savedtr is None:
                self.bounds.transform = savedtr
            
            self.level -= 1
        
        elif node.tag == self.SVG_USE:
            self.level += 1
            
            nodedata = node.tail = {}
            
            # find style & transform
            self.nodeStyle(node)
            self.nodeTransform(node)
            
            # apply 'x' and 'y' attribute as translation of defs object
            if node.get('x') or node.get('y'):
                dx = parseLength(node.get('x','0'))
                dy = parseLength(node.get('y','0'))
                
                if not 'transfom' in nodedata:
                    nodedata['transform'] = vg.Matrix().Identity()
                
                nodedata['transform'] *= vg.Matrix().Translate(dx, dy)
                
            # link id
            link_id = node.get(self.LINK).lstrip('#')
            
            # find linked node in defs or symbol section
            target = self.findLink(link_id, self.SVG_DEFS)
            if target is None:
                target = self.findLink(link_id, self.SVG_SYMBOL)
                
                if target is None:
                    raise ParserError("Could not find use node '%s'" % link_id)
            
            savedtr = None
            if 'transform' in nodedata:
                savedtr = self.bounds.transform.Copy()
                self.bounds.transform *= nodedata['transform']
                
            nodedata['target'] = target
            self.preparse(target)
            
            if not savedtr is None:
                self.bounds.transform = savedtr
            
            self.level -= 1
        
        elif node.tag in self.GRADIENT_NODES:
            nodedata = node.tail = {}
            
            # find transform
            self.nodeTransform(node)
            
            value = node.get("spreadMode")
            if value is None or value == 'pad':
                spreadMode = vg.COLOR_RAMP_SPREAD_PAD
            elif value == 'repeat':
                spreadMode = vg.COLOR_RAMP_SPREAD_REPEAT
            elif value == 'reflect':
                spreadMode = vg.COLOR_RAMP_SPREAD_REFLECT
            else:
                raise ParserError("Unknown spreadMode '%s'" % value)
                
            nodedata['spreadMode'] = spreadMode
            nodedata['unit'] = node.get("gradientUnits", "objectBoundingBox")
            
            if node.tag == self.SVG_LINEARGRADIENT:
                nodedata['x1'] = node.get("x1", "0%")
                nodedata['y1'] = node.get("y1", "0%")
                nodedata['x2'] = node.get("x2", "100%")
                nodedata['y2'] = node.get("y2", "0%")
                
                if nodedata['unit'] != "objectBoundingBox":
                    nodedata['x1'] = parseLength(nodedata['x1'])
                    nodedata['y1'] = parseLength(nodedata['y1'])
                    nodedata['x2'] = parseLength(nodedata['x2'])
                    nodedata['y2'] = parseLength(nodedata['y2'])
                    
            else:
                nodedata['cx'] = node.get("cx", "50%")
                nodedata['cy'] = node.get("cy", "50%")
                nodedata['fx'] = node.get("fx", nodedata['cx'])
                nodedata['fy'] = node.get("fy", nodedata['cy'])
                nodedata['radius'] = node.get("r", "50%")
                
                if nodedata['unit'] != "objectBoundingBox":
                    nodedata['cx'] = parseLength(nodedata['cx'])
                    nodedata['cy'] = parseLength(nodedata['cy'])
                    nodedata['fx'] = parseLength(nodedata['fx'])
                    nodedata['fy'] = parseLength(nodedata['fy'])
                    nodedata['radius'] = parseLength(nodedata['radius'])
                
            # find possible href link
            stopdef = node
            link_id = node.get(self.LINK)
            if not link_id is None:
                target = self.findLink(link_id, self.SVG_DEFS)
                if target is None:
                    raise ParserError("Link '%s' not found!" % link_id)
                stopdef = target
                
            # iterate children
            stops = []
            last = None
            for child in stopdef:
                if child.tag.endswith("stop"):
                    value = child.get("offset", "0")
                    if value.endswith("%"):
                        offset = float(value[:-1])/100.
                    else:
                        offset = float(value)
                    
                    if last is not None and last > offset:
                        offset = last
                        
                    last = offset
                    
                    opacity = parseOpacity(child.get("stop-opacity", "1."))

                    # find local style
                    style = parseStyle.parse(child.get("style") or '')
                    style_color = None
                    for name, value in style.iteritems():
                        if name == "stop-color":
                            style_color = value
                        elif name == "stop-opacity":
                            opacity = parseOpacity(value)
                    
                    color = parseColor(child.get("stop-color", style_color))
                    stops.extend([offset, color[0], color[1], color[2], opacity])
            
            nodedata['stops'] = stops
        
        elif node.tag == self.SVG_IMAGE:
            x = parseLength(node.get('x', '0'))
            y = parseLength(node.get('y', '0'))
            width = parseLength(node.get('width', '0'))
            height = parseLength(node.get('height', '0'))
            aspect = node.get('preserveAspectRatio', '')
            
            nodedata = node.tail = {}
            nodedata['pos'] = x,y
            nodedata['size'] = width,height
            nodedata['aspect'] = aspect
            
            # link id
            link_id = node.get(self.LINK)
            if link_id is None:
                raise ParserError('Missing image link')
            
            # Try to load image
            rgba_data = None
            if not self.imageprovider is None:
                rgba_data = self.imageprovider(link_id)
            
            nodedata['rgba_data'] = rgba_data
            
            # find transform
            self.nodeTransform(node)
            
            # set local bounds and update global bounds
            bounds = Box()
            bounds.transform = self.bounds.transform
            
            if 'transform' in nodedata:
                x_, y_ = nodedata['transform'].Map(x, y)
                width_,_ = nodedata['transform'].Map(width, 0.)
                _,height_ = nodedata['transform'].Map(0.,height)
                
                bounds.update(x_, y_)
                bounds.update(x_ + width_, y_ + height_)
            else:
                bounds.update(x, y)
                bounds.update(x + width, y + height)
                
            self.bounds.union(bounds)
            nodedata['bounds'] = bounds
            
            # Scale image
            if not rgba_data is None:
                w, h, _ = rgba_data
                if 'transform' in nodedata:
                    tr = nodedata['transform']
                else:
                    tr = vg.Matrix().Identity()
                
                tr *= vg.Matrix().Translate(x, y)
                tr *= vg.Matrix().Scale(width/float(w),height/float(h))
                nodedata['transform'] = tr
                
        elif node.tag == self.SVG_LINE:
            # get coordinates
            x1 = parseLength(node.get('x1', '0'))
            y1 = parseLength(node.get('y1', '0'))
            x2 = parseLength(node.get('x2', '0'))
            y2 = parseLength(node.get('y2', '0'))
            
            nodedata = node.tail = {}
            nodedata['args'] = (x1, y1, x2, y2)
            
            # find style & transform
            self.nodeStyle(node)
            self.nodeTransform(node)
            
            # set local bounds and update global bounds
            bounds = Box()
            bounds.transform = self.bounds.transform
            
            if 'transform' in nodedata:
                x1, y1 = nodedata['transform'].Map(x1, y1)
                x2, y2 = nodedata['transform'].Map(x2, y2)
            
            bounds.update(x1, y1)
            bounds.update(x2, y2)
            
            self.bounds.union(bounds)
            nodedata['bounds'] = bounds
            
        elif node.tag == self.SVG_RECT:
            # get coordinates
            x = parseLength(node.get('x', '0'))
            y = parseLength(node.get('y', '0'))
            width = parseLength(node.get('width'))
            height = parseLength(node.get('height'))
            
            rx = parseLength(node.get('rx', '0'))
            ry = parseLength(node.get('ry', '0'))
            if rx > 0. and ry == 0.:
                ry = rx
                
            nodedata = node.tail = {}
            nodedata['args'] = x, y, width, height, rx, ry
            
            # find style & transform
            self.nodeStyle(node)
            self.nodeTransform(node)
            
            # set local bounds and update global bounds
            bounds = Box()
            bounds.transform = self.bounds.transform
            
            if 'transform' in nodedata:
                x, y = nodedata['transform'].Map(x, y)
                width,_ = nodedata['transform'].Map(width, 0.)
                _,height = nodedata['transform'].Map(0.,height)
                
            bounds.update(x, y)
            bounds.update(x + width, y + height)
            
            self.bounds.union(bounds)
            nodedata['bounds'] = bounds
        
        elif node.tag == self.SVG_CIRCLE:
            cx = parseLength(node.get('cx', '0'))
            cy = parseLength(node.get('cy', '0'))
            r = parseLength(node.get('r'))
            
            if r > 0.:
                nodedata = node.tail = {}
                nodedata['args'] = cx, cy, r
            
                # find style & transform
                self.nodeStyle(node)
                self.nodeTransform(node)
                
                # set local bounds and update global bounds
                bounds = Box()
                bounds.transform = self.bounds.transform
                
                if 'transform' in nodedata:
                    cx, cy = nodedata['transform'].Map(cx, cy)
                    r1,_ = nodedata['transform'].Map(r, 0.)
                    _,r2 = nodedata['transform'].Map(0.,r)
                    r = max(r1, r2)
                    
                bounds.update(cx - r, cy - r)
                bounds.update(cx + r, cy + r)
                
                self.bounds.union(bounds)
                nodedata['bounds'] = bounds
            else:
                self.skip.add(node)
                
        elif node.tag == self.SVG_ELLIPSE:
            cx = parseLength(node.get('cx', '0'))
            cy = parseLength(node.get('cy', '0'))
            rx = parseLength(node.get('rx'))
            ry = parseLength(node.get('ry'))
            
            if rx > 0. and ry > 0.:
                nodedata = node.tail = {}
                nodedata['args'] = cx, cy, rx, ry
                
                # find style & transform
                self.nodeStyle(node)
                self.nodeTransform(node)
                
                # set local bounds and update global bounds
                bounds = Box()
                bounds.transform = self.bounds.transform
                
                if 'transform' in nodedata:
                    cx, cy = nodedata['transform'].Map(cx, cy)
                    rx,_ = nodedata['transform'].Map(rx, 0.)
                    _,ry = nodedata['transform'].Map(0.,ry)
                    
                bounds.update(cx - rx, cy - ry)
                bounds.update(cx + rx, cy + ry)
                
                self.bounds.union(bounds)
                nodedata['bounds'] = bounds
            else:
                self.skip.add(node)
                
        elif node.tag == self.SVG_POLYLINE or node.tag == self.SVG_POLYGON:
            # convert points
            points = node.get('points').strip()
            if len(points) == 0:
                self.skip.add(node)
                return
            points = map(parseLength, re.split('[ ,]+', points))
            
            nodedata = node.tail = {}
            nodedata['args'] = points
            
            # find style & transform
            self.nodeStyle(node)
            self.nodeTransform(node)
            
            # set local bounds and update global bounds
            bounds = Box()
            bounds.transform = self.bounds.transform
            
            update = bounds.update
            if 'transform' in nodedata:
                tr = nodedata['transform'].Map
                i = 0
                while i < len(points):
                    update(tr(points[i + 0] , points[i + 1]))
                    i += 2
            else:
                i = 0
                while i < len(points):
                    update(points[i + 0] , points[i + 1])
                    i += 2
            
            self.bounds.union(bounds)
            nodedata['bounds'] = bounds
            
        elif node.tag == self.SVG_PATH:
            # avoid empty path data
            pathdata = node.get('d')
            if pathdata is None or len(pathdata) < 4:
                self.skip.add(node)
                return
            
            nodedata = node.tail = {}
            
            # find style & transform
            self.nodeStyle(node)
            self.nodeTransform(node)
            
            # set local bounds and update global bounds
            bounds = Box()
            bounds.transform = self.bounds.transform
            
            update = bounds.update
            if 'transform' in nodedata:
                trans = nodedata['transform'].Map
            else:
                tr = vg.Matrix().Identity()
                trans = tr.Map
                
            segments = []
            data = []
            
            for op, args in parsePath.iterparse(pathdata):
                if op == "A" or op == "a":
                    rel = op == "a"
                    
                    for i in xrange(len(args)//7):
                        largearc, sweeparc = args[i*7 + 3], args[i*7 + 4]
                        
                        if largearc and sweeparc:
                            cmd = vg.LCCWARC_TO
                        elif largearc and not sweeparc:
                            cmd = vg.LCWARC_TO
                        elif not largearc and sweeparc:
                            cmd = vg.SCCWARC_TO
                        elif not largearc and not sweeparc:
                            cmd = vg.SCWARC_TO
                        
                        segments.append(cmd | rel)
                        data.extend(args[i*7 + 0:i*7 + 3])
                        data.extend(args[i*7 + 5:i*7 + 7])
                        
                        update(*trans(args[i*7 + 0] , args[i*7 + 1]))
                        update(*trans(args[i*7 + 5] , args[i*7 + 6]))
                
                elif op in 'zZ':
                    segments.append(pathCommands[op])
                        
                else:
                    i = 0
                    while i < len(args):
                        update(*trans(args[i + 0], args[i + 1]))
                        i += 2
                    
                    cmd = pathCommands[op]
                    count = pathArgCount(cmd)
                    
                    # Multiple MOVE_TO = polyline
                    if op in 'mM' and len(args) > count:
                        segments.append(cmd)
                        data.extend(args[:2])
                        args = args[2:]
                        cmd = vg.LINE_TO | (cmd & vg.RELATIVE)
                    
                    for i in xrange(len(args)/count):
                        segments.append(cmd)
                        data.extend(args[i*count:(i+1)*count])
                    
            self.bounds.union(bounds)
            nodedata['bounds'] = bounds
            
            nodedata['args'] = segments, data
        
        self.seen.add(node)
    
    def nodeTransform(self, node):
        nodedata = node.tail
        
        transform = node.get('transform')
        if transform is None:
            transform = node.get('gradientTransform')
            if transform is None:
                return
            
        tr = vg.Matrix().Identity()
        for op, args in parseTransform.iterparse(transform):
            if op == 'scale':
                tr *= vg.Matrix().Scale(*args)
            elif op == 'translate':
                tr *= vg.Matrix().Translate(*args)
            elif op == "skewX":
                tr *= vg.Matrix().Skew(args[0], 0.)
            elif op == "skewY":
                tr *= vg.Matrix().Skew(0., args[0])
            elif op == 'rotate':
                angle, center = args
                if center is None:
                    tr *= vg.Matrix().Rotate(angle)
                else:
                    cx, cy = center
                    tmp = vg.Matrix().Translate(cx,cy)
                    tmp *= vg.Matrix().Rotate(angle)
                    tmp *= vg.Matrix().Translate(-cx,-cy)
                    tr *= tmp
                    
            elif op == "matrix":
                tr *= vg.Matrix(*args)
        
        nodedata['transform'] = tr
        
    def nodeStyle(self, node):
        nodedata = node.tail
        nodestyle = {}
        
        # find local style
        style = parseStyle.parse(node.get('style') or '')
        
        # update with inline style
        inames = STYLE_NAMES.intersection(node.keys())
        style.update({(name, node.get(name)) for name in inames})
            
        for name, value in style.iteritems():
            if name == 'fill':
                if value == "none":
                    nodestyle['hasFill'] = False
                    continue
                
                # check for gradient fill
                if value.startswith("url"):
                    match = re.match("url\(#(?P<id>.+?)\)", value)
                    if match is None:
                        raise ParserError("Unknown '%s' url" % value)
                    link_id = match.group('id')
                    
                    # find gradient node
                    link = self.findLink(link_id, self.SVG_DEFS)
                    if link is None:
                        raise ParserError("Could not find linked node '%s'" % link_id)
                    
                    if link.tag in self.GRADIENT_NODES:
                        if not self.gradient:
                            nodestyle['gradient'] = link
                        
                        self.preparse(link)
                        value = link
                    else:
                        # skip pattern fill for now
                        value = (0.,0.,0.,1.)
                        
                else:
                    value = parseColor(value)
                    if value is None:
                        continue
                
                if not self.hasFill:
                    nodestyle['hasFill'] = True
                
            elif name == 'fill-rule':
                if value == "evenodd":
                    value = vg.EVEN_ODD
                elif value == "nonzero":
                    value = vg.NON_ZERO
                else:
                    raise ParserError("Unknown '%s' value '%s'" % (name,value))
                    
            elif name == 'stroke':
                if value == "none":
                    if self.hasFill:
                        nodestyle['hasStroke'] = False
                    continue
                
                value = parseColor(value)
                if value is None:
                    continue
                
                if not self.hasFill:
                    nodestyle['hasStroke'] = True
                    
            elif name == 'stroke-linecap':
                if value == "round":
                    value = vg.CAP_ROUND
                elif value == "butt":
                    value = vg.CAP_BUTT
                elif value == "square":
                    value = vg.CAP_SQUARE
                else:
                    raise ParserError("Unknown '%s' value '%s'" % (name,value))
            
            elif name == 'stroke-linejoin':
                if value == "round":
                    value = vg.JOIN_ROUND
                elif value == "bevel":
                    value = vg.JOIN_BEVEL
                elif value == "miter":
                    value = vg.JOIN_MITER
                else:
                    raise ParserError("Unknown '%s' value '%s'" % (name,value))
            
            elif name == 'stroke-dasharray':
                if value == "none":
                    continue
                value = parseDashArray(value)
                
            elif name in ('stroke-width', 'stroke-miterlimit', 'stroke-dashoffset'):
                value = parseLength(value)
            
            elif name in ('opacity', 'fill-opacity', 'stroke-opacity'):
                value = parseOpacity(value)
            
            nodestyle[name] = value
        
        if nodestyle:
            if 'opacity' in nodestyle:
                opacity = nodestyle['opacity']
                
                if 'fill-opacity' in nodestyle:
                    nodestyle['fill-opacity'] *= opacity
                else:
                    nodestyle['fill-opacity'] = opacity
                
                if 'stroke-opacity' in nodestyle:
                    nodestyle['stroke-opacity'] *= opacity
                else:
                    nodestyle['stroke-opacity'] = opacity
                
                del nodestyle['opacity']
            
            nodedata['style'] = nodestyle

STYLE_NAMES = frozenset((
    "fill", "fill-rule", "stroke", "stroke-width", "stroke-linejoin",
    "stroke-linecap", "stroke-dasharray", "stroke-miterlimit", "stroke-dashoffset",
    "opacity", "fill-opacity", "stroke-opacity"
))

pathCommands = {
    'M' : vg.MOVE_TO_ABS,   'm' : vg.MOVE_TO_REL,
    'Z' : vg.CLOSE_PATH,    'z' : vg.CLOSE_PATH,
    'L' : vg.LINE_TO_ABS,   'l' : vg.LINE_TO_REL,
    'H' : vg.HLINE_TO_ABS,  'h' : vg.HLINE_TO_REL,
    'V' : vg.VLINE_TO_ABS,  'v' : vg.VLINE_TO_REL,
    'C' : vg.CUBIC_TO_ABS,  'c' : vg.CUBIC_TO_REL,
    'S' : vg.SCUBIC_TO_ABS, 's' : vg.SCUBIC_TO_REL,
    'Q' : vg.QUAD_TO_ABS,   'q' : vg.QUAD_TO_REL,
    'T' : vg.SQUAD_TO_ABS,  't' : vg.SQUAD_TO_REL
}

def pathArgCount(cmd):
    one = (vg.HLINE_TO, vg.VLINE_TO)
    two = (vg.MOVE_TO, vg.LINE_TO, vg.SQUAD_TO)
    four = (vg.QUAD_TO, vg.SCUBIC_TO)
    
    cmd -= cmd % 2
    if cmd == vg.CLOSE_PATH:
        return 0
    elif cmd in one:
        return 1
    elif cmd in two:
        return 2
    elif cmd in four:
        return 4
    
    return 6