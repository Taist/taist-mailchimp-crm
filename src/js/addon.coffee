app = require './app'

style = document.createElement 'style'
style.type = 'text/css'

innerHTML = ''

# zoho styles
innerHTML += '\n.zohoContainer { margin-left: 2.5%; padding-top: 8px; width: 95%; }'
innerHTML += '\n.zohoContainer * { font-size: 16px; font-family: "Roboto", sans-serif; }'

innerHTML += '\n.selectFieldWrapper div[tabindex="0"] div { text-overflow: ellipsis; overflow-x: hidden; }'

innerHTML += '\n.subscriptionsInfo { overflow: hidden; max-height: 0px; transition: max-height .5s ease-in-out; }'

innerHTML += '\n.subscriptionsInfo.isExpanded { max-height: 1000px; opacity: 1; transition: max-height .5s ease-in-out; }'

style.innerHTML = innerHTML
document.getElementsByTagName('head')[0].appendChild style

addonEntry =
  start: (_taistApi, entryPoint) ->
    window._app = app
    app.init _taistApi

    DOMObserver = require './helpers/domObserver'
    app.elementObserver = new DOMObserver()

    app.elementObserver.waitElement '[id^="emailspersonality_"]', (section) ->
      id = section.id.replace 'emailspersonality_', ''
      container = document.getElementById id
      container.appendChild app.container
    # container = document.querySelector '#notReact'

    app.mailchimpAPI.getLists()

    # app.render()


module.exports = addonEntry
