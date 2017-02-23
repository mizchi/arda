React = require 'react'
T = React.PropTypes
module.exports = React.createClass
  childContextTypes:
    shared: T.object

  contextTypes:
    ctx: T.object

  getChildContext: ->
    # shared: @state.activeContext
    shared: @getContext()

  getContext: -> this.state.activeContext or @context.shared
    # return this.props.shared or (@context and @context.shared)

  getInitialState: ->
    activeContext: null
    templateProps: {}

  render: ->
    if @state.activeContext?
      @state.templateProps.ref = 'root'
      React.createFactory(@state.activeContext?.component)(@state.templateProps)
    else
      React.createElement 'div'
