# forked from peko's "Cellular automat in triangle grid with controls" http://jsdo.it/peko/lS4M
# RULES
# ORIGINAL CONWAY'S
#death = [0,1,    4,5,6,7,8,9,10,11,12]
#life  = [     3                      ]
life  = [      3                     ]
death = [0,1,    4,5,6,7,8,9,10,11,12]

R =   1.0
r = R/2.0
s = Math.sqrt 3.0
a = R*s

#W = window.innerWidth
#H = window.innerHeight
W = H = 128 * 3


MOUSEDOWN = false
PAUSED = false
MODE = "ON"
nextMat = 0

#mat1 = new THREE.MeshBasicMaterial color: 0xDDDDDD

#mat2 = new THREE.MeshBasicMaterial color: 0x222222
#mat3 = new THREE.MeshBasicMaterial color: 0xDD2222
#mat4 = new THREE.MeshBasicMaterial color: 0xDD6666
#mat5 = new THREE.MeshBasicMaterial color: 0xFFFFFF

mat1 = new THREE.MeshBasicMaterial color: 0xDDDDDD

mat2 = new THREE.MeshBasicMaterial color: 0x118844
mat3 = new THREE.MeshBasicMaterial color: 0x66BB22
mat4 = new THREE.MeshBasicMaterial color: 0xAADD66
mat5 = new THREE.MeshBasicMaterial color: 0xFFFFFF

#mat1 = new THREE.MeshBasicMaterial color: 0xDDDDDD

#mat2 = new THREE.MeshBasicMaterial color: 0x441188
#mat3 = new THREE.MeshBasicMaterial color: 0x6622BB
#mat4 = new THREE.MeshBasicMaterial color: 0xAA22DD
#mat5 = new THREE.MeshBasicMaterial color: 0xFFFFFF

mats = [mat2, mat3, mat4, mat5]

face1 = new THREE.Geometry()
face1.vertices.push( new THREE.Vector3(    0,  R, 0 ) );
face1.vertices.push( new THREE.Vector3( -a/2, -r, 0 ) );
face1.vertices.push( new THREE.Vector3(  a/2, -r, 0 ) );
face1.faces.push( new THREE.Face3( 0, 1, 2 ) );
face1.computeFaceNormals()

face2 = new THREE.Geometry()
face2.vertices.push( new THREE.Vector3(    0, -R, 0 ) );
face2.vertices.push( new THREE.Vector3(  a/2,  r, 0 ) );
face2.vertices.push( new THREE.Vector3( -a/2,  r, 0 ) );
face2.faces.push( new THREE.Face3( 0, 1, 2 ) );
face2.computeFaceNormals()
# do @face1.computeCentroids
# do @face1.computeBoundingSphere

        
scene  = new THREE.Scene()
camera = new THREE.PerspectiveCamera 30, W/H, 0.1, 1000
camera.position.y =  8
camera.position.z = 170

scene.add new THREE.AmbientLight 0xFFFFFF

plane = new THREE.Mesh(new THREE.PlaneGeometry(150, 150), new THREE.MeshBasicMaterial({color:0x99cc44}))
plane.position.z = -1
scene.add plane 

#light1 = new THREE.DirectionalLight 0xFFCCAA, 1.5
#light1.position.set  0, 15, 15
#scene.add light1

#light2 = new THREE.DirectionalLight 0x4422CC, 1.5
#light2.position.set 0,-15, 15
#scene.add light2

#window.renderer = new THREE.WebGLRenderer()
window.renderer = new THREE.CanvasRenderer()
window.renderer.setClearColor 0xFFFFFF, 0
window.renderer.setSize W, H
# renderer.domElement.addEventListener 'mousemove', onDocumentMouseMove, false );
projector = new THREE.Projector()
mouse     = new THREE.Vector3()

document.body.appendChild renderer.domElement

# ------------------------------------------------------------------------------

class Atom extends THREE.Object3D

    @meshes:[]

    constructor: (@i, @j)->
        
        super()
        
        @d = Math.abs((@i+@j+1)%2)
        @position.x = @i*a/2.0
        @position.y = @j*a/2.0*s + @d*R/2.0

        # console.log @i, @j, @position.x, @position.y

        @position.x *= 1.1
        @position.y *= 1.1
        
        # console.log @i, @j, @x, @y/r

        # @geo = new THREE.SphereGeometry(r/2.0, 0)
        @on = Math.random()>0.5
        # @on = false
        mat = if @on then mats[Math.random()*mats.length|0] else mat1
        @face = if Math.abs((@j+@i)%2) then face1 else face2
        Atom.meshes.push @mesh = new THREE.Mesh @face, mat
        @mesh.atom = @
        @add @mesh

    toggle:=>
        # console.log "toggle"
        @on = !@on
        @mesh.material = if @on then mats[Math.random()*mats.length|0] else mat1

    setOn:=>
        # console.log "toggle"
        @on = true
        @mesh.material = mats[nextMat]
        
    
    setOff:=>
        # console.log "toggle"
        @on = false
        @mesh.material = mat1

# ------------------------------------------------------------------------------

class Structure extends THREE.Object3D

    atoms: {}

    constructor:()->
        
        super()        
        
        @rotation.z = Math.PI
        A = 14
        for j in [-A*2..A]
            l = 2*A+j
            for i in [-l..l]
                @add atom = new Atom i, j
                @atoms["#{i}:#{j}"] = atom


    cellularCalcs:=>

        return if MOUSEDOWN or PAUSED
        
        nextMat = (nextMat+1)%mats.length
        
        for i, a of @atoms
            a.c = 0
            if a.d
                a.c+= @atoms["#{a.i-1}:#{a.j  }"]?.on|0
                a.c+= @atoms["#{a.i+1}:#{a.j  }"]?.on|0
                a.c+= @atoms["#{a.i  }:#{a.j+1}"]?.on|0
                
                a.c+= @atoms["#{a.i-2}:#{a.j+1}"]?.on|0
                a.c+= @atoms["#{a.i-2}:#{a.j  }"]?.on|0
                a.c+= @atoms["#{a.i-1}:#{a.j+1}"]?.on|0
                
                a.c+= @atoms["#{a.i+2}:#{a.j+1}"]?.on|0
                a.c+= @atoms["#{a.i+2}:#{a.j  }"]?.on|0
                a.c+= @atoms["#{a.i+1}:#{a.j+1}"]?.on|0
                
                a.c+= @atoms["#{a.i  }:#{a.j-1}"]?.on|0
                a.c+= @atoms["#{a.i-1}:#{a.j-1}"]?.on|0
                a.c+= @atoms["#{a.i+1}:#{a.j-1}"]?.on|0
                
            else
                a.c+= @atoms["#{a.i-1}:#{a.j  }"]?.on|0
                a.c+= @atoms["#{a.i+1}:#{a.j  }"]?.on|0
                a.c+= @atoms["#{a.i  }:#{a.j-1}"]?.on|0
                
                a.c+= @atoms["#{a.i-2}:#{a.j-1}"]?.on|0
                a.c+= @atoms["#{a.i-2}:#{a.j  }"]?.on|0
                a.c+= @atoms["#{a.i-1}:#{a.j-1}"]?.on|0
                
                a.c+= @atoms["#{a.i+2}:#{a.j-1}"]?.on|0
                a.c+= @atoms["#{a.i+2}:#{a.j  }"]?.on|0
                a.c+= @atoms["#{a.i+1}:#{a.j-1}"]?.on|0
                
                a.c+= @atoms["#{a.i  }:#{a.j+1}"]?.on|0
                a.c+= @atoms["#{a.i-1}:#{a.j+1}"]?.on|0
                a.c+= @atoms["#{a.i+1}:#{a.j+1}"]?.on|0
                
            
        # for i, a of @atoms
        #     a.toggle() if a.c>=3 
        
        for i, a of @atoms
            if     a.on and ~death.indexOf a.c then do a.setOff
            if not a.on and ~life.indexOf  a.c then do a.setOn
        
        if window.gif?
            window.gif.addFrame window.renderer.domElement.getContext('2d')
               
# ------------------------------------------------------------------------------

onDocumentMouseDown = (e) ->

    e.preventDefault();

    MOUSEDOWN = true
    
    mouse.x =  ( e.clientX / window.innerWidth  ) * 2 - 1
    mouse.y = -( e.clientY / window.innerHeight ) * 2 + 1
    mouse.z = 0.5
    
    projector.unprojectVector mouse, camera
    console.log mouse

    raycaster  = new THREE.Raycaster camera.position, mouse.sub( camera.position ).normalize()
    intersects = raycaster.intersectObjects Atom.meshes

    if intersects.length > 0
        if intersects[0].object.atom.on
            intersects[0].object.atom.setOff()
            MODE = "OFF"
        else
            intersects[0].object.atom.setOn()
            MODE = "ON"
    else
        MODE = "ON"
        console.log intersects[0].object.atom.c


onDocumentMouseUp = (e)->

    e.preventDefault();
    
    MOUSEDOWN = false

    # controls.enabled = true
    # if INTERSECTED
    #     plane.position.copy( INTERSECTED.position );
    #     SELECTED = null;

    # container.style.cursor = 'auto';


onDocumentMouseMove = (e)->

    e.preventDefault();

    if MOUSEDOWN

        mouse.x =  ( e.clientX / W ) * 2 - 1
        mouse.y = -( e.clientY / H ) * 2 + 1
        mouse.z =  0.5

        # atom.lookAt mouse.clone().multiplyScalar(-15).setZ(20) for atom in structure.children

        projector.unprojectVector mouse, camera
        # console.log mouse
        raycaster  = new THREE.Raycaster camera.position, mouse.sub( camera.position ).normalize()
        intersects = raycaster.intersectObjects Atom.meshes

        if intersects.length > 0
            renderer.domElement.style.cursor = 'pointer';
            if MODE=="ON"
                intersects[0].object.atom.setOn()
            else
                intersects[0].object.atom.setOff()
        else 
            renderer.domElement.style.cursor = 'auto';

window.readRules=()->
    
    d = document.getElementById("death").children
    i = 0 
    death = []
    (death.push i if c.checked; i++) for c in d
            
    l = document.getElementById("life").children
    i = 0
    life = []
    (life.push i if c.checked; i++) for c in l
    
    console.log life
    console.log death
    
window.clearCells=()->do a.setOff for i, a of structure.atoms
window.fillCells=()->do a.setOn for i, a of structure.atoms
window.randomFillCells=()->(if Math.random()>0.5 then do a.setOff else do a.setOn) for i, a of structure.atoms
window.pauseToggle=(e)->
    PAUSED = !PAUSED
    document.getElementById("pause").value = if PAUSED then "play" else "pause"
window.save=(e)->
    window.open renderer.domElement.toDataURL "image/png"

window.selectRule = (rule)->
    console.log rule, eval(rule)
    life  = rule[0]
    death = rule[1]
    writeRules()
    
window.writeRules=()->

    console.log life, death
    d = document.getElementById("death").children
    i=0
    c.checked = ~death.indexOf i++ for c in d
    
    l = document.getElementById("life").children
    i=0
    c.checked = ~life.indexOf i++ for c in l
    
render = ()->

    requestAnimationFrame render
    renderer.render scene, camera
    
window.record=()->
    btn = document.getElementById("recbtn")
    if btn.value is "recgif"
        btn.value = "stoprec"
        window.gif = new GIFEncoder()
        window.gif.setTransparent null
        window.gif.setRepeat 0
        window.gif.setDelay 100
        console.log window.gif.start()
    else
        btn.value = "recgif"
        if window.gif
            window.gif.finish()  
            window.open 'data:image/gif;base64,'+window.encode64(window.gif.stream().getData());
            window.gif = undefined
    
window.encode64 = (input) ->
      output = ""
      i = 0
      l = input.length
      key = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
      chr1 = undefined
      chr2 = undefined
      chr3 = undefined
      enc1 = undefined
      enc2 = undefined
      enc3 = undefined
      enc4 = undefined
      while i < l
        chr1 = input.charCodeAt(i++)
        chr2 = input.charCodeAt(i++)
        chr3 = input.charCodeAt(i++)
        enc1 = chr1 >> 2
        enc2 = ((chr1 & 3) << 4) | (chr2 >> 4)
        enc3 = ((chr2 & 15) << 2) | (chr3 >> 6)
        enc4 = chr3 & 63
        if isNaN(chr2)
          enc3 = enc4 = 64
        else enc4 = 64  if isNaN(chr3)
        output = output + key.charAt(enc1) + key.charAt(enc2) + key.charAt(enc3) + key.charAt(enc4)
      output
    

structure = new Structure 
scene.add structure

renderer.domElement.addEventListener 'mousemove', onDocumentMouseMove, false 
renderer.domElement.addEventListener 'mousedown', onDocumentMouseDown, false 
renderer.domElement.addEventListener 'mouseup'  , onDocumentMouseUp  , false

writeRules()

setInterval structure.cellularCalcs, 100

do render
