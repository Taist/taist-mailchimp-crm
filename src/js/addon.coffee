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

innerHTML += '\n.subscriptionsInfo td { box-sizing: border-box; }'

style.innerHTML = innerHTML
document.getElementsByTagName('head')[0].appendChild style

updateMailchimpKey = (action, key) ->
  creds = {}
  if action is 'enable'
    elem = document.querySelector '[aria-label="Account name"]'
    creds = APIKey: key, APIUser: elem.innerText

  app.mailchimpAPI.setCreds creds
  .then () ->
    app.mailchimpAPI.getCreds()
  .then (creds) ->
    updateMailchimpInterface()

updateMailchimpInterface = ->
  app.mailchimpAPI.getCreds()
  .then (creds) ->
    [].slice.call(document.querySelectorAll '.taistAPIKey').forEach (link) ->
      if creds?.APIKey is link.dataset.apikey
        link.innerText = 'Disable Taist integration'
        link.onclick = -> updateMailchimpKey 'disable', link.dataset.apikey
      else
        link.innerText = 'Use for Taist integration'
        link.onclick = -> updateMailchimpKey 'enable', link.dataset.apikey

addonEntry =
  start: (_taistApi, entryPoint) ->
    window._app = app
    app.init _taistApi

    DOMObserver = require './helpers/domObserver'
    app.elementObserver = new DOMObserver()

    if location.href.match /\.admin\.mailchimp\.com\/account\/api\//i
      app.elementObserver.waitElement '[id^="apikey-"]', (input) ->
        apikey = input.value
        a = document.createElement 'a'
        a.dataset.apikey = apikey
        a.className = 'taistAPIKey'
        a.style.cursor = 'pointer'

        div = document.createElement 'div'
        div.appendChild a

        input.parentNode.appendChild div

        updateMailchimpInterface()

    if location.href.match /crm\.zoho\.com\/crm\//i
      app.mailchimpAPI.getCreds()
      .then ->
        app.elementObserver.waitElement '[id^="emailspersonality_"]', (section) ->
          id = section.id.replace 'emailspersonality_', ''
          container = document.getElementById id
          container.appendChild app.container

          app.zohoAPI.setMember()
          app.mailchimpAPI.getLists()
      .catch (error) ->
        console.log error

module.exports = addonEntry
