
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

MESSAGE = "TYPE TEXT"

S3 = Math.sqrt 3.0
L4 = Math.log 4.0
TR = 256
String::rpt = (n) -> Array(n+1).join(this)

colors = [
    "#2E0927"
    "#D90000"
    # "#FF2D00"
    # "#FF8C00"
    # "#04756F"
# ]
# colors = [
    # "#004358"
    # "#1F8A70"
    # "#BEDB39"
    # "#FFE11A"
    # "#FD7400"
]

class Tetra extends Group
    
    subdivided: false

    constructor:(@R, p=[0,0])->

        super    
            pivot      : [0,0]
            applyMatrix: false
        @c = colors[Math.random()*colors.length|0]
        @w = @R/8
        @w = 2 if @w<2
        @t = new Path.RegularPolygon
            radius     : @R-@w*1.5
            pivot      : [0,0]
            sides      :  3
            strokeColor: @c
            strokeWidth: @w
            opacity    : 0.05

        @addChild @t
        
        @position = p
    
    subdivide:=>

        return @subdivideSelf() if not @subdivided
        do t.subdivide for t, i in @children

        @

    subdivideSelf:=>

        @t.remove()

        R = @R/2

        @addChild new Tetra(R, [      0,   0]).rotate(180)
        @addChild new Tetra(R, [      0,-R  ])
        @addChild new Tetra(R, [-R*S3/2, R/2])
        @addChild new Tetra(R, [ R*S3/2, R/2])
        
        @subdivided = true
        @

    encode:(ab)=>
        B = ab.length
        if B>2
            @subdivideSelf()

            l = Math.ceil Math.log(B/2)/L4
            s = Math.pow 4, (l-1)
            s*= 2
            # console.log s
            # s = Math.ceil B/4
            s = 2 if s<2
            for i in [0..3]
                if i*s <B
                    if (i+1)*s < B
                        d = ab.subarray i*s, (i+1)*s
                    else
                        d = ab.subarray i*s, (i+1)*s

                    @children[i].encode d
        else
            @subdivide()
            @subdivide()
            ba = (i.toString 2 for i in ab)
            ba = ("0".rpt(8-b.length)+b for b in ba).join ""
            for v, i in ba
                t = @children[i/4|0].children[i%4]
                if v is "1"
                    t.t.fillColor = t.c
                # else
                #     t.t.fillColor = "white"
                t.t.opacity = 1

            # for i in ia



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
    txt.position = [view.center.x, view.center.y+TR/2+24]
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
    fillColor: "#DDD"

bg2 = new Path.Circle
    center   : view.center
    radius   : 100
    fillColor: "#EFEFEF"

t = new Tetra 256

txt = new PointText
    point        : [0,256]
    justification: "center"
    fontFamily   : 'Arial'
    # fontWeight   : 'bold'
    fontSize     : 20
    fillColor    : colors[0]
    pivot        : [0,0]
    content      : MESSAGE

onResize()


# input = document.createElement "input"
# input.className = "input"
# input.setAttribute "type", "text"
# input.onkeyup = (e)->
    
#     t.remove()

#     t = new Tetra 256
#     onResize()

#     buf = LZString.compressToUint8Array input.value
#     # console.log "#{input.value}[#{input.value.length}] -> [#{buf.length}]"
#     t.encode buf

#     view.update()
# document.body.appendChild input

onKeyDown = (e)->

    txt.content = "" if txt.content is MESSAGE
    if e.key is "backspace"
        txt.content = txt.content[0...-1]
    else 
        txt.content += e.character

    t.remove()

    t = new Tetra TR
    onResize()

    buf = LZString.compressToUint8Array txt.content
    t.encode buf

    false



# onFrame = (e)->
#     # console.log e
#     t.rotate(0.5)
