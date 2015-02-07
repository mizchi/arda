{EventEmitter} = require 'events'

module.exports =
class Context extends EventEmitter
  root: (component, state, el = null) ->
    rendered =
      React.withContext {shared: @}, ->
        React.createFactory(Component)(state)
    if el?
      React.render rendered, el
    else
      React.renderToString rendered
