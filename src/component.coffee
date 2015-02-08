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

      for k, v of @childContexts
        @_childContexts[k] = @createChildContext(k, v)
        @state.childContextPropsMap[k] = {}

  # string => Context
  getChildContextByKey: (key) ->
    @_childContexts[key]

  # string * typeof Context => Context
  createChildContext: (contextKey, contextClass) ->
    context = new contextClass
    context.subscribe (eventName, fn) => context.on eventName, fn

    context.on 'internal:template-ready', (__, templateProps) =>
      map = @state.childContextPropsMap
      map[contextKey] = templateProps
      @setState childContextPropsMap: map
      context.emit 'internal:rendered'
    context

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
    context.on 'internal:template-ready', (context, props) =>
      if @activeContext isnt context
        console.info context.constructor.name + ' is not active'
        return
      @_component?.setState
        activeContext: context
        activeProps: props
      context.emit 'internal:rendered'

    React.withContext {shared: context}, =>
      React.createFactory(context.constructor.component)(props)
