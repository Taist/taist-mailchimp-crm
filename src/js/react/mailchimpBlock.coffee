React = require 'react'

{ div, button } = React.DOM

mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()
ThemeManager.setTheme ThemeManager.types.LIGHT

{ Paper, RaisedButton, SelectField } = mui

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
    console.log 'onClick', @state

  onSelectMailchimpList: (event) ->
    this.setState { selectValue: event.target.value }

  render: ->
    React.createElement Paper, { zDepth: 1, rounded: false, style: padding: 8 },
      div {},
        div { className: 'selectFieldWrapper', style: display: 'inline-block' },
          React.createElement SelectField, {
            value: @state.selectValue
            floatingLabelText: 'Select Mailchimp List'
            valueMember: 'id'
            displayMember: 'name'
            menuItems: @props.lists
            onChange: @onSelectMailchimpList
            style: width: 320
          }

        div { style: display: 'inline-block', width: 16 }

        React.createElement RaisedButton, {
          label: 'Button'
          disabled: !@state.selectValue?
          onClick: @onClick
        }

module.exports = MailchimpBlock
