const React = require('react');
const T = React.PropTypes;
const $ = React.createElement;

module.exports = React.createClass({
  childContextTypes: {
    shared: T.object
  },
  contextTypes: {
    ctx: T.object
  },

  getChildContext() {
    return {shared: this.getContext()};
  },

  getContext() {
    return this.state.activeContext || this.context.shared;
  },

  getInitialState() {
    return {
      activeContext: null,
      templateProps: {}
    };
  },

  render() {
    if (this.state.activeContext != null) {
      this.state.templateProps.ref = 'root';
      return $(
        this.state.activeContext.component,
        this.state.templateProps
      );
    } else {
      return <box top="center"
                  left="center"
                  width="100%"
                  height="100%"
                  border={{type: 'line'}}
                  style={{border: {fg: 'blue'}}}>
                  Loading
              </box>;
    }
  }
})
