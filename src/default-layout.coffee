T = React.PropTypes

module.exports = React.createClass
  childContextTypes:
    ctx: T.object

  contextTypes:
    ctx: T.object

  getChildContext: ->
    ctx: @getCtx()

  getCtx: -> @props.ctx ? @context.ctx

  dispatch: ->
    @getCtx().emit arguments...

  getInitialState: ->
    activeContext: null
    templateProps: {}

  render: ->
    if @state.activeContext?
      # dirty touch
      @state.templateProps.ref = 'root'
      @state.templateProps.ctx = @state.activeContext
      React.createElement @state.activeContext?.component, @state.templateProps
    else
      React.createElement 'div'
