app = require './app'

React = require 'react'

addonEntry =
  start: (_taistApi, entryPoint) ->
    window._app = app
    app.init _taistApi

    DOMObserver = require './helpers/domObserver'
    app.elementObserver = new DOMObserver()

    container = document.querySelector '#notReact'

    MailchimpBlock = require './react/mailchimpBlock'
    React.render ( MailchimpBlock {} ), container

module.exports = addonEntry
