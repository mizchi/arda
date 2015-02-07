Component = require './component'
module.exports =
class DefaultLayout extends Component
  render: ->
    React.createElement 'div', {className: 'ow-container'}, [
      @props.activeComponent
    ]
