{EventEmitter} = require 'events'

module.exports =
class Context extends EventEmitter
  # (State => State) => Promise<void>
  updateState: (stateFn) -> new Promise (done) =>
    Promise.resolve(
      # Call initState if state is null/undefined
      if !@state? and @props
        Promise.resolve(@initState(@props))
        .then (@state) => Promise.resolve()
    ).then =>
      @state = stateFn(@state)
      @emit 'internal:state-updated', @state
      Promise.resolve(@expandTemplate(@props, @state))
      .then (template) =>
        @once 'internal:rendered', done
        @emit 'internal:template-ready', @, template

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
