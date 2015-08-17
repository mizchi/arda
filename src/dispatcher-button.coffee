mixin = require './mixin'
module.exports = React.createClass
  mixins: [mixin]
  propTypes:
    event: React.PropTypes.any.isRequired
    args: React.PropTypes.any.isRequired
  render: ->
    rootElement =
      if (typeof @props.children) is 'string'
        'button'
      else
        'span'
    React.createElement rootElement, {
      className: @props.className ? 'arda-dispatcher-button'
      onClick: => @dispatch @props.event, @props.args...
    }, @props.children
