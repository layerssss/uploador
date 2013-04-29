processStart = (msg)->
  $('.processing').show().find('.message').text "正在#{msg}，请稍候……"
processStop = ->
  $('.processing').hide()
refreshStatus = ->
  title = window.uploadorTitle || '马上上传'
  title = title.replace /\s/g, ''
  url = window.uploadorUrl.replace /\s/g, ''
  status = "我在 #{title} "
  status += "( #{url} )" if url 
  status += '发布了贴图。 ' + (String Date.now()).slice -5
  $('#status').val status
reloadPics = (cb)->
  $('.pics').hide().children('.images').empty().load 'pics', ->
    processStop()
    $('.pics img:first-child').addClass('ui-selected')
    selectablestop = ->
      $('.btn-finish .num').text num = $('img.ui-selected').length
      if num
        try
          $('.btn-finish').removeAttr('title').removeClass('disabled').tooltip('destroy')
        catch e
      else
        $('.btn-finish').attr('title','请选择至少一个图片后继续').addClass('disabled').tooltip()

    $('.pics').show().children('.images').selectable
      filter: 'img.img-rounded.img-polaroid'
      stop: selectablestop
    selectablestop()
    cb()

  processStart '刷新列表'
$ ->
  refreshStatus()
  $('form[enctype="multipart/form-data"]').fileupload 
    dataType: 'json'
    singleFileUploads: true
    forceIframeTransport: true
    dropZone: $ '.uploader'
    start: ->
      $('.uploader').hide()
      processStart '上传..'
    done: refreshStatus
    stop: (e, data)->
      processStop()
      reloadPics ->
        $('.uploader').show()
        $('.uploader').children(':not(".label")').toggle()
  $('.btn-reupload').click ->
    $('.uploader').children(':not(".label")').toggle()
  $('.btn-finish').click ->
    return false unless $('.pics img.ui-selected').length
    pics = []
    for img in $('.pics img.ui-selected')
      pics.push img.dataset
    opener.postMessage (JSON.stringify pics), '*'
    window.close()
  reloadPics ->