mixin = require './mixin'
module.exports = React.createClass
  mixins: [mixin]
  propTypes:
    event: React.PropTypes.any.isRequired
    args: React.PropTypes.any
    className: React.PropTypes.string
  render: ->
    rootElement =
      if (typeof @props.children) is 'string'
        'button'
      else
        'span'
    args = @props.args ? []
    React.createElement rootElement, {
      className: @props.className ? 'arda-dispatcher-button'
      onClick: => @dispatch @props.event, args...
    }, @props.children
