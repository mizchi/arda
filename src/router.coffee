module.exports =
class Router
  constructor: (@layoutComponent, @el)->
    @_layout = React.createFactory(@layoutComponent)
    @history = []
    @mounted = null

  # typeof Context => Thenable<Boolean>
  pushContext: (contextClass, initialProps = {}) -> new Promise (done) =>
    @history.push {
      name: contextClass.name
      props: initialProps
    }

    context = new contextClass

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
