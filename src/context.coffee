{EventEmitter} = require 'events'

module.exports =
class Context extends EventEmitter
  _initTemplatePropsByController: (@props) -> new Promise (done) =>
    Promise.resolve(@initState(@props))
    .then (@state) =>
      Promise.resolve(@expandTemplate(@props, @state))
      .then (templateProps) => done(templateProps)

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
