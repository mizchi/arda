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
      @_childContextElementCaches = {}
      @state = childContextPropsMap: {}
      for key, contextClass of @childContexts
        @_childContexts[key] =
          @_createChildContext(key, new contextClass)

  # string => Context
  getChildContextByKey: (key) ->
    throw 'This component doeen\'t have child contexts' unless @_childContexts?
    @_childContexts[key]

  # string * Object => React.Element
  createChildElement: (key) ->
    lastElement = @_childContextElementCaches[key]
    return lastElement if lastElement

    @_childContextCache ?= {}

    context = @getChildContextByKey(key)
    props = context.props ? {}

    component = React.createFactory(context.constructor.component)

    # return with cache
    @_childContextElementCaches[key] = React.withContext {shared: context}, => component(ref: key)

  # string * typeof Context => Context
  _createChildContext: (contextKey, context) ->
    parentComponent = @
    context.on 'internal:template-ready', (__, templateProps) =>
      component = @refs[contextKey]
      component.props = templateProps
      component.forceUpdate()
      context.emit 'internal:rendered'
    context

  # string * Object => React.Element
  createRootElementByContext: (context, props) ->
    # TODO: subscribe or not
    context = @_createRootContext(context)
    component = React.createFactory(context.constructor.component)
    React.withContext {shared: context}, =>
      component(props)

  # string * typeof Context => Context
  _createRootContext: (context) ->
    context.on 'internal:template-ready', (__, templateProps) =>
      @_component?.setState
        activeContext: context
        activeTemplateProps: templateProps
      context.emit 'internal:rendered'
    context
