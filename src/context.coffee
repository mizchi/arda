{EventEmitter} = require 'events'

module.exports =
class Context extends EventEmitter
  constructor: ->
    super

  _initTemplatePropsByController: (@props) -> new Promise (done) =>
    Promise.resolve(@initState(@props))
    .then (@state) =>
      Promise.resolve(@expandTemplate(@props, @state))
      .then (templateProps) =>
        done(templateProps)

  # Override
  # Props -> Promise<State>
  initState: (props) -> props

  # Override
  # Props, State -> Promise<TemplateProps>
  expandTemplate: (props, state) -> props

  # Override
  subscribe: (subscribe) ->

  dispose: ->
    delete @props
    delete @state
    @emit 'disposed'
    @removeAllListeners?()
    Object.freeze(@)
