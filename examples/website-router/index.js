window.React = require('react');
const Arda = require('../../lib');
const $ = React.createElement;
const App = React.createClass({
  mixins: [Arda.mixin],
  render() {
    return $('div', {}, [
      $('h1', {}, this.props.name),
      $('a', {href:'#foo'}, 'foo'),
      $('a', {href:'#bar'}, 'bar'),
      $('a', {href:'#baz'}, 'baz')
    ]);
  }
});

class AppContext extends Arda.Context {
  get component() {
    return App;
  }

  expandComponentProps(props, state) {
    return {name: props.name};
  }

  dispose() {
    super.dispose();
    console.log('disposed:', this);
  }

  delegate(subscribe) {
    super.delegate();
    subscribe('context:created', () => console.log('created', this.props.name));
  }
};

let Router = require('@mizchi/router');
var router;
window.addEventListener('hashchange', () => {
  router.emit(location.hash)
});

window.addEventListener('DOMContentLoaded', () => {
  // arda
  var ardaRouter = new Arda.Router(Arda.DefaultLayout, document.body);
  ardaRouter.setMaxHistory(3); // Cache only last 3 context

  // router
  router = new Router({hash: true});
  router.route(':context', params => {
    ardaRouter.pushContext(AppContext, {name: 'context:' + params.context});
  });
  router.route('', params => {
    ardaRouter.pushContext(AppContext, {name: 'root'});
  });

  // emit first manually
  if (location.hash === '') {
    ardaRouter.pushContext(AppContext, {name: 'root'});
  } else {
    router.emit(location.hash);
  }
});
