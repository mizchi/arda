{EventEmitter} = require 'events'

module.exports =
class Context extends EventEmitter
  # (State => State) => Promise<void>
  updateState: (stateFn) -> new Promise (done) =>
    Promise.resolve(
      if !@state? and @props
        new Promise (d) =>
          Promise.resolve(@initState(@props))
          .then (@state) =>
            @state = stateFn(@state) # TODO: merge other update
            d()
      else
        @state = stateFn(@state)
    ).then =>
      Promise.resolve(@expandTemplate(@props, @state))
      .then (template) =>
        @once 'internal:rendered', done
        @emit 'internal:state-updated', @, template

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
