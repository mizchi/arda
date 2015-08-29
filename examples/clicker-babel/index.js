window.React = require('react');
var Arda = require('../../lib');

var Clicker = React.createClass({
  mixins: [Arda.mixin],
  render() {
    return React.createElement('button', {onClick: this.onClick.bind(this)}, this.props.cnt);
  },

  onClick() {
    this.dispatch('hello:++');
  }
});

class ClickerContext extends Arda.Context {
  get component() {
    return Clicker;
  }

  initState() {
    return {cnt: 0};
  }
  expandComponentProps(props, state) {
    return {cnt: state.cnt};
  }

  delegate(subscribe) {
    super.delegate();
    subscribe('context:created', () => console.log('created'));
    subscribe('hello:++', () =>
      this.update((s) => { return {cnt: s.cnt+1}; })
    );
  }
};

window.addEventListener('DOMContentLoaded', () => {
  var router = new Arda.Router(Arda.DefaultLayout, document.body);
  router.pushContext(ClickerContext, {});
});
