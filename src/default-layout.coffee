Component = require './component'

T = React.PropTypes
module.exports = React.createClass
  childContextTypes:
    shared: T.any

  getChildContext: ->
    shared: @state.activeContext

  getInitialState: ->
    activeContext: null
    templateProps: {}

  render: ->
    if @state.activeContext?
      React.createFactory(@state.activeContext?.constructor.component)(@state.templateProps)
    else
      React.createElement 'div'
