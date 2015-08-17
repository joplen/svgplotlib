# Introduction #

Due to SVG attributes use of dashes a mangling scheme is used
where an underscore is mangled to a dash. So `stroke_width`
becomes `stroke-width`.

SVG Attribute values will be converted to text upon writing, so
float and int values can be passed for coordinates etc.

# General SVG #

```
svg = SVG(width="150", height="150")
g = svg.Group(stroke = "black", transform="translate(75,75)")

delta = 30
for angle in range(0,360 + delta,delta):
    x = 70.*math.sin(math.radians(angle))
    y = 70.*math.cos(math.radians(angle))
    g.Line(x1 = 0, y1 = 0, x2 = x, y2 = y)
```

![http://svgplotlib.googlecode.com/svn/wiki/images/ExampleSvg.png](http://svgplotlib.googlecode.com/svn/wiki/images/ExampleSvg.png)

[ExampleSvg.svg](http://svgplotlib.googlecode.com/svn/wiki/images/ExampleSvg.svg)

# TEX #
```
svg = SVG(width="100", height="100")
svg.TEX(r'$\sum_{i=0}^\infty x_i$', x = 1, y = 50)
```

![http://svgplotlib.googlecode.com/svn/wiki/images/ExampleTEX.png](http://svgplotlib.googlecode.com/svn/wiki/images/ExampleTEX.png)

[ExampleTEX.svg](http://svgplotlib.googlecode.com/svn/wiki/images/ExampleTEX.svg)

# Bar #

```
graph = Bar(
    (10,50,100),
    width = 1000, height = 500,
    titleColor = 'blue',
    title = 'Simple bar plot',
    xlabel = 'X axis',
    ylabel = 'Y axis',
    grid = True,
)
```

![http://svgplotlib.googlecode.com/svn/wiki/images/ExampleBar.png](http://svgplotlib.googlecode.com/svn/wiki/images/ExampleBar.png)

[ExampleBar.svg](http://svgplotlib.googlecode.com/svn/wiki/images/ExampleBar.svg)

# Gantt #

```
items = []
items.append(Duration('Item 1', date(2009, 1, 4), date(2009, 8, 10), '90%'))
items.append(Duration('Item 2', date(2009, 3, 11), date(2009, 8, 17), '50%'))
items.append(Duration('Item 3', date(2009, 4, 18), date(2009, 8, 24), '70%'))
items.append(Duration('Item 4', date(2009, 5, 25), date(2009, 8, 31), '10%'))
items.append(Duration('Item 4', date(2009, 5, 25), date(2009, 9, 27), '25%'))

graph = Gantt(items)
```

![http://svgplotlib.googlecode.com/svn/wiki/images/ExampleGantt.png](http://svgplotlib.googlecode.com/svn/wiki/images/ExampleGantt.png)

[ExampleGantt.svg](http://svgplotlib.googlecode.com/svn/wiki/images/ExampleGantt.svg)

# Graph #

```
# graph with multiple lines
# first call only sets limits and scales
graph = Graph(
    (0,20),(0,50),
    width = 1000, height = 500,
    title = 'Simple plot',
    xlabel = 'X axis',
    ylabel = 'Y axis',
    grid = True,
)

# plot lines
graph.drawLines((0,10,20),(0,50,25), 'red')
graph.drawLines((0,10,20),(10,25,50), 'blue', stroke_dasharray="5 5", stroke_width=3)
```

![http://svgplotlib.googlecode.com/svn/wiki/images/ExampleGraph.png](http://svgplotlib.googlecode.com/svn/wiki/images/ExampleGraph.png)

[ExampleGraph.svg](http://svgplotlib.googlecode.com/svn/wiki/images/ExampleGraph.svg)

# Pie #

```
graph =Pie(
    (10,50,100),
    title = 'Simple pie plot',
    labels = ('Cars', 'Boats', 'Planes'),
)
```

![http://svgplotlib.googlecode.com/svn/wiki/images/ExamplePie.png](http://svgplotlib.googlecode.com/svn/wiki/images/ExamplePie.png)

[ExamplePie.svg](http://svgplotlib.googlecode.com/svn/wiki/images/ExamplePie.svg)