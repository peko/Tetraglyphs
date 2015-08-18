
# t = new Path.RegularPolygon
#     center   : view.center
#     sides    :   3
#     radius   : 200
#     fillColor: "#222"

# c1 = new Shape.Circle
#     center   : view.center
#     radius   : 100
#     strokeColor: "#CC4422"

# c2 = new Path.Circle
#     center   : view.center
#     radius   : 110
#     strokeColor: "#44CC22"

S3 = Math.sqrt 3.0
L4 = Math.log 4.0

colors = [
    "#2E0927"
    "#D90000"
    "#FF2D00"
    "#FF8C00"
    "#04756F"
# ]
# colors = [
    "#004358"
    "#1F8A70"
    "#BEDB39"
    "#FFE11A"
    "#FD7400"
]

class Tetra extends Group
    
    subdivided: false

    constructor:(@R, p=[0,0])->

        super    
            pivot      : [0,0]
            applyMatrix: false

        cid = Math.random()*colors.length|0
        @t = new Path.RegularPolygon
            radius     : @R
            pivot      : [0,0]
            sides      :  3
            fillColor  : colors[(cid++)%colors.length]

        cid = Math.random()*colors.length|0
        @c = new Path.Circle
            radius     : @R/2
            pivot      : [0,0]
            fillColor  : colors[(cid++)%colors.length]
        
        cid = Math.random()*colors.length|0
        @t2 = new Path.RegularPolygon
            radius     : @R/2
            pivot      : [0,0]
            sides      :  3
            fillColor  : colors[(cid++)%colors.length]

        @t2.rotate 180

        # cid = Math.random()*colors.length|0
        # @c2 = new Path.Circle
        #     radius     : @R/4
        #     pivot      : [0,0]
        #     sides      :  3
        #     # strokeColor: colors[(cid+3)%colors.length]
        #     fillColor: colors[(cid++)%colors.length]

        # @t.onMouseEnter = (e)->
        #   @opacity = 0.5
        #   @selected = true
        # @t.onMouseLeave = (e)->
        #   @opacity = 1.00
        #   @selected = false
        # @c.onMouseDown = (e)->
        #     console.log e
        #     @.t.subdivide()

        @addChild @t
        @addChild @c
        @addChild @t2
        # @addChild @c2

        # @x = new PointText
        #     point        : [0,@R/4]
        #     justification: "center"
        #     fontFamily   : 'Terminus'
        #     # fontWeight   : 'bold'
        #     fontSize     : @R
        #     fillColor    : colors[(cid+3)%colors.length]
        #     content      : cid
        #     pivot        : [0,0]
        #     applyMatrix  : false
        # @addChild @x
        # console.log @x

        # @m = new Marker @R/2, colors[1]
        # @addChild @m
        
        @position = p
    
    subdivide:=>

        return @subdivideSelf() if not @subdivided
        do t.subdivide for t, i in @children when Math.random()*3|0

        @

    subdivideSelf:=>

        @t.remove()
        @c.remove()
        @t2.remove()
        # @c2.remove()
        # @x?.remove()
        # @m?.remove()

        R = @R/2

        @addChild new Tetra(R, [      0,   0]).rotate(180)
        @addChild new Tetra(R, [      0,-R  ])
        @addChild new Tetra(R, [ R*S3/2, R/2])
        @addChild new Tetra(R, [-R*S3/2, R/2])
        
        @subdivided = true

        @


class Marker extends Group 

    constructor: (r,c=[0,0,0,0.1])->
        super
            pivot: [0,0]

        @addChild new Path.Line
            from: [-r*S3/2,-r/2]
            to  : [ 0, 0]
            strokeColor: c
        @addChild new Path.Line
            from: [r*S3/2,-r/2]
            to  : [0, 0]
            strokeColor: c
        @addChild new Path.Line
            from: [0,r]
            to  : [0, 0]
            strokeColor: c

        @addChild new Path.Circle
            center: [0,0]
            radius: r
            strokeColor: c

# t = new Tetra 256
# t.subdivide() for i in [0..3]
# t.position = view.center
# R = 200
# c = view.center

# t = new Path.RegularPolygon
#     radius: R
#     center: c
#     sides : 3
#     strokeColor: [0,0,0,0.25]

# r = new Path.Circle
#     radius: R
#     center: c
#     strokeColor: [0,0,0,0.25]


# # onFrame=(event)->
#     t.rotate(1, view.center);


onResize = (е)->
    bg1.fitBounds view.bounds, true
    bg2.fitBounds view.bounds, false
    t.position = view.center
    # t.fitBounds view.bounds, false

ab2str = (buf)->String.fromCharCode.apply null, new Uint16Array(buf)

str2ab = (str)->
    buf = new ArrayBuffer(str.length*2)
    bufView = new Uint16Array(buf)
    for i in [0...str.length]
        bufView[i] = str.charCodeAt(i);
    buf

bg1 = new Path.Circle
    center   : view.center
    radius   : 200
    fillColor: "#CCC"

bg2 = new Path.Circle
    center   : view.center
    radius   : 100
    fillColor: "#F8F8F8"

t = new Tetra 256
t.subdivide() for i in [0..3]
onResize

# input = document.createElement "input"
# input.className = "input"
# input.setAttribute "type", "text"
# input.onkeyup = (e)->
#     buf = str2ab input.value
#     t.encode buf
# document.body.appendChild input

# onFrame = (e)->
#     # console.log e
#     t.rotate(0.5)
