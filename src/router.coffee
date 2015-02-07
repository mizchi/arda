module.exports =
class Router
  constructor: (@layoutComponent, @el)->
    @_layout = React.createFactory(@layoutComponent)
    @history = []
    @mounted = null

  # typeof Context => Thenable<Boolean>
  pushContext: (contextClass, initialProps = {}) ->
    context = new contextClass
    activeComponent =
      React.withContext {shared: context}, ->
        React.createFactory(contextClass.component)(initialProps)

    rendered = @_layout {activeComponent}
    # initialize
    if @mounted?
      @mounted.setDefaultProps {activeComponent}
    else
      if @el
        @mounted = React.render rendered, @el
      else
        console.log 'rendered', React.renderToString rendered

  popContext: ->
  replaceContext: ->
