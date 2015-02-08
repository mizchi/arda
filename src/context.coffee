{EventEmitter} = require 'events'

module.exports =
class Context extends EventEmitter
  # State -> Promise<void>
  updateState: (state) -> new Promise (done) =>
    @state = state
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
  subscribe: (subscribe) ->

  _initByProps: (@props) -> new Promise (done) =>
    Promise.resolve(@initState(@props))
    .then (@state) => done()
