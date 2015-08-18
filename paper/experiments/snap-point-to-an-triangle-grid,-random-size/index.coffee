# forked from peko's "forked: Barycentric fractal space" http://jsdo.it/peko/eP1d
# Triangle metrics
TR = 1.0           # external radius
Tr = TR/2.0        # inner radius
S3 = Math.sqrt 3.0
Ta = TR*S3         # side length

colors = [
    0xEE2244
    0x88CC44
    0x4488EE
    0xEE8844]

class Dharma

    init: ()->
    
        @W = window.innerWidth
        @H = window.innerHeight

        @scene  = new THREE.Scene()
        @camera = new THREE.PerspectiveCamera 45, @W/@H, 1, 1000
        # @camera = new THREE.OrthographicCamera( -@W / 2, @W / 2, @H / 2, -@H / 2, 1, 1000 );
        @camera.position.y = 0
        @camera.position.z = 40

        # @renderer = new THREE.WebGLRenderer({antialias:true})
        @renderer = new THREE.CanvasRenderer()
        @renderer.setSize @W, @H
        @renderer.domElement.addEventListener 'mousemove', @onMouseMove, false 
        @renderer.domElement.addEventListener 'mousedown', @onMouseDown, false 

        @projector = new THREE.Projector()
        @mouse     = new THREE.Vector3()

        @scene.add new THREE.AmbientLight 0x444444
        @scene.add @lineTriangles = new THREE.Object3D
        @scene.add @faceTriangles = new THREE.Object3D

        @faces = {}

        for a in [0..600]
            @poinToTriangle (15-a/40)*Math.sin(a/100*Math.PI), (15-a/40)*Math.cos(a/100*Math.PI) 

        document.body.appendChild @renderer.domElement
        
        do @render


    # convert p{x,y} from cartesian to barycentric coordinate system
    c2b: (p, a, b, c)->

        ac = x: a.x-c.x, y: a.y-c.y
        bc = x: b.x-c.x, y: b.y-c.y
        pc = x: p.x-c.x, y: p.y-c.y
        
        d = (bc.y*ac.x-bc.x*ac.y)
        u = (bc.y*pc.x-bc.x*pc.y)/d
        v = (ac.x*pc.y-ac.y*pc.x)/d
        w = 1 - u - v 

        u: u
        v: v
        w: w

    # convert p{u,v} from barycentric to cartesian coordinate system
    b2c = (u, v, a, b, c)->
        w = 1 - u - v
        x: a.x*u + b.x*v + c.x*w
        y: a.y*u + b.y*v + c.y*w

    # recursive grabs triangles contains p{x,y}
    getTriangles: (z, p, a, b, c, T=null, H=null)->
        
        z = z>>1
        # @scene.add @createLineTriangle a, b, c

        if z==0 then return T
        
        br = @c2b p, a, b, c
        # console.log z, p, a, b, c

        if br.u>0 and br.v>0 and br.w>0
            
            T?={}
            H?=0b100

            T[H] = [a,b,c]
            
            ab = x: (a.x+b.x)/2, y: (a.y+b.y)/2
            bc = x: (b.x+c.x)/2, y: (b.y+c.y)/2
            ca = x: (c.x+a.x)/2, y: (c.y+a.y)/2
            
            if br.u<=1/2 and br.v<=1/2 and br.w<=1/2
                @getTriangles z, p, ab, bc, ca, T, H<<2|0b00             #00
            if br.u>1/2 then @getTriangles z, p, a, ab, ca, T, H<<2|0b01 #01
            if br.v>1/2 then @getTriangles z, p, ab, b, bc, T, H<<2|0b10 #10
            if br.w>1/2 then @getTriangles z, p, ca, bc, c, T, H<<2|0b11 #11

        return T

    # grabs triangle contains p{x,y}
    getTriangle: (p, a, b, c)->        
        br = @c2b p, a, b, c
        u = Math.floor br.u
        v = Math.floor br.v
        w = Math.floor br.w
        d = (u+v+w)%2
        inc = if not d then 1/3 else 2/3
        # console.log d, inc
        cor = b2c (u+inc), (v+inc), a, b, c
        T = if not d then [
             { x: cor.x+a.x, y: cor.y+a.y },
             { x: cor.x+b.x, y: cor.y+b.y },
             { x: cor.x+c.x, y: cor.y+c.y }]
        else [
             { x: cor.x+a.x, y: cor.y-a.y },
             { x: cor.x-b.x, y: cor.y-b.y },
             { x: cor.x-c.x, y: cor.y-c.y }]

        T.push {u:u+inc, v:v+inc, w:1-u-v-inc*2}
        T

    render: ()=>
        # console.log @ 
        requestAnimationFrame @render
        @renderer.render @scene, @camera

    
    onMouseDown: (e)=>

        # e.preventDefault();
        # m   = new THREE.Vector3
        # m.x =  ( e.clientX / window.innerWidth  ) * 2 - 1
        # m.y = -( e.clientY / window.innerHeight ) * 2 + 1
        # m.z = 0.5
        
        # # search intersection with plane z=0 
        # @projector.unprojectVector m, @camera
        # o = @camera.position
        # x0 = o.z*m.x/(o.z-m.z)
        # y0 = o.z*m.y/(o.z-m.z)

        # z = 256
        # a = x: 0     , y: TR*z
        # b = x: Ta/2*z, y:-Tr*z
        # c = x:-Ta/2*z, y:-Tr*z

        # # for t in @faceTriangles.children
        # #     @faceTriangles.remove t
        # # @faceTriangles.children = []

        # triangles = @getTriangles z, {x:x0, y:y0}, a, b, c
        # z=-1.0
        # for h, t of triangles
        #     # console.log h
        #     unless @faces[h]
        #         @faceTriangles.add @faces[h] = @createFaceTriangle t[0], t[1], t[2], z+=0.01


    onMouseMove: (e)=>

        e.preventDefault();
        m   = new THREE.Vector3
        m.x =  ( e.clientX / window.innerWidth  ) * 2 - 1
        m.y = -( e.clientY / window.innerHeight ) * 2 + 1
        m.z = 0.5
        
        # search intersection with plane z=0 
        @projector.unprojectVector m, @camera
        o = @camera.position
        x0 = o.z*m.x/(o.z-m.z)
        y0 = o.z*m.y/(o.z-m.z)

        @poinToTriangle x0, y0

    poinToTriangle: (x, y)=>
        z = Math.pow(2, Math.random()*3|0)
        #z = 1
        a = x: 0     , y: TR*z
        b = x: Ta/2*z, y:-Tr*z
        c = x:-Ta/2*z, y:-Tr*z
        
        t = @getTriangle {x:x, y:y}, a, b, c
        h = "#{t[3].u*3|0}|#{t[3].v*3|0}"
        @triangles?={}
        unless @triangles[h]
            @faceTriangles.add @triangles[h] = @createFaceTriangle t[0], t[1], t[2], 0, Math.random()*colors.length|0


    createLineTriangle: (a, b, c, z=0.0)->

        geom = new THREE.Geometry();

        geom.vertices.push new THREE.Vector3 a.x, a.y, z
        geom.vertices.push new THREE.Vector3 b.x, b.y, z
        geom.vertices.push new THREE.Vector3 c.x, c.y, z
        geom.vertices.push new THREE.Vector3 a.x, a.y, z
        new THREE.Line( geom, new THREE.LineBasicMaterial( { color: 0xDDDDDD, opacity: 1.0} ) );


    createFaceTriangle: (a, b, c, z=0.0, cid=0)->

        geom = new THREE.Geometry();

        geom.vertices.push new THREE.Vector3 a.x, a.y, z
        geom.vertices.push new THREE.Vector3 c.x, c.y, z
        geom.vertices.push new THREE.Vector3 b.x, b.y, z

        geom.faces.push( new THREE.Face3( 0, 1, 2 ) );
        geom.computeFaceNormals()
        new THREE.Mesh( geom, new THREE.MeshBasicMaterial( { color: colors[cid], opacity: 0.5} ) );


dharma = new Dharma
do dharma.init
