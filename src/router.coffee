module.exports =
class Router
  # React.Class * ?HTMLElement => Router
  constructor: (layoutComponent, @el)->
    @_layout = React.createFactory(layoutComponent)()
    @_locked = false
    @history = []

  # () => boolean
  isLocked: -> @_locked

  # typeof Context => Thenable<Boolean>
  pushContext: (contextClass, initialProps = {}) -> new Promise (done) =>
    @_lock()
    lastContext = @activeContext
    if lastContext
      lastContext.emit 'paused'

    @activeContext = context = @_createContext contextClass
    @_mount(context, initialProps).then =>
      @history.push
        name: contextClass.name
        props: initialProps
        context: context
      @_unlock()
      @activeContext.emit 'created'
      @activeContext.emit 'started'
      done()

  _disposeContext: (context) ->
    delete context.props
    delete context.state
    context.emit 'disposed'
    context.removeAllListeners?()
    context.disposed = true
    Object.freeze(context)

  # () => Thenable<void>
  popContext: -> new Promise (done) =>
    if @history.length <= 0
      throw 'history stack is null'

    @_lock()
    lastContext = @activeContext
    @history.pop()

    # emit disposed in context.dispose
    Promise.resolve(
      if lastContext
        @_disposeContext(lastContext)
    ).then =>
      @activeContext = @history[@history.length-1]?.context
      if @activeContext
        @_mount(@activeContext, @activeContext.props).then =>
          @activeContext.emit 'started'
          @activeContext.emit 'resumed'
          @_unlock()
          done()
      else
        @_unmountAll().then =>
          @_unlock()
          done()

  # () => Thenable<void>
  replaceContext: (contextClass, initialProps = {}) -> new Promise (done) =>
    if @history.length <= 0
      throw 'history stack is null'
    @_lock()

    lastContext = @activeContext
    Promise.resolve(
      if lastContext
        @_disposeContext(lastContext)
    ).then =>
      @activeContext = @_createContext(contextClass)
      @activeContext.emit 'created'
      @activeContext.emit 'started'
      @_mount(@activeContext, initialProps).then =>
        @history.pop()
        @history.push
          name: contextClass.name
          props: initialProps
          context: @activeContext
        @_unlock()
        done()

  #  Context * Object  => Thenable<void>
  _mount: (context, initialProps) -> new Promise (done) =>
    context._initTemplatePropsByController(initialProps).then (templateProps) =>
      @_renderOrUpdate(context, templateProps).then => done()

  #  () => Thenable<void>
  _unmountAll: ->
    @_renderOrUpdate(null)

  #  React.Element => Thenable<void>
  _renderOrUpdate: (activeContext, props) -> new Promise (done) =>
    # render
    if !@_component? and @el?
      @_component = React.render @_layout, @el

    # setState
    if @el?
      @_component.setState {activeContext, activeProps: props}
    else
      # for test
      if activeContext
        rendered = React.createFactory(activeContext.constructor.component)(props)
        @innerHTML = React.renderToString rendered
      else
        @innerHTML = ''
    done()

  #  React.Element => Thenable<void>
  _createContext: (contextClass) ->
    context = new contextClass
    context.subscribe (eventName, fn) =>
      context.on eventName, fn

    context.on 'internal:state-updated', (context, props) =>
      if @activeContext isnt context
        console.info context.constructor.name + ' is not active'
        return

      @_lock()
      @_component?.setState
        activeContext: context
        activeProps: props
      @_unlock()
      context.emit 'internal:rendered'

    context

  _unlock: -> @_locked = false
  _lock: -> @_locked = true
