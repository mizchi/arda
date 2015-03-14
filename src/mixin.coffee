T = React.PropTypes

module.exports =
  contextTypes:
    ctx: T.object
    
  dispatch: ->
    @getCtx().emit arguments...

  getCtx: -> @props.ctx ? @context.ctx

  createChildRouter: (node) ->
    Router = require './router'
    DefaultLayout = require './default-layout'

    childRouter = new Router(DefaultLayout, node)
    childRouter

  createContextOnNode: (node, contextClass, props) ->
    childRouter = @createChildRouter(node)
    childRouter.pushContext(contextClass, props)
    .then (context) => Promise.resolve(context)

  getContext: ->
    @props.ctx or @context?.ctx
