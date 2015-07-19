app = require './app'

style = document.createElement 'style'
style.type = 'text/css';
style.innerHTML = '.selectFieldWrapper div[tabindex="0"] div { text-overflow: ellipsis; overflow-x: hidden; }';
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
