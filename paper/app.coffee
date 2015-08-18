express = require "express"
socket  = require "socket.io"
stylus  = require "stylus"
nib     = require "nib"
http    = require "http" 
coffee  = require "coffee-middleware"

port = 3030

app = express()
srv = http.Server app
io  = socket srv

console.log "Listen #{port}"
srv.listen port

compile = (str, path)->
    stylus(str)
    .set("filename", path)
    .use(nib())

app.set "views"      , "#{__dirname}/views"
app.set "view engine", "jade"

app.use stylus.middleware
    src: "#{__dirname}/public"
    compile: compile

app.use coffee
    src     : __dirname + '/public'
    compress: true
    bare    : true

app.use express.static "#{__dirname}/public"

app.get "/:id", (req,res)->
    res.render "index",
        title: "index"
        id   : req.params.id

io.on "connection", (socket)->
    socket.emit "news", helllo: "world"
    socket.on "hello", (data)->
        console.log data

console.log __dirname

