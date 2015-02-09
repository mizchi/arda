{EventEmitter} = require 'events'
module.exports =
class Router extends EventEmitter
  # React.Class * ?HTMLElement => Router
  constructor: (layoutComponent, @el)->
    @_locked = false
    @history = []

    if @el
      Layout = React.createFactory(layoutComponent)
      @_rootComponent = React.render Layout(), @el
      @_rootComponent.isRoot = true

  # () => boolean
  isLocked: -> @_locked

  # typeof Context => Thenable<Boolean>
  pushContext: (contextClass, initialProps = {}) ->
    @_lock()

    # check
    if lastContext = @activeContext
      lastContext.emit 'paused'

    @activeContext = new contextClass @_rootComponent, initialProps

    @_mountToParent(@activeContext, initialProps).then =>
      @history.push
        name: contextClass.name
        props: initialProps
        context: @activeContext

      @_unlock()

      @activeContext.emit 'created'
      @activeContext.emit 'started'
      Promise.resolve(@activeContext)

  # () => Thenable<void>
  popContext: ->
    if @history.length <= 0
      throw 'history stack is null'

    @_lock()
    @history.pop()

    # emit disposed in context.dispose
    Promise.resolve(
      if lastContext = @activeContext
        @_disposeContext(lastContext)
    )
    .then =>
      @activeContext = @history[@history.length-1]?.context
      if @activeContext
        @_mountToParent(@activeContext, @activeContext.props)
      else
        @_unmountAll()
    .then =>
      if @activeContext
        @activeContext.emit 'started'
        @activeContext.emit 'resumed'
      @_unlock()

  # () => Thenable<Context>
  replaceContext: (contextClass, initialProps = {}) ->
    if @history.length <= 0
      throw 'history stack is null'
    @_lock()

    lastContext = @activeContext
    Promise.resolve(
      if lastContext then @_disposeContext(lastContext) else null
    )
    .then =>
      @activeContext = new contextClass @_rootComponent, initialProps
      @activeContext.emit 'created'
      @activeContext.emit 'started'
      @_mountToParent(@activeContext, initialProps)
    .then =>
      @history.pop()
      @history.push
        name: contextClass.name
        props: initialProps
        context: @activeContext
      @_unlock()
      Promise.resolve(@activeContext)

  #  Context * Object  => Thenable<void>
  _mountToParent: (context, initialProps) ->
    @_initContextWithExpanding(context, initialProps)
    .then (templateProps) =>
      @_outputByEnv(context, templateProps)

  #  () => Thenable<void>
  _unmountAll: ->
    @_outputByEnv(null)

  #  React.Element => Thenable<void>
  _outputByEnv: (activeContext, props) ->
    if @el?
      @_outputToDOM(activeContext, props)
    else
      @_outputToRouterInnerHTML(activeContext, props)

  _outputToDOM: (activeContext, props) ->
    @_rootComponent.setState
      activeContext: activeContext.render(props)

  # For test dry run
  _outputToRouterInnerHTML: (activeContext, props) ->
    if activeContext
      rendered = activeContext.render(props)
      @innerHTML = React.renderToString rendered
    else
      @innerHTML = ''

  _unlock: -> @_locked = false

  _lock: -> @_locked = true

  _disposeContext: (context) ->
    delete context.props
    delete context.state
    context.emit 'disposed'
    context.removeAllListeners?()
    context.disposed = true
    Object.freeze(context)

  _initContextWithExpanding: (context, props) ->
    context._initByProps(props)
    .then => context.expandTemplate(context.props, context.state)
