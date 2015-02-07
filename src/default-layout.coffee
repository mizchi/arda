Component = require './component'
module.exports =
class DefaultLayout extends Component
  constructor: ->
    super
    @state = activeComponent: null
    # @setState activeComponent: null

  render: ->
    React.createElement 'div', {className: 'ow-container'}, [
      @state.activeComponent
    ]
