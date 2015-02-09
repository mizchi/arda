Context = require './context'
module.exports =
class Component extends React.Component
  @contextTypes:
    shared: React.PropTypes.any
  dispatch: -> @context.shared.emit arguments...

  # parentContext : Context
  # constructor: () ->
  #   super
