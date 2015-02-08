Context = require './context'
module.exports =
class Component extends React.Component
  @contextTypes:
    shared: React.PropTypes.object
  dispatch: -> @context.shared.emit arguments...

  constructor: ->
    super
    if @childContexts
      @_childContexts = {}
      @state = childContextPropsMap: {}
      for key, contextClass of @childContexts
        @_childContexts[key] = Context.createChildContext(@, key, contextClass)
        @state.childContextPropsMap[key] = {}

  # string => Context
  getChildContextByKey: (key) ->
    @_childContexts[key]

  # string * Object => React.Element
  createElementByContextKey: (key, props) ->
    context = @_childContexts[key]
    context.props = props
    React.withContext {shared: context}, =>
      React.createFactory(context.constructor.component)(props)

  # string * Object => React.Element
  createRootElementByContext: (context, props) ->
    context.subscribe (eventName, fn) =>
      context.on eventName, fn

    context.on 'internal:template-ready', (__, templateProps) =>
      if @activeContext isnt context
        console.info context.constructor.name + ' is not active'
        return
      @_component?.setState
        activeContext: context
        activeTemplateProps: templateProps
      context.emit 'internal:rendered'

    React.withContext {shared: context}, =>
      React.createFactory(context.constructor.component)(props)
