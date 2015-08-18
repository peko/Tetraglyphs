

MESSAGE = "TYPE TEXT"

S3 = Math.sqrt 3.0
L4 = Math.log 4.0
TR = 256
String::rpt = (n) -> Array(n+1).join(this)

colors = {
    "0":"#ED5565"
    "1":"#FC6E51"
    "2":"#FFCE54"
    "3":"#A0D468"

    "4":"#48CFAD"
    "5":"#4FC1E9"
    "6":"#5D9CEC"
    "7":"#AC92EC"

    "8":"#DA4453"
    "9":"#E9573F"
    "A":"#F6BB42"
    "B":"#8CC152"

    "C":"#37BC9B"
    "D":"#3BAFDA"
    "E":"#4A89DC"
    "F":"#967ADC"
}

cid = 0
class Tetra extends Group
    
    subdivided: false

    constructor:(@R, p=[0,0])->

        super    
            pivot      : [0,0]
            applyMatrix: false
        @c = colors[(cid++)%colors.length]
        @w = @R/Math.pow(1.618,5)
        # @w = 2 if @w<2
        @t = new Path.RegularPolygon
            radius     : @R - @w
            pivot      : [0,0]
            sides      :  3
            strokeColor: @c
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
        @addChild new Tetra(R, [-R*S3/2, R/2]).rotate(-120)
        @addChild new Tetra(R, [ R*S3/2, R/2]).rotate(120)
        
        @subdivided = true

        @

    encode:(ab)=>
        B = ab.length
        if B>2
            @subdivideSelf()

            s = Math.ceil B/4
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
            ba = (i.toString 16 for i in ab)
            ba = ("0".rpt(2-b.length)+b for b in ba).join ""
            console.log ba
            for v, i in ba
                t = @children[i]
                t.t.fillColor = colors[v]
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

t = new Tetra TR

txt = new PointText
    point        : [0,TR]
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
    cid = 0
    t = new Tetra TR
    onResize()

    buf = LZString.compressToUint8Array txt.content
    # buf = new Uint8Array(str2ab(txt.content))
    t.encode buf

    false



# onFrame = (e)->
#     # console.log e
#     t.rotate(0.5)
