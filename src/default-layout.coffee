Component = require './component'
module.exports =
class DefaultLayout extends Component
  constructor: ->
    super
    @state =
      activeContext: null
      activeProps: {}

  render: ->
    React.createElement 'div', {className: 'ow-container'}, [
      if @state.activeContext
        @createRootElementByContext(@state.activeContext, @state.activeProps)
      else
        null
    ]
