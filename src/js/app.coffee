Q = require 'q'

require('react/lib/DOMProperty').ID_ATTRIBUTE_NAME = 'data-vr-mc-crm-reactid'
React = require 'react'
extend = require 'react/lib/Object.assign'

appData = {
  lists: []
}

app =
  api: null
  exapi: {}

  container: null

  init: (api) ->
    app.api = api

    app.exapi.setUserData = Q.nbind api.userData.set, api.userData
    app.exapi.getUserData = Q.nbind api.userData.get, api.userData

    app.exapi.setCompanyData = Q.nbind api.companyData.set, api.companyData
    app.exapi.getCompanyData = Q.nbind api.companyData.get, api.companyData

    app.exapi.setPartOfCompanyData = Q.nbind api.companyData.setPart, api.companyData
    app.exapi.getPartOfCompanyData = Q.nbind api.companyData.getPart, api.companyData

    app.exapi.updateCompanyData = (key, newData) ->
      app.exapi.getCompanyData key
      .then (storedData) ->
        updatedData = {}
        extend updatedData, storedData, newData
        app.exapi.setCompanyData key, updatedData
        .then ->
          updatedData

    app.container = document.createElement 'div'
    
  render: ->
    MailchimpBlock = require './react/mailchimpBlock'
    React.render ( MailchimpBlock appData ), app.container

  actions: {}

  mailchimpAPI:
    APIUser: 'kiddylab'
    APIKey: 'df2d045d24b32563023c886c8d51774c-us11'

    getAPIAddress: (path) ->
      unless @APIKey
        return null

      dc = @APIKey.split('-')?[1]

      "https://#{dc}.api.mailchimp.com/3.0/#{path}"

    sendRequest: (path) ->
      url = @getAPIAddress path

      options =
        type: 'json'
        method: 'get'
        contentType: 'application/json'
        headers:
          Authorization: 'Basic ' + btoa "#{@APIUser}:#{@APIKey}"

      deferred = Q.defer()

      app.api.proxy.jQueryAjax url, '', options, (error, response) ->
        if error
          deferred.reject error
        else
          deferred.resolve response.result

      deferred.promise

    getLists: ->
      @sendRequest('lists')
      .then (result) ->
        appData.lists = result.lists or []
        app.render()
      .catch (error) ->
        #Use stub instead of real function
        console.log 'proxy error', error
      #   sendFBRequest = sendFBRequestStub

module.exports = app
