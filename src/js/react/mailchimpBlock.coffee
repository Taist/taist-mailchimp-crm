React = require 'react'

{ div, button, path } = React.DOM

mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()
ThemeManager.setTheme ThemeManager.types.LIGHT

{ Paper, RaisedButton, SelectField, SvgIcon } = mui

injectTapEventPlugin = require 'react-tap-event-plugin'
injectTapEventPlugin()

MailchimpBlock = React.createFactory React.createClass
  getInitialState: ->
    selectValue: null

  #needed for mui ThemeManager
  childContextTypes:
    muiTheme: React.PropTypes.object

  #needed for mui ThemeManager
  getChildContext: ->
    muiTheme: ThemeManager.getCurrentTheme()

  onClick: ->
    if @state.selectValue
      @props.actions.onSubscribe? @state.selectValue
    # console.log 'onClick', @state

  onSelectMailchimpList: (event) ->
    this.setState { selectValue: event.target.value }

  onResetError: (event) ->
    @props.actions.onResetError?()

  render: ->
    contentWidth = 480

    React.createElement Paper, {
      zDepth: 1
      rounded: false
      style:
        margin: 8
        padding: 8
        width: contentWidth
        boxSizing: 'content-box'
    },
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
              viewBox: '0 0 1792 1792',
              color: mui.Styles.Colors.red200
              hoverColor: mui.Styles.Colors.red900
              onClick: @onResetError
              style:
                height: 16
                width: 16
                cursor: 'pointer'
            },
              path d: "M1490 1322q0 40-28 68l-136 136q-28 28-68 28t-68-28l-294-294-294 294q-28 28-68 28t-68-28l-136-136q-28-28-28-68t28-68l294-294-294-294q-28-28-28-68t28-68l136-136q28-28 68-28t68 28l294 294 294-294q28-28 68-28t68 28l136 136q28 28 28 68t-28 68l-294 294 294 294q28 28 28 68z"
          @props.data.error

      div {},
        div { className: 'selectFieldWrapper', style: display: 'inline-block' },
          React.createElement SelectField, {
            value: @state.selectValue
            floatingLabelText: 'Select Mailchimp List'
            valueMember: 'id'
            displayMember: 'name'
            menuItems: @props.data.lists
            onChange: @onSelectMailchimpList
            style:
              width: contentWidth
          }

      div {},
        React.createElement RaisedButton, {
          label: 'Button'
          disabled: !@state.selectValue?
          onClick: @onClick
        }

module.exports = MailchimpBlock
