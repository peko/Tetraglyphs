# Triangle metrics
TR = 1.0           # external radius
Tr = TR/2.0        # inner radius
S3 = Math.sqrt 3.0
Ta = TR*S3         # side length

colors = [
    0xEE2244
    0x88CC44
    0x4488EE
    0xEE8844
]

class Dharma


    init: ()->
    
        @W = window.innerWidth
        @H = window.innerHeight

        @scene  = new THREE.Scene()
        @camera = new THREE.PerspectiveCamera 45, @W/@H, 1, 1000
        @camera.position.y = 0
        @camera.position.z = 400

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


    render: ()=>
        # console.log @ 
        requestAnimationFrame @render
        @renderer.render @scene, @camera

    
    onMouseDown: (e)=>

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

        z = 512
        a = x: 0     , y: TR*z
        b = x: Ta/2*z, y:-Tr*z
        c = x:-Ta/2*z, y:-Tr*z

        for cid in [@faceTriangles.children.length-1..0]
            @faceTriangles.remove @faceTriangles.children[cid]
        # @faceTriangles.children = []

        triangles = @getTriangles z, {x:x0, y:y0}, a, b, c
        z=-1.0
        cid=0
        for h, t of triangles
            # console.log h
            unless @faces[h]
                @faceTriangles.add @faces[h] = @createFaceTriangle t[0], t[1], t[2], z+=0.1, cid = ++cid % colors.length


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

        z = 512

        a = x: 0     , y: TR*z
        b = x: Ta/2*z, y:-Tr*z
        c = x:-Ta/2*z, y:-Tr*z

        # console.log @lineTriangles.children.length
        for t in @lineTriangles.children
            @lineTriangles.remove t
        @lineTriangles.children = []

        triangles = @getTriangles z, {x:x0, y:y0}, a, b, c
        cid = 0
        for h, t of triangles
            @lineTriangles.add @createLineTriangle t[0], t[1], t[2], 1.0

    
    createLineTriangle: (a, b, c, z=0.0)->

        geom = new THREE.Geometry();

        geom.vertices.push new THREE.Vector3 a.x, a.y, z
        geom.vertices.push new THREE.Vector3 b.x, b.y, z
        geom.vertices.push new THREE.Vector3 c.x, c.y, z
        geom.vertices.push new THREE.Vector3 a.x, a.y, z
        new THREE.Line( geom, new THREE.LineBasicMaterial( { color: 0xEEEEEE, opacity: 0.5} ) );


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
