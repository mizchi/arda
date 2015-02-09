# {EventEmitter} = require 'events'
EventEmitter = require './event-emitter'
inherits = require 'inherits'

# Context mixin React.Component
module.exports =
class Context extends React.Component
  ##### Properties #####
  # static contextType: Object
  # props: Props
  # state: State
  # wrapper: Context
  ######################

  inherits @, EventEmitter

  constructor: (@wrapper, @props) ->
    super
    subscribers = @constructor.subscribers ? []
    subscribers.forEach (subscriber) =>
      subscriber @, (eventName, callback) =>
        @on eventName, callback

  # (State => State) => Promise<void>
  updateState: (stateFn) ->
    Promise.resolve(
      if !@state? and @props
        Promise.resolve(@initState(@props))
        .then (@state) => Promise.resolve()
    )
    .then =>
      @state = stateFn(@state)
      Promise.resolve(@expandTemplate(@props, @state))
    .then (templateProps) =>
      @wrapper.setState
        activeContext: @render(templateProps)

  # Override
  # Props -> Promise<State>
  initState: (props) -> props

  # Override
  # Props, State -> Promise<TemplateProps>
  expandTemplate: (props, state) -> props

  # Override
  # Register
  render: (templateProps = {}) ->
    component = React.createFactory(@constructor.component)
    React.withContext {shared: @}, =>
      component(templateProps)

  # Props => ()
  # Update internal props and state
  _initByProps: (@props) -> new Promise (done) =>
    Promise.resolve(@initState(@props))
    .then (@state) => done()
