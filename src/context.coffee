{EventEmitter} = require 'events'

module.exports =
class Context extends EventEmitter
  _initTemplatePropsByController: (@props) -> new Promise (done) =>
    Promise.resolve(@initState(@props))
    .then (@state) =>
      Promise.resolve(@expandTemplate(@props, @state))
      .then (templateProps) =>
        done(templateProps)

  # Props -> Promise<State>
  initState: (props) -> props

  # Props, State -> Promise<TemplateProps>
  expandTemplate: (props, state) -> props
  
  subscribe: (subscribe) ->
