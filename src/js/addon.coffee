app = require './app'

style = document.createElement 'style'
style.type = 'text/css'

innerHTML = ''

innerHTML += '\n.selectFieldWrapper div[tabindex="0"] div { text-overflow: ellipsis; overflow-x: hidden; }';

innerHTML += '\n.subscriptionsInfo { display: none; opacity: 0.01; }'

innerHTML += '\n.subscriptionsInfo.isExpanded { display: block; opacity: 1; transition: display 0s, opacity 5s ease-in;}'

style.innerHTML = innerHTML
document.getElementsByTagName('head')[0].appendChild style

addonEntry =
  start: (_taistApi, entryPoint) ->
    window._app = app
    app.init _taistApi

    # DOMObserver = require './helpers/domObserver'
    # app.elementObserver = new DOMObserver()

    container = document.querySelector '#notReact'
    container.appendChild app.container

    app.mailchimpAPI.getLists()

    # app.render()


module.exports = addonEntry
