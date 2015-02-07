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

  # Props -> Promise<State>
  updateState: (state) ->
    @state = state
    @emit 'state-updated', @state

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
