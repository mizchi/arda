window.React = require('react');
const Dom = require('react-dom');
require('babel/polyfill');
const {Stacker, Scene, mixin} = require('../../src/');

var Clicker = React.createClass({
  mixins: [mixin],
  render() {
    return <button onClick={this.onClick}>{this.props.cnt}</button>;
  },
  componentDidMount() {
    console.log('mounted');
  },

  onClick() {
    this.dispatch('++');
  }
});

class ClickerScene extends Scene {
  static get component() {return Clicker;}
  initQuery() {
    return {cnt: 0};
  }

  expandProps() {
    return {cnt: this.query.cnt};
  }

  constructor(...args) {
    super(...args);
    this.subscribe('++', () => this.updateQuery(s => ({cnt: s.cnt+1})));
  }
};

const target = document.querySelector('.content')
const router = new Stacker(el => {
  return Dom.render(el, target);
});

router.pushScene(new ClickerScene({}))
