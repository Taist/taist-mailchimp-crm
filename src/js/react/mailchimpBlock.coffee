React = require 'react'

{ div, button } = React.DOM

mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()
ThemeManager.setTheme ThemeManager.types.LIGHT

{ Paper, RaisedButton } = mui

MailchimpBlock = React.createFactory React.createClass
  #needed for mui ThemeManager
  childContextTypes:
    muiTheme: React.PropTypes.object

  #needed for mui ThemeManager
  getChildContext: () ->
    muiTheme: ThemeManager.getCurrentTheme()

  onClick: ->
    console.log 'onClick'

  render: ->
    console.log Paper
    React.createElement Paper, { zDepth: 1, rounded: false, style: padding: 8 },
      div {},
        React.createElement RaisedButton, {
          label: 'Button'
          onClick: @onClick
        }

module.exports = MailchimpBlock
