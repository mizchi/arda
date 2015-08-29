EventEmitter = require './event-emitter'
$ = React.createElement

module.exports =
class Router extends EventEmitter
  # React.Class * ?HTMLElement| (e: ReactComponentClass) => ReactComponent  => Router
  constructor: (layoutComponent, @_elOrMountFunc)->
    @history = []
    @_max_history = null
    @_locked = false
    @_disposers = []
    if @_elOrMountFunc
      if @_elOrMountFunc instanceof Function
        @_rootComponent = @_elOrMountFunc $(layoutComponent, {})
      else
        @_rootComponent = React.render $(layoutComponent, {}), @_elOrMountFunc
      @_rootComponent.isRoot = true

  setMaxHistory: (_max_history) =>
    if _max_history < 1
      throw new Error 'setMaxHistory need more than 1'
    @_max_history = _max_history

  # () => boolean
  isLocked: => @_locked

  dispose: =>
    Promise.all @_disposers.map (disposer) => do disposer
    .then => new Promsie (done) =>
      do popUntilBlank = =>
        if @history.length > 0
          @popContext().then => popUntilBlank()
        else
          done()
    .then =>
      @diposed = true
      @_lock = true
      delete @history
      delete @_disposers
      @removeAllListeners()
      Object.freeze(@)
      if @_elOrMountFunc? and not (@_elOrMountFunc instanceof Function)
        React.unmountComponentAtNode(@_elOrMountFunc)
      @emit 'router:disposed'

  pushContextAndWaitForBack: (contextClass, initialProps = {}) =>
    new Promise (done) =>
      @pushContext(contextClass, initialProps)
      .then (context) =>
        context.on 'context:disposed', done

  # typeof Context => Thenable<Boolean>
  pushContext: (contextClass, initialProps = {}) =>
    @_lock()

    # check
    if lastContext = @activeContext
      lastContext.emit 'context:paused'
      lastContext.lifecycle = 'paused'

    @activeContext = new contextClass @_rootComponent, initialProps
    @_mountToParent(@activeContext, initialProps)
    .then =>
      @history.push
        name: contextClass.name
        props: initialProps
        context: @activeContext

      # dispose context that is out of cache
      if @_max_history? and @history.length > @_max_history
        willDisposeHistory = @history.shift()
        if willDisposeHistory
          @_disposeContext(willDisposeHistory.context)

      @_unlock()
      @activeContext.emit 'context:created'
      @activeContext.emit 'context:started'
      @activeContext.lifecycle = 'active'
      @emit 'router:pushed', @activeContext
    .then =>
      @activeContext

  # () => Thenable<void>
  popContext: =>
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
      if @activeContext?
        @_mountToParent(@activeContext, @activeContext.props, true)
      else
        @_unmountAll()
    .then =>
      if @activeContext
        @activeContext.emit 'context:started'
        @activeContext.emit 'context:resumed'
        @activeContext.lifecycle = 'active'
        @emit 'router:popped', @activeContext
      else
        @emit 'router:blank'
      @_unlock()
    .then =>
      @activeContext

  # () => Thenable<Context>
  replaceContext: (contextClass, initialProps = {}) =>
    if @history.length <= 0
      throw 'history stack is null'
    @_lock()

    lastContext = @activeContext
    Promise.resolve(
      if lastContext then @_disposeContext(lastContext) else null
    )
    .then =>
      @activeContext = new contextClass @_rootComponent, initialProps
      @activeContext.emit 'context:created'
      @activeContext.emit 'context:started'
      @activeContext.lifecycle = 'active'
      @_mountToParent(@activeContext, initialProps)
    .then =>
      @history.pop()
      @history.push
        name: contextClass.name
        props: initialProps
        context: @activeContext
      @_unlock()
      @emit 'router:replaced', @activeContext

    .then =>
      @activeContext

  #  Context * Object  => Thenable<void>
  _mountToParent: (context, initialProps, reuseState = false) =>
    @_initContextWithExpanding(context, initialProps, reuseState)
    .then (templateProps) =>
      @_outputByEnv(context, templateProps)

  #  () => Thenable<void>
  _unmountAll: =>
    @_outputByEnv(null)

  #  React.Element => Thenable<void>
  _outputByEnv: (activeContext, props) =>
    if @_elOrMountFunc?
      @_distributeProps(activeContext, props)
    else
      @_outputToRouterInnerHTML(activeContext, props)

  _distributeProps: (activeContext, props) =>
    # TODO: now Arda grasp setState error.
    # In react-blessed example, first transition failed. I can't guess why yet.
    # ref. http://stackoverflow.com/questions/27153166/typeerror-when-using-react-cannot-read-property-firstchild-of-undefined
    try
      @_rootComponent.setState
        activeContext: activeContext
        templateProps: props

  # For test dry run
  _outputToRouterInnerHTML: (activeContext, templateProps) =>
    if activeContext
      rendered = React.createFactory(activeContext.component)(templateProps)
      @innerHTML = React.renderToString rendered
    else
      @innerHTML = ''

  _unlock: -> @_locked = false

  _lock: -> @_locked = true

  _disposeContext: (context) =>
    delete context.props
    delete context.state
    context.emit 'context:disposed'
    context.lifecycle = 'disposed'
    context.removeAllListeners?()
    context.dispose()
    context.disposed = true
    Object.freeze(context)

  _initContextWithExpanding: (context, props, reuseState = false) =>
    if context.state? and reuseState
      Promise.resolve(
        context.expandComponentProps(context.props, context.state)
      )
    else
      context._initByProps(props)
      .then => context.expandComponentProps(context.props, context.state)
