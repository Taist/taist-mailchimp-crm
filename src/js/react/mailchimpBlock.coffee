React = require 'react'

{ div, button, path } = React.DOM

mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()
ThemeManager.setTheme ThemeManager.types.LIGHT

{ Paper, RaisedButton, SelectField, SvgIcon, List, ListItem, ListDivider, Table } = mui

injectTapEventPlugin = require 'react-tap-event-plugin'
injectTapEventPlugin()

MailchimpBlock = React.createFactory React.createClass
  #needed for mui ThemeManager
  childContextTypes:
    muiTheme: React.PropTypes.object

  #needed for mui ThemeManager
  getChildContext: ->
    muiTheme: ThemeManager.getCurrentTheme()

  onSubscribe: (listId) ->
    @props.actions.onSubscribe? listId

  onUnsubscribe: (listId) ->
    @props.actions.onUnsubscribe? listId

  onResetError: (event) ->
    @props.actions.onResetError?()

  selectedRows: []

  render: ->
    @selectedRows = []
    tableData = @props.data.lists?.map? (list, idx) =>
      subscriptions = @props.data.subscriptions?.filter? (s) ->
        s.list_id is list.id

      if subscriptions[0]?.status is 'subscribed'
        @selectedRows.push idx

      {
        selected: (subscriptions[0]?.status is 'subscribed')
        listId: list.id
        name:
          style:
            paddingLeft: 0
          content:
            div {},
              div {}, list.name
              if subscriptions[0]?.status?
                div {
                  style:
                    fontSize: 14
                    fontStyle: 'normal'
                    fontVariant: 'normal'
                    fontWeight: 400
                    lineHeight: '16px'
                    height: 16
                    marginTop: 4
                    color: mui.Styles.Colors.grey600
                }, subscriptions[0].status
      }

    React.createElement Paper, {
      zDepth: 1
      rounded: false
      style:
        marginTop: 24
        marginBottom: 48
        padding: 8
        boxSizing: 'content-box'
    },
      React.createElement List, {},
        React.createElement ListItem, {
          disabled: true
          primaryText: 'Mailchimp subscriptions'
          leftIcon: React.createElement SvgIcon, {
            viewBox: '0 0 1792 1792'
          }, path d: 'M1664 1504v-768q-32 36-69 66-268 206-426 338-51 43-83 67t-86.5 48.5-102.5 24.5h-2q-48 0-102.5-24.5t-86.5-48.5-83-67q-158-132-426-338-37-30-69-66v768q0 13 9.5 22.5t22.5 9.5h1472q13 0 22.5-9.5t9.5-22.5zm0-1051v-24.5l-.5-13-3-12.5-5.5-9-9-7.5-14-2.5h-1472q-13 0-22.5 9.5t-9.5 22.5q0 168 147 284 193 152 401 317 6 5 35 29.5t46 37.5 44.5 31.5 50.5 27.5 43 9h2q20 0 43-9t50.5-27.5 44.5-31.5 46-37.5 35-29.5q208-165 401-317 54-43 100.5-115.5t46.5-131.5zm128-37v1088q0 66-47 113t-113 47h-1472q-66 0-113-47t-47-113v-1088q0-66 47-113t113-47h1472q66 0 113 47t47 113z'
        }

      if @props.data.error?
        React.createElement Paper, {
          zDepth: 2
          rounded: false
          style:
            position: 'relative'
            padding: 8
        },
          div { style: position: 'absolute', right: 8 },
            React.createElement SvgIcon, {
              viewBox: '0 0 1792 1792'
              color: mui.Styles.Colors.red200
              hoverColor: mui.Styles.Colors.red900
              onClick: @onResetError
              style:
                height: 16
                width: 16
                cursor: 'pointer'
            }, path d: 'M1490 1322q0 40-28 68l-136 136q-28 28-68 28t-68-28l-294-294-294 294q-28 28-68 28t-68-28l-136-136q-28-28-28-68t28-68l294-294-294-294q-28-28-28-68t28-68l136-136q28-28 68-28t68 28l294 294 294-294q28-28 68-28t68 28l136 136q28 28 28 68t-28 68l-294 294 294 294q28 28 28 68z'
          @props.data.error

      div { className: 'subscriptionsInfo' },
        React.createElement Table, {
          columnOrder: ['name']
          rowData: tableData
          selectable: true
          multiSelectable: true
          preScanRowData: true
          deselectOnClickaway: false
          showRowHover: true
          onCellClick: (row, column) =>
            tableData[row].selected = !tableData[row].selected
            if tableData[row].selected
              @onSubscribe tableData[row].listId
            else
              @onUnsubscribe tableData[row].listId
        }

module.exports = MailchimpBlock
