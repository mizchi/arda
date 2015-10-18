window.React = require('react');
require('babel/polyfill');
const Dom = require('react-dom');
const {Stacker, Scene, mixin} = require('../../src/');

const HelloComponent = React.createClass({
  mixins: [mixin],
  render() {
    return <h1>Hello Arda</h1>;
  }
})

class HelloScene extends Scene {
  static get component() {return HelloComponent;}
}
const target = document.querySelector('.content')
const router = new Stacker(el => {
  return Dom.render(el, target);
});

router.pushScene(new HelloScene({}))
