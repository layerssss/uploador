express = require 'express'
request = require 'request'
url = require 'url'
path = require 'path'
stylus = require 'stylus'
nib = require 'nib'
debug = require 'debug'
fs = require 'fs'
os = require 'os'
moment = require 'moment'
moment.lang 'zh-cn'

connectCoffeeScript = require 'connect-coffee-script'
{
  exec
} = require 'child_process'

app = new express()
{
  WEIBO_KEY
  WEIBO_SECRET
  WEIBO_CALLBACK
  PORT
  NODE_ENV
} = process.env
NODE_ENV?= 'development'
throw new Error 'WEIBO_KEY not set!' unless WEIBO_KEY
throw new Error 'WEIBO_SECRET not set!' unless WEIBO_SECRET
throw new Error 'WEIBO_CALLBACK not set!' unless WEIBO_CALLBACK


api = (pathname, query, cb, host)->
  opt = 
    headers:
      'Accept': 'application/json'
      "User-Agent": (require './package.json').name
    method: 'GET'

  if query._method?.toUpperCase() in ['GET', 'PUT', 'DELETE', 'POST']
    opt.method = query._method?.toUpperCase()
    delete query._method

  if opt.method in ['PUT', 'POST']
    opt.form = query
    query = {}

  opt.url = url.format
    protocol: 'https'
    host: host||'api.weibo.com'
    pathname: pathname
    query: query

  (debug 'API') "#{opt.method} #{url.format opt.url}"
  await request opt, defer e, res, data
  return cb e if e
  (debug 'API') "#{res.statusCode} #{url.format opt.url}"
  try
    data = JSON.parse data
  catch e
    return cb new Error data
  return cb new Error data.error if data.error
  return cb new Error Stringify data if res.statusCode != 200
  cb null, data

if NODE_ENV == 'development'
  app.locals.pretty = true
app.locals.version = (require './package.json').version
app.locals.title = '马上上传'
app.set 'view engine', 'jade'
app.set 'views', path.join __dirname, 'views'


app.use stylus.middleware
  src: path.join __dirname, 'src'
  dest: path.join __dirname, 'public'
  compile: (str, path)-> stylus(str).set('filename', path).set('compress', false).use nib()
app.use connectCoffeeScript
  src: path.join __dirname, 'src'
  dest: path.join __dirname, 'public'
app.use express.static path.join __dirname, 'public'
app.use express.static path.join __dirname, 'src', 'raw'
app.use express.static path.join __dirname, 'components'


app.use express.bodyParser()
app.use (req, res, next)->
  req.body[k] = v for k, v of req.query
  next()
app.use express.methodOverride()
app.use express.cookieParser WEIBO_SECRET
app.use express.session
  secret: WEIBO_SECRET
  cookie:
    path: '/'
    httpOnly: true
    maxAge: 365 * 24 * 60 * 60 * 1000


app.use (req, res, cb)->
  res.locals.user = req.session.user
  cb null

app.get '/login', (req, res)-> 
  res.locals.url = req.session.url = req.query.url || ''
  res.locals.title = req.session.title = req.query.title || ''
  return res.redirect '/my/' if res.locals.user
  res.render 'login'

app.get '/oauth', (req, res)->
  res.redirect url.format
    protocol: 'https'
    host: 'open.weibo.cn'
    pathname: 'oauth2/authorize'
    query:
      'client_id': WEIBO_KEY
      'redirect_uri': WEIBO_CALLBACK
      'scope': 'statuses_to_me_read'
      'display': 'mobile'

app.get '/oauth_callback', (req, res, cb)->
  return res.redirect '/' if req.query.error == 'access_denied'

  await api "oauth2/access_token", _method: 'post', client_id: WEIBO_KEY, client_secret: WEIBO_SECRET, code: req.query.code, grant_type: 'authorization_code', redirect_uri: WEIBO_CALLBACK, defer(e, data), 'open.weibo.cn'
  return cb e if e

  await api "2/users/show.json", access_token: data.access_token, uid: data.uid, defer e, req.session.user
  return cb e if e

  req.session.user.access_token = data.access_token

  res.redirect '/my/'

app.all '/my/*', (req, res, cb)->
  return res.redirect '/login' unless res.locals.user
  req.access_token = res.locals.user.access_token
  cb null

app.get '/my/', (req, res, cb)->
  res.locals.access_token = req.access_token
  res.locals.url = req.session.url
  res.locals.title = req.session.title
  res.render 'my'

app.get '/my/pics', (req, res, cb)->
  await api '/2/statuses/user_timeline.json', access_token: req.access_token, uid: req.session.user.id, count: 50, defer e, data
  return cb e if e
  res.locals.statuses = data.statuses.filter (status)-> status.original_pic
  res.render 'my_pics'

app.delete '/my/:id', (req, res, cb)->
  pic = req.session.pics[Number req.params.id]
  return cb null unless pic

  req.session.pics.splice Number req.params.id, 1
  res.redirect 'back'

app.get '/my/signout', (req, res, cb)->
  req.session.user = undefined
  return res.redirect '/my/'

app.get '/', (req, res, cb)->
  res.render 'index'

app.use (err, req, res, cb)->
  return cb new Error "少年，你操作太频繁了，稍微歇一会儿再贴吧~" if err.message.match /out of rate limit/
  cb err

app.use (err, req, res, cb)->
  res.statusCode = 500
  res.render 'error',
    message: err.message


  




await server = app.listen (Number PORT||3000), defer e
throw e if e
console.log server.address()