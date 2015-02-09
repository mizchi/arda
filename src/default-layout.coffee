Component = require './component'

module.exports =
class DefaultLayout extends Component
  constructor: ->
    super
    @state =
      activeContext: null

  render: ->
    @state.activeContext ? React.createElement 'div'
    # React.createElement 'div', {className: 'wrapper'}, [
    # ]
