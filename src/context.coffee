{EventEmitter} = require 'events'
inherits = require 'inherits'

# Context mixin React.Component
module.exports =
class Context extends React.Component
  inherits @, EventEmitter

  ##### Properties #####
  # props: Props
  # state: State
  # parent: Context
  ######################

  render: (templateProps = {}) ->
    component = React.createFactory(@constructor.component)
    React.withContext {shared: context}, =>
      component(templateProps)

  constructor: (parent, props) ->
    super
    @parent = parent
    @props = props if props

  # (State => State) => Promise<void>
  updateState: (stateFn) ->
    Promise.resolve(
      if !@state? and @props
        Promise.resolve(@initState(@props))
        .then (@state) => Promise.resolve()
    )
    .then =>
      @state = stateFn(@state)
      @emit 'internal:state-updated', @state
      Promise.resolve(@expandTemplate(@props, @state))
    .then (templateProps) =>
      @parent.setState
        activeContext: @render(templateProps)

  # Override
  # Props -> Promise<State>
  initState: (props) -> props

  # Override
  # Props, State -> Promise<TemplateProps>
  expandTemplate: (props, state) -> props

  # Override
  # Register
  subscribe: (subscribe) ->

  # Props => ()
  # Update internal props and state
  _initByProps: (@props) -> new Promise (done) =>
    Promise.resolve(@initState(@props))
    .then (@state) => done()
