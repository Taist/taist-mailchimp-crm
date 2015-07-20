Q = require 'q'

require('react/lib/DOMProperty').ID_ATTRIBUTE_NAME = 'data-vr-mc-crm-reactid'
React = require 'react'
extend = require 'react/lib/Object.assign'

md5 = require('blueimp-md5').md5

appData = {
  lists: []
  error: null
  subscriptions: []
  contentWidth: 480
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
    React.render ( MailchimpBlock data: appData, actions: app.actions ), app.container

  actions:
    onSubscribe: (subscriptionId) ->
      app.mailchimpAPI.subscribe subscriptionId, app.appAPI.getMember()
      .then ->
        app.mailchimpAPI.getLists()

    onUnsubscribe: (subscriptionId) ->
      app.mailchimpAPI.unsubscribe subscriptionId, app.appAPI.getMember()
      .then ->
        app.mailchimpAPI.getLists()

    onResetError: ->
      appData.error = null
      app.render()

  appAPI:
    getMember: ->
      email_address: 'john.doe@kiddylab.ru'
      marge_fields:
        FNAME: 'John'
        LNAME: 'Doe'

    setError: (errorMessage) ->
      appData.error = errorMessage
      app.render()

  mailchimpAPI:
    APIUser: 'kiddylab'
    APIKey: 'df2d045d24b32563023c886c8d51774c-us11'

    getAPIAddress: (path) ->
      unless @APIKey
        return null

      dc = @APIKey.split('-')?[1]

      "https://#{dc}.api.mailchimp.com/3.0/#{path}"

    getRequest: (path) ->
      @sendRequest path

    postRequest: (path, data) ->
      @sendRequest path, { data: JSON.stringify(data), method: 'post' }

    patchRequest: (path, data) ->
      @sendRequest path, { data: JSON.stringify(data), method: 'patch' }

    sendRequest: (path, options = {}) ->
      url = @getAPIAddress path

      requestOptions = extend {
        type: 'json'
        method: 'get'
        contentType: 'application/json'
        headers:
          Authorization: 'Basic ' + btoa "#{@APIUser}:#{@APIKey}"
      }, options

      deferred = Q.defer()

      app.api.proxy.jQueryAjax url, '', requestOptions, (error, response) ->
        if error
          deferred.reject error
        else
          deferred.resolve response.result

      deferred.promise

    indexOf: (listId) ->
      index = -1
      appData.subscriptions.forEach (s, i) -> if s.list_id is listId then index = i
      index

    insertSubscription: (subscription) ->
      idx = @indexOf(subscription.list_id)
      if idx > -1
        appData.subscriptions[idx] = subscription
      else
        appData.subscriptions.push subscription


    getLists: ->
      @getRequest 'lists'
      .then (result) =>
        appData.lists = result.lists or []
        app.render()
        result.lists.map (list) =>
          @getMember list.id, app.appAPI.getMember()
          .then (listData) =>
            @insertSubscription extend { name: list.name }, listData
            app.render()

      .catch (error) ->
        #Use stub instead of real function
        console.log 'proxy error', error

    getUserId: (email) ->
      md5 email.toLowerCase()

    getMember: (subscriptionId, user) ->
      path = "lists/#{subscriptionId}/members/#{@getUserId(user.email_address)}"
      @getRequest path

    subscribe: (subscriptionId, user) ->
      if @indexOf(subscriptionId) > -1
        path = "lists/#{subscriptionId}/members/#{@getUserId(user.email_address)}"
        method = 'patchRequest'
      else
        path = "lists/#{subscriptionId}/members"
        method = 'postRequest'
      @[method] path, extend user, { status: 'subscribed' }
      .catch (error) ->
        responseBody = JSON.parse error.response.body
        app.appAPI.setError responseBody.detail

    unsubscribe: (subscriptionId, user) ->
      path = "lists/#{subscriptionId}/members/#{@getUserId(user.email_address)}"
      @patchRequest path, extend user, { status: 'unsubscribed' }
      .catch (error) ->
        responseBody = JSON.parse error.response.body
        app.appAPI.setError responseBody.detail

module.exports = app
