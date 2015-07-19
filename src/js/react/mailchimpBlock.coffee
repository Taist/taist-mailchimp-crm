React = require 'react'

{ div, button } = React.DOM

MailchimpBlock = React.createFactory React.createClass
  onClick: ->
    console.log 'onClick'

  render: ->
    div {},
      button {
        onClick: @onClick
      }, 'Button'

module.exports = MailchimpBlock
