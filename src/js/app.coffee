Q = require 'q'

require('react/lib/DOMProperty').ID_ATTRIBUTE_NAME = 'data-vr-mc-crm-reactid'

extend = require 'react/lib/Object.assign'

appData = {}

app =
  api: null
  exapi: {}

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

  actions: {}

  mailchimpAPI:
    request: () ->
      url = 'https://us11.api.mailchimp.com/3.0/lists'

      options =
        type: 'json'
        method: 'get'
        contentType: 'application/json'
        headers:
          Authorization: 'Basic ' + btoa "#{app.mailchimpAPI.APIUser}:#{app.mailchimpAPI.APIKey}"

      deferred = Q.defer()

      app.api.proxy.jQueryAjax url, '', options, (error, response) ->
        if error
          deferred.reject error
        else
          deferred.resolve response.result
      deferred.promise

    APIUser: 'kiddylab'
    APIKey: 'df2d045d24b32563023c886c8d51774c-us11'

    getLists: ->
      app.mailchimpAPI.request()
      .then (result) ->
        console.log result
      .catch (error) ->
        #Use stub instead of real function
        console.log 'proxy error', error
      #   sendFBRequest = sendFBRequestStub
      #   'FB_PROXY_ERROR'

      # reqwest {
      #   url: 'https://us11.api.mailchimp.com/3.0/lists'
      #   type: 'json'
      #   method: 'get'
      #   contentType: 'application/json'
      #   headers:
      #     Authorization: 'Basic ' + btoa "#{app.mailchimpAPI.APIKey}:#{app.mailchimpAPI.APIUser}"
      # }
      # .then (resp) ->
      #   console.log resp.content
      # .fail (err, msg) ->
      #   console.log resp.content

  # us11.api.mailchimp.com/3.0/lists
  # freshBooksAPI.getCreds()
  # .then (creds) ->
  #   Q.when $.ajax
  #     url: creds.url
  #     headers:
  #       Authorization: 'Basic ' + btoa "#{creds.token}:"
  #     method: 'POST'
  #     data: XMLMapping.dump requestData, throwErrors: true, header: true
  #     dataType: 'text'


module.exports = app
