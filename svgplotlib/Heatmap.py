

from svgplotlib import SVG, Base

import itertools
import math
import re
import sys
import xml.etree.cElementTree as ET
import xml.etree.ElementTree as etree


class Heatmap(Base):
    ## SVG attributes
    width  = 480  # total width
    height = 640  # total height
    ## VALUE attributes
    min  = 0
    mid  = 50
    max  = 100
    ## COLOUR ATTRIBUTES
    cold = '0066FF'
    nowt = '000000'
    hot  = 'FF3300'
    ## LABEL attributes
    topshift = 0
    leftshift = 0
    xscale = 0  # text height (on x-axis where it's rotated)
    yscale = 0  # text height (on y-axis where it's not)
    xpad   = 1    # gap between top labels
    ypad   = 1    # gap between left labels
    ## LEGEND attributes
    leght  = 20 # height
    legwd  = 10  # width

    def __init__(self, matrix, xlabels=None, ylabels=None,
                       width=None, height=None,
                       xpad=0, ypad=0,
                       n_groups=None,
                       **kwargs ):
        """
        >>> matrix = [ [0,1,2], [2,1,0] ]
        >>> xlabels = ['a','b']
        >>> ylabels = ['1','2','3']
        >>> heat = Heatmap( matrix, xlabels, ylabels, width=60,height=40 )
        >>> heat.set_colours( 0, 1, 2 )
        >>> heat.draw()
        >>> 
        """
        super( Heatmap, self ).__init__(**kwargs)
        xlabels = [ str(xval) for xval in xlabels ]
        ylabels = [ str(yval) for yval in ylabels ]
        self.n_cols = len(xlabels) + 1
        self.n_rows = len(ylabels)

        # pre-calc top shift for x-axis labels (vertical text)
        longestlabel    = max([(len(xval),i) for i,xval in enumerate(xlabels)])
        biggestsize     = self.textSize(xlabels[longestlabel[1]])
        self.topshift   = int(min(150, biggestsize[0] ))
        self.yscale     = int(biggestsize[1])
        self.leght      = int(biggestsize[1])
        self.topshift  += int(biggestsize[1]*2)
        self.xpad, self.ypad = xpad, ypad
        if height is None:
            height =  ( self.yscale + ypad ) * len(ylabels) + \
                        self.topshift + self.leght 
            height = '{0:.0f}'.format(height)
            self.set('height', height)

        # same for left (y-labels)
        longestlabel    = max([(len(str(yval)),i) for i,yval in enumerate(ylabels)])
        biggestsize     = self.textSize(ylabels[longestlabel[1]])
        self.leftshift  = int(biggestsize[0])
        self.xscale     = int(biggestsize[1])

        if width is None:
            width  =  ( self.xscale + xpad ) * len(xlabels) + \
                        self.leftshift + self.legwd
            width  = '{0:.0f}'.format(width)
            self.set('width', width)

        self.set( 'viewBox', '0 0 {0.02f} {1:.02f}'.format( width/2., height/2. ) )

        self.matrix = matrix
        self.save_labels(xlabels, ylabels)
        self.n_groups = n_groups 
        self.styles  = { '.row'      : { 'height'  : self.yscale },
                         '#xlabels'  : { 'width'   : self.leght ,
                                         'height'  : self.yscale },
                         '.row > use' : { 'width'  : self.xscale },
                         '.row > text': { 'width'       : self.leftshift,
                                          'text_anchor' : 'end' }
                    }
        try:
            self.Style( **self.styles )
        except Exception,e:
            print self.styles
            styles = self.Style()
            styles.update( self.styles )

    
        #self.transform_script()
    hexed = re.compile( '([0-9a-fA-F]{2})' )
    def set_style( self, **attrib ):
        """Sets any number of style options to be written to the SVG at
        the top of the SVG."""
        mangle = self.mangle
        for selector in attrib:
            attrib = tuple( map(lambda item: ( mangle.sub(item[0],'-'), item[1], ),
                               attrib[selector].items() ) )
        for key, value in attrib.items():
            if key in self.styles:
                self.styles[key] += ' {0}'.format(value)
            else:
                self.styles.update( { key : value } )

    def set_colours( self, minlim, mid, maxlim ):
        """Factory method. Returns a colour generator that can be
        used to generate an RGB hex colour from a value in the
        range minlim - maxlim. Values that are equal to mid
        will get the colour 'nothing', (default black).
        Values that converge on minlim get a cold colour, and
        vice-versa for values converging towards maxlim.

        Before returning, self.heat_color is replaced with
        the colour generator, so there's no need to keep hold
        of the returned function.
        """
        self.min = minlim
        self.mid = mid
        self.max = maxlim
        cold     = self.cold
        hot      = self.hot
        nothing  = self.nowt

        ## Convert hex values to ints
        r,g,b   = self.hexed.findall(cold)
        coldhex = [ int('0x{0}'.format(c),16) for c in (r,g,b,) ]
        r,g,b   = self.hexed.findall(hot)
        hothex  = [ int('0x{0}'.format(c),16) for c in (r,g,b,) ]
        r,g,b   = self.hexed.findall(nothing)
        nothing = [ int('0x{0}'.format(c),16) for c in (r,g,b,) ]

        ## Norm each rgb colour value around mid 
        coldnorm = map( lambda c,n : c-n , coldhex, nothing )
        hotnorm  = map( lambda h,n : h-n , hothex,  nothing )

        ## Pre-calculate normalisation constants for given values.
        upnorm  = maxlim - mid
        _upnorm = 1./upnorm
        lownorm = minlim  - mid
        _lownorm= 1./lownorm

        def colorgen( value ):
            """value must be within the range min - max, as given
            to set_colours"""
            if value == mid:
                rgb = nothing
            elif value > mid:
                nval = value * _upnorm
                rgb  = [ int(nval*c) for c in hotnorm ]
            else:
                nval = value * _lownorm
                rgb  = [ int(nval*c) for c in coldnorm ]
            return '#{0:02X}{1:02X}{2:02X}'.format(*rgb)

        if self.n_groups is not None:
            def RGB( rgb_list ):
                return '#{0:02X}{1:02X}{2:02X}'.format(*rgb_list)

            def gen_groups(group_diff, prefix='h'):
                cur   = mid + group_diff
                i = 0
                colours = []
                while cur <= maxlim and cur >= minlim:
                    id = '{0}{1}'.format(prefix,i)
                    self.defs.Rect( id=id, fill=colorgen(cur),
                                    width=self.xscale, height=self.yscale )
                    colours.append(cur)
                    cur += group_diff
                    i   += 1
                id = '{0}{1}'.format(prefix,i)
                self.defs.Rect( id=id, fill=colorgen(cur),
                                width=self.xscale, height=self.yscale )
                colours.append(cur)
                return colours

            ## half the groups in cold_groups, other half in hot_groups
            colour_groups = {}
            cold_gdiff = _lownorm * .5 / self.n_groups
            hot_gdiff  = _upnorm  * .5 / self.n_groups
            self.defs.Rect( id='0', fill = RGB(nothing),
                            width=self.xscale, height=self.yscale )

            colour_groups.update( { 'cold' : gen_groups(cold_gdiff, prefix='c') } )
            colour_groups.update( { 'hot'  : gen_groups(hot_gdiff , prefix='h') } )

        def IDgen( value ):
            """ Alternate colour generator that returns id's, referencing a
            rect in the SVG's defs section."""
            i = 0
            if value == mid:
                id = '#0'
            elif value < mid:
                cold = colour_groups['cold']
                while value < cold[i]:
                    i += 1
                id = '#c{0}'.format(i)
            else: # value > mid
                hot = colour_groups['hot']
                while value > hot[i]:
                    i += 1
                id = '#h{0}'.format(i)
            return id
        self.heat_ID    = IDgen
        self.heat_color = colorgen
        return colorgen

    def draw(self):
        min, mid, max = self.min, self.mid, self.max
        xlabels, ylabels = self.xlabels, self.ylabels
        n_x = len( xlabels )
        n_y = len( ylabels )

        g = self.g = self.Group(id='heatmaps',
            transform="translate({0},{1})".format(self.leftshift, self.topshift) )

        self.r = g.Group(id='xlabels', transform="rotate(-90)")
        #self.r.set('class','row')

        map( self.set_xlabel, enumerate(xlabels) )
        set_ylabel = self.set_ylabel

        if self.n_groups is not None:
            make_rect = self.use_rect
        else:
            make_rect = self.make_rect
        yshift = self.yscale + self.ypad

        for y,ylabel in enumerate( self.ylabels ):
            r = self.r = g.Group(transform="translate(0,{0:.0f})".format(y*yshift) )
            r.set('class','row')
            set_ylabel( (y,ylabel) )
            ylab = ((y,ylabel,),) * n_x
            map( make_rect, enumerate(xlabels), ylab )
        self.draw_legend()
        return

    def draw_box( self, xlabel_ylabel ):
        xlabel, ylabel = xlabel_ylabel
        xind, xlabel = xlabel
        yind, ylabel = ylabel
        x = self.leftshift + (xind*self.xscale) + (xind*self.xpad)
        y = self.topshift  + (yind*self.yscale) + (yind*self.ypad)
        val  = self.matrix[xind][yind]
        rect = self.g.Rect( x=x, y=y, 
                width = '{0:.0f}'.format(self.xscale + self.xpad),
                height= '{0:.0f}'.format(self.yscale + self.xpad),
                fill  = self.heat_color(val),
                )
        return rect.element

    def draw_legend(self):
        x , y = 0, self.leght*1.5 #-(self.leftshift), - (self.topshift)
        minc =  self.heat_color(self.min)
        midc =  self.heat_color(self.mid)
        maxc =  self.heat_color(self.max)
        g = self.Group( id="legend" )

        grad = self.defs.linearGradient( id='hot' , x1=0, x2=0, y1=1, y2=0 )
        s = grad.Stop(offset='0', stop_color=midc )
        s = grad.Stop(offset='1', stop_color=maxc )

        grad = self.defs.linearGradient( id='cold', x1=0, x2=0, y1=0, y2=1 )
        s = grad.Stop(offset='0'  , stop_color=midc )
        s = grad.Stop(offset='1'  , stop_color=minc,  )

        yt  = y - self.leght
        ym  = y
        yb  = y + self.leght

        rect = g.Rect(fill="url(#hot)",  stroke="black", stroke_width=1,
                x=x, y=yt, width=self.legwd, height=self.leght*2 )
        rect = g.Rect(fill="url(#cold)", stroke="black", stroke_width=1,
                x=x, y=yb, width=self.legwd, height=self.leght*2 )

        x     += self.legwd * 2
        yshift = self.leght *.5
        
        labels  = [ str(val) for val in (self.min,self.mid,self.max) ]

        yt += yshift 
        ym += yshift +   self.leght
        yb += yshift + 2*self.leght

        g = g.Group( id='legendlabels' )
        topl = g.Text( x=x ,y=yt )
        topl.text = labels[2]
        midl = g.Text( x=x ,y=ym )
        midl.text = labels[1]
        botl = g.Text( x=x ,y=yb )
        botl.text = labels[0]

    def heat_color(self,value):
        print "Run {0}.set_colours() first".format( self.__class__.__name__ )

    def heat_ID(self,value):
        print "Run {0}.set_colours() first".format( self.__class__.__name__ )

    def transform_script(self):
        js = u"""
window.onload = function() {{
  var cols, row;
  var ncols = {ncols};
  var rows = document.getElementsByClassName("row");
  var nrows = {nrows};
  for (var i=0; i<nrows; i++) {{
    row = rows[i];
    row.setAttribute("transform",'translate(0,'+ (i*{rowht}) + ')');
    cols = row.children;
    cols[0].setAttribute("transform", 'translate(0,{rowwd})');
    for (var c=1; c<ncols ; c++) {{
      cols[c].setAttribute("transform", 'translate(' + ({rowwd}*c) + ',0)' );
    }}
  }}
  adjustXLabel();
}}

function adjustXLabel() {{
  var xlabels = document.getElementById("xlabels");
  xlabels.setAttribute("transform", "rotate(-90)");
  var labels = xlabels.children;
  var nlabels = labels.length;
  var label, tr, transform;
  for (var i=0; i<nlabels; i++) {{
     label = labels[i];
     tr = label.getAttribute("transform");
     transform = (tr==null) ? "translate(0," + ({rowwd2}+{rowwd}*i)+")" :   tr  +  "translate(0," + ({rowwd2}+{rowwd}*i)+")" ;
     /*transform = (tr==null) ? "rotate(-90)"" :   tr  +  " rotate(-90)";*/
     label.setAttribute("transform", transform);
    }}
}}
""".format( ncols=self.n_cols, nrows=self.n_rows, rowht=self.yscale, rowwd=self.xscale, rowwd2=2*self.xscale )
        dom = self.Script( )
        dom.text = js

    def make_rect(self, xlabel, ylabel ):
        xind, xlabel = xlabel
        yind, ylabel = ylabel
        x = self.leftshift + (xind*self.xscale) + (xind*self.xpad)
        y = self.topshift  + (yind*self.yscale) + (yind*self.ypad)
        val  = self.matrix[xind][yind]
        rect = self.r.Rect( 
            width  = self.xscale+self.xpad,
            height = self.yscale+self.ypad,
            fill = self.heat_color(val),
            transform="translate({0},{1})".format(x,y)
        )
        return rect

    def use_rect(self, xlabel, ylabel ):
        xind, xlabel = xlabel
        yind, ylabel = ylabel
        #xpos = self.leftshift  + (xind*self.xscale) + (self.xscale*.75) + (xind*(2*self.xpad))
        #ypos = self.topshift + (yind*self.yscale) + (self.yscale*.75) + (yind*(2*self.ypad))
        xpos = xind * ( self.xscale + self.xpad )
        val  = self.matrix[xind][yind]
        use  = self.r.Use( transform="translate({0},0)".format(xpos) )
        use.set( 'xlink:href', self.heat_ID(val) )
        return use 

    def save_labels(self,xlabels=None,ylabels=None):
        if xlabels is not None:
            self.xlabels = xlabels
        if ylabels is not None:
            self.ylabels = ylabels

    def set_xlabel(self, label, angle=-90):
        xind, label = label
        ### x and y switched because the group is rotated
        #x = - self.topshift
        #y = self.leftshift  + (xind*self.xscale) + (self.xscale*.75) + (xind*(2*self.xpad))
        x = 0
        y = self.xscale + self.xscale*xind
        #y = 2*self.xscale + self.xscale + xind
        #node = self.g.Text( x=xpos, y=ypos ) # , transform="rotate({0})".format(angle) )
        node = self.r.Text( transform="translate({0},{1})".format(x,y) )
        node.text = unicode(label)
        return node.element

    def set_ylabel(self, label, angle=0):
        yind, label = label
        x = - self.leftshift*.5 #self.leftshift  + (xind*self.xscale) + (self.xscale*.75) + (xind*(2*self.xpad))
        y = .75*self.yscale  #(yind*self.yscale) + (self.yscale*.75) + (yind*(2*self.ypad))
        #node = self.r.Text( x=xpos, y=ypos )   # , transform="rotate({0})".format(angle) )
        node = self.r.Text( transform="translate(0,{0})".format(y) )
        node.text = unicode(label)
        return node.element

    def write(self, file=sys.stdout, header=True, encoding='utf-8', **kwargs):
        return super(Heatmap,self).write(file=file, header=header, encoding=encoding, method='svg')


_encode = etree._encode
_escape_attrib = etree._escape_attrib
_escape_attrib_html = etree._escape_attrib_html
_escape_cdata = etree._escape_cdata
Comment = etree.Comment
ProcessingInstruction = etree.ProcessingInstruction
QName = etree.QName


def _serialize_svg(write, elem, encoding, qnames, namespaces):
    tag = elem.tag
    text = elem.text
    if tag is Comment:
        write("<!--%s-->" % _escape_cdata(text, encoding))
    elif tag is ProcessingInstruction:
        write("<?%s?>" % _escape_cdata(text, encoding))
    else:
        tag = qnames[tag]
        if tag is None:
            if text:
                write(_escape_cdata(text, encoding))
            for e in elem:
                _serialize_svg(write, e, encoding, qnames, None)
        else:
            write("<" + tag)
            items = elem.items()
            if items or namespaces:
                if namespaces:
                    for v, k in sorted(namespaces.items(),
                                       key=lambda x: x[1]):  # sort on prefix
                        if k:
                            k = ":" + k
                        write(" xmlns%s=\"%s\"" % (
                            k.encode(encoding),
                            _escape_attrib(v, encoding)
                            ))
                for k, v in sorted(items):  # lexical order
                    if isinstance(k, QName):
                        k = k.text
                    if isinstance(v, QName):
                        v = qnames[v.text]
                    else:
                        v = _escape_attrib_html(v, encoding)
                    write(" %s=\"%s\"" % (qnames[k], v))
            if text or len(elem):
                write(">")
                if text:
                    if tag == "script" or tag == "style":
                        write(_encode(text, encoding))
                    else:
                        write(_escape_cdata(text, encoding))
                for e in elem:
                    _serialize_svg(write, e, encoding, qnames, None)
                write("</" + tag + ">")
            else:
                write(" />")
    if elem.tail:
        write(_escape_cdata(elem.tail, encoding))
        
etree._serialize.update( { 'svg' : _serialize_svg } )

if __name__ == '__main__':
    from svgplotlib.SVG import Backend
    matrix = [ range(10), range(10,0,-1), range(-10,0)]
    for i,m in enumerate(matrix):
        print 'x[{0}]: {1}'.format(i,m)
    xlabels = ['1asdf','2dfj','3alsdf']
    ylabels = ['a'] * 10
    svg = Heatmap( matrix, xlabels, ylabels, n_groups=20 )
    svg.set_colours( -10, 0, 10 )
    svg.draw()
    Backend.show(svg)
    outfile = '/var/www/html/svgtest2.svg'
    with file( outfile,'w') as handle:
        svg.write(handle)
    print ''
