Context = require './context'
module.exports =
class Component extends React.Component
  dispatch: -> @context.shared.emit arguments...
