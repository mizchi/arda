Component = require './component'
module.exports =
class DefaultLayout extends Component
  constructor: ->
    super
    @state =
      activeContext: null
      activeProps: {}

  render: ->
    console.log 'emit render in layout', @state.activeProps, @state.activeContext?.constructor.name
    React.createElement 'div', {className: 'ow-container'}, [
      if context = @state.activeContext
        React.withContext {shared: context}, =>
          React.createFactory(context.constructor.component)(@state.activeProps)
      else
        null
    ]
