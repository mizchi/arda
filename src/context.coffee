{EventEmitter} = require 'events'

module.exports =
class Context extends EventEmitter
  constructor: ->
    super
    @_owner = null # injected at mounted
    React.createFactory(@constructor.component)

  _initTemplatePropsByController: (@props) -> new Promise (done) =>
    Promise.resolve(@initState(@props))
    .then (@state) =>
      Promise.resolve(@expandTemplate(@props, @state))
      .then (templateProps) =>
        done(templateProps)

  # State -> Promise<void>
  updateState: (state) -> new Promise (done) =>
    @state = state
    console.log 'updateState:', state, !!@_owner
    if @_owner?
      Promise.resolve(@expandTemplate(@props, @state))
      .then (template) =>
        console.log 'updateState:template', template
        @_owner.setState(activeContext: @, activeProps: template)
        # @_owner.forceUpdate()
        done()
    else
      done()

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
