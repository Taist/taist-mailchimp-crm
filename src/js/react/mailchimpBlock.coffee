React = require 'react'

{ div, button, path } = React.DOM

mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()
ThemeManager.setTheme ThemeManager.types.LIGHT

{ Paper, RaisedButton, SelectField, SvgIcon, List, ListItem, ListDivider } = mui

injectTapEventPlugin = require 'react-tap-event-plugin'
injectTapEventPlugin()

MailchimpBlock = React.createFactory React.createClass
  getInitialState: ->
    isExpanded: false
    selectValue: null

  #needed for mui ThemeManager
  childContextTypes:
    muiTheme: React.PropTypes.object

  #needed for mui ThemeManager
  getChildContext: ->
    muiTheme: ThemeManager.getCurrentTheme()

  onSubscribe: ->
    if @state.selectValue
      @props.actions.onSubscribe? @state.selectValue

  onUnsubscribe: ->
    if @state.selectValue
      @props.actions.onUnsubscribe? @state.selectValue

  onChangeMailchimpList: (event) ->
    this.setState { selectValue: event.target.value }

  onSelectSubscription: (listId) ->
    this.setState { selectValue: listId }

  onResetError: (event) ->
    @props.actions.onResetError?()

  toggleControl: ->
    @setState isExpanded: !@state.isExpanded

  faChevronUp: React.createElement SvgIcon, {
    viewBox: '0 0 1792 1792'
  }, path d: 'M1683 1331l-166 165q-19 19-45 19t-45-19l-531-531-531 531q-19 19-45 19t-45-19l-166-165q-19-19-19-45.5t19-45.5l742-741q19-19 45-19t45 19l742 741q19 19 19 45.5t-19 45.5z'

  faChevronDown: React.createElement SvgIcon, {
    viewBox: '0 0 1792 1792'
  }, path d: 'M1683 808l-742 741q-19 19-45 19t-45-19l-742-741q-19-19-19-45.5t19-45.5l166-165q19-19 45-19t45 19l531 531 531-531q19-19 45-19t45 19l166 165q19 19 19 45.5t-19 45.5z'

  render: ->
    React.createElement Paper, {
      zDepth: 1
      rounded: false
      style:
        margin: 8
        padding: 8
        width: @props.data.contentWidth
        boxSizing: 'content-box'
    },
      React.createElement List, {},
        React.createElement ListItem, {
          onClick: @toggleControl
          primaryText: 'Mailchimp subscriptions'
          leftIcon: React.createElement SvgIcon, {
            viewBox: '0 0 1792 1792'
          }, path d: 'M1664 1504v-768q-32 36-69 66-268 206-426 338-51 43-83 67t-86.5 48.5-102.5 24.5h-2q-48 0-102.5-24.5t-86.5-48.5-83-67q-158-132-426-338-37-30-69-66v768q0 13 9.5 22.5t22.5 9.5h1472q13 0 22.5-9.5t9.5-22.5zm0-1051v-24.5l-.5-13-3-12.5-5.5-9-9-7.5-14-2.5h-1472q-13 0-22.5 9.5t-9.5 22.5q0 168 147 284 193 152 401 317 6 5 35 29.5t46 37.5 44.5 31.5 50.5 27.5 43 9h2q20 0 43-9t50.5-27.5 44.5-31.5 46-37.5 35-29.5q208-165 401-317 54-43 100.5-115.5t46.5-131.5zm128-37v1088q0 66-47 113t-113 47h-1472q-66 0-113-47t-47-113v-1088q0-66 47-113t113-47h1472q66 0 113 47t47 113z'
          rightIcon: if @state.isExpanded then @faChevronUp else @faChevronDown
        }

      div { className: "subscriptionsInfo #{if @state.isExpanded then 'isExpanded' else ''}" },
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

        if @props.data.subscriptions.length > 0
          React.createElement List, {},
            @props.data.subscriptions.map (subscription) =>
              React.createElement ListItem, {
                key: subscription.list_id
                primaryText: subscription.name
                secondaryText: subscription.status
                onClick: => @onSelectSubscription subscription.list_id
              }
        else
          React.createElement List, {},
            React.createElement ListItem, { primaryText: 'Active subscriptions not found' }

        React.createElement ListDivider, {}

        div {},
          div { className: 'selectFieldWrapper', style: display: 'inline-block' },
            React.createElement SelectField, {
              value: @state.selectValue
              floatingLabelText: 'Select Mailchimp List'
              valueMember: 'id'
              displayMember: 'name'
              menuItems: @props.data.lists
              onChange: @onChangeMailchimpList
              style:
                width: @props.data.contentWidth
            }

        div {},
          if @props.data.subscriptions.filter((s) =>
              (s.status is 'subscribed') and (s.list_id is @state.selectValue)
            )[0]?
            React.createElement RaisedButton, {
              label: 'unsubscribe'
              disabled: !@state.selectValue?
              onClick: @onUnsubscribe
            }
          else
            React.createElement RaisedButton, {
              label: 'subscribe'
              disabled: !@state.selectValue?
              onClick: @onSubscribe
            }

module.exports = MailchimpBlock
