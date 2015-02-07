module.exports =
class Router
  constructor: (@layoutComponent, @el)->
    @_layout = React.createFactory(@layoutComponent)
    @history = []
    @mounted = null

  # typeof Context => Thenable<Boolean>
  pushContext: (contextClass, initialProps = {}) -> new Promise (done) =>
    lastContext = @activeContext
    if lastContext
      lastContext.emit 'paused'

    @history.push
      name: contextClass.name
      props: initialProps

    @activeContext = context = new contextClass

    @activeContext.subscribe (eventName, fn) =>
      @activeContext.on eventName, fn

    @activeContext.emit 'created'
    @activeContext.emit 'started'

    context._initTemplatePropsByController(initialProps).then (templateProps) =>
      activeComponent =
        React.withContext {shared: context}, ->
          React.createFactory(contextClass.component)(templateProps)
      rendered = @_layout {activeComponent}
      # initialize
      if @mounted?
        @mounted.setDefaultProps {activeComponent}
        done()
      else
        if @el
          @mounted = React.render rendered, @el
        else
          # for test
          @renderedHtml = React.renderToString rendered
        done()

  popContext: ->
  replaceContext: ->
