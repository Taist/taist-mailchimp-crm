Q = require 'q'

require('react/lib/DOMProperty').ID_ATTRIBUTE_NAME = 'data-vr-mc-crm-reactid'
React = require 'react'
extend = require 'react/lib/Object.assign'

md5 = require('blueimp-md5').md5

appData = {
  lists: []
  error: null
  subscriptions: []
  contentWidth: 700
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

  render: ->
    MailchimpBlock = require './react/mailchimpBlock'
    React.render ( MailchimpBlock data: appData, actions: app.actions, user: app.zohoAPI.setMember() ), app.container

  actions:
    onSubscribe: (subscriptionId) ->
      app.zohoAPI.setMember()
      app.mailchimpAPI.subscribe subscriptionId, app.appAPI.getMember()
      .then ->
        app.mailchimpAPI.getLists()

    onUnsubscribe: (subscriptionId) ->
      app.zohoAPI.setMember()
      app.mailchimpAPI.unsubscribe subscriptionId, app.appAPI.getMember()
      .then ->
        app.mailchimpAPI.getLists()

    onResetError: ->
      appData.error = null
      app.render()

  appAPI:
    member: {}

    getMember: ->
      @member

    setMember: (email, firstName, lastName) ->
      @member =
        email_address: email
        merge_fields:
          FNAME: firstName
          LNAME: lastName

    setError: (errorMessage) ->
      appData.error = errorMessage
      app.render()

  zohoAPI:
    setMember: ->
      pageData = JSON.parse document.querySelector('#mapValues').value
      fullName = pageData['Full Name'] or ""
      firstName = pageData['First Name'] or ""
      lastName = fullName.slice firstName.length + 1
      email = pageData.priEmail or ""
      app.appAPI.setMember email, firstName, lastName

  mailchimpAPI:
    creds: {}

    setCreds: (creds) ->
      app.exapi.setCompanyData 'mailchimpCreds', creds

    getCreds: () ->
      app.exapi.getCompanyData 'mailchimpCreds'
      .then (creds) =>
        @creds = creds or {}

    getAPIAddress: (path) ->
      unless @creds.APIKey
        return null

      dc = @creds.APIKey.split('-')?[1]

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
          Authorization: 'Basic ' + btoa "#{@creds.APIUser}:#{@creds.APIKey}"
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
      appData.subscriptions = []

      unless @creds?.APIKey?
        app.appAPI.setError 'Please setup Mailchimp API key to start'
        return Q.resolve()

      @getRequest 'lists'
      .then (result) =>
        appData.lists = result.lists or []

        result.lists.map (list) =>
          Q.all(
            @getMember list.id, app.appAPI.getMember()
            .then (listData) =>
              @insertSubscription extend { name: list.name }, listData
            .catch ->
              # just supress error
          )
          .then () ->
            # console.log 'before render', appData
            app.render()
          .catch (error) ->
            # console.log error
            app.render()

      .catch (error) ->
        console.log 'getLists error', error
        responseBody = JSON.parse error.response.body
        app.appAPI.setError responseBody.detail

    getUserId: (email) ->
      md5 email?.toLowerCase()

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
