Component = require './component'

module.exports =
class DefaultLayout extends Component
  constructor: ->
    super
    @state =
      activeContext: null
      activeTemplateProps: {}

  render: ->
    @state.activeContext ? React.createElement 'div'
