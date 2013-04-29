$ ->
  $('.troll').click ->
    uploador title: '马上上传', url: 'http://uploador.micy.in/', (e, pics)->
      alert "你贴了#{pics.length}张，但是我只要一张，所以我用第一张了哦~" if pics.length > 1
      if pics.length
        $('.troll').prepend $('<i class="icon-spin icon-spinner icon-4x"></i>')

        $('.troll img').addClass('img-rounded img-polaroid').one 'load',->
          $('.troll img').show()
          $('.troll i.icon-spinner').remove()
        $('.troll img').attr('src', 'about:blank')
        $('.troll img').attr('src', pics[0].original)
        $('.troll img').hide()
