module.exports =
class Router
  constructor: (@layoutComponent, @el)->
    @_layout = React.createFactory(@layoutComponent)
    @history = []
    @mounted = null

  # typeof Context => Thenable<Boolean>
  pushContext: (contextClass, initialProps = {}) ->
    @history.push {
      name: contextClass.name
      props: initialProps
    }

    context = new contextClass
    templateProps = context._initTemplatePropsByController(initialProps)

    activeComponent =
      React.withContext {shared: context}, ->
        React.createFactory(contextClass.component)(templateProps)
    rendered = @_layout {activeComponent}
    # initialize
    if @mounted?
      @mounted.setDefaultProps {activeComponent}
    else
      if @el
        @mounted = React.render rendered, @el
      else
        # for test
        @renderedHtml = React.renderToString rendered

  popContext: ->
  replaceContext: ->
