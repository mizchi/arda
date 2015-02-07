module.exports =
class Router
  constructor: (@layoutComponent, @el)->
    @_layout = React.createFactory(@layoutComponent)
    @history = []
    @_mounted = null

  # typeof Context => Thenable<Boolean>
  pushContext: (contextClass, initialProps = {}) -> new Promise (done) =>
    lastContext = @activeContext
    if lastContext
      lastContext.emit 'paused'

    @activeContext = context = new contextClass
    @history.push
      name: contextClass.name
      props: initialProps
      context: context

    @activeContext.subscribe (eventName, fn) =>
      @activeContext.on eventName, fn

    @activeContext.emit 'created'
    @activeContext.emit 'started'

    @_mount(context, initialProps).then => done()

  # () => Thenable<void>
  popContext: -> new Promise (done) =>
    if @history.length <= 0
      throw 'history stack is null'
    lastContext = @activeContext
    @history.pop()

    # emit disposed in context.dispose
    Promise.resolve(lastContext?.dispose()).then =>
      @activeContext = @history[@history.length-1]?.context
      if @activeContext
        @_mount(@activeContext, @activeContext.props).then =>
          @activeContext.emit 'started'
          @activeContext.emit 'resumed'
          done()
      else
        @_unmountAll().then =>
          done()

  replaceContext: ->
    # TODO

  #  Context * Object  => Thenable<void>
  _mount: (context, initialProps) -> new Promise (done) =>
    context._initTemplatePropsByController(initialProps).then (templateProps) =>
      activeComponent =
        React.withContext {shared: context}, ->
          React.createFactory(context.constructor.component)(templateProps)

      rendered = @_layout {activeComponent}
      @_renderOrUpdate(rendered).then => done()

  #  () => Thenable<void>
  _unmountAll: ->
    rendered = @_layout {activeComponent: null}
    @_renderOrUpdate(rendered)

  #  React.Element => Thenable<void>
  _renderOrUpdate: (rendered) -> new Promise (done) =>
    if @_mounted?
      @_mounted.setProps {activeComponent}
      done()
    else
      # initialize
      if @el
        @_mounted = React.render rendered, @el
      else
        # for test
        @renderedHtml = React.renderToString rendered
      done()
