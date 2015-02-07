module.exports =
class Component extends React.Component
  @contextTypes:
    shared: React.PropTypes.object
  dispatch: -> @context.shared.emit arguments...
