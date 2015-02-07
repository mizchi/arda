{EventEmitter} = require 'events'

module.exports =
class Context extends EventEmitter
  _initTemplatePropsByController: (@props) ->
    @state = @initState(@props)
    return @expandTemplate(@props, @state)

  initState: (props) -> props
  expandTemplate: (props, state) -> props

  root: (component, state, el = null) ->
    rendered =
      React.withContext {shared: @}, ->
        React.createFactory(Component)(state)
    if el?
      React.render rendered, el
    else
      React.renderToString rendered
