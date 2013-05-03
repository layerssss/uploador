def = 
  title: ''
  url: ''
window.uploador = uploador = (options, cb)->
  opt = {}
  opt[k] = v for k, v of def
  opt[k] = v for k, v of options
  x = (window.screen.width - 800) / 2
  y = (window.screen.height - 600) / 2
  url = "http://uploador.micy.in/login?url=#{encodeURIComponent opt.url}&title=#{encodeURIComponent opt.title}"
  window.open url, 'uploador', "scrollbars=1,width=600,height=700,left=#{x},top=#{y}"
  $(window).one 'message', (e)->
    data = null
    try
      data = JSON.parse e.originalEvent.data
    catch e
    return cb new Error '' if data.constructor != Array
    console.log data
    cb null, data


