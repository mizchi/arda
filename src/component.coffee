module.exports =
class Component extends React.Component
  @contextTypes:
    shared: React.PropTypes.object
  dispatch: -> @context.shared.emit arguments...

  createChildContext: (key, contextClass) ->
    context = new contextClass
    context.subscribe (eventName, fn) =>
      context.on eventName, fn
    context.on 'internal:state-updated', (context, props) =>
      obj = {}
      obj[key] = context
      @setState obj
      context.emit 'internal:rendered'
    context

  createElementByContextKey: (key, props) ->
    context = @state[key]
    React.withContext {shared: context}, =>
      React.createFactory(context.constructor.component)(props)

  createRootElementByContext: (context, props) ->
    context.subscribe (eventName, fn) =>
      context.on eventName, fn
    context.on 'internal:state-updated', (context, props) =>
      if @activeContext isnt context
        console.info context.constructor.name + ' is not active'
        return
      @_component?.setState
        activeContext: context
        activeProps: props
      context.emit 'internal:rendered'

    React.withContext {shared: context}, =>
      React.createFactory(context.constructor.component)(props)

  #
  # #  React.Element => Thenable<void>
  # createChildContext: (contextClass) ->
  #   context = new contextClass
  #   context.subscribe (eventName, fn) =>
  #     context.on eventName, fn
  #
  #   context.on 'internal:state-updated', (context, props) =>
  #     if @activeContext isnt context
  #       console.info context.constructor.name + ' is not active'
  #       return
  #     @_component?.setState
  #       activeContext: context
  #       activeProps: props
  #
  #     context.emit 'internal:rendered'
