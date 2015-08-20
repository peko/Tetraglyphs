bg1 = new Path.Circle
    center   : view.center
    radius   : 200
    fillColor: "#EEE"

bg2 = new Path.Circle
    center   : view.center
    radius   : 100
    fillColor: "#F8F8F8"

S3 = Math.sqrt 3.0

colors = [
    "#2E0927"
    # "#D90000"
    # "#FF2D00"
    "#FF8C00"
    # "#04756F"
]
cid = 0 
class Tetra extends Group
    
    subdivided: false

    constructor:(@R, p=[0,0])->

        super    
            pivot      : [0,0]
            applyMatrix: false

        @t = new Path.RegularPolygon
            radius     : @R+0.3
            pivot      : [0,0]
            sides      :  3
            # fillColor  : colors[(cid++)%colors.length|0]
            fillColor  : colors[0]
        @t.cid = 0

        # @t.onMouseEnter = (e)->
        #   @opacity = 0.5
        #   @selected = true
        # @t.onMouseLeave = (e)->
        #   @opacity = 1.00
        #   @selected = false
        @t.onMouseDown = (e)->
            @cid = (@cid+1)%2
            @fillColor = colors[@cid]
        @t.onMouseEnter = (e)->
            if e.event.buttons
                @cid = (@cid+1)%2
                @fillColor = colors[@cid]      

        @addChild @t

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
        do t.subdivide for t, i in @children

        @

    subdivideSelf:=>

        @t.remove()
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

t = new Tetra 256
t.subdivide() for i in [0..1]
t.position = view.center

onResize = (е)->
    bg1.fitBounds view.bounds, true
    bg2.fitBounds view.bounds, false
    t.position = view.center
