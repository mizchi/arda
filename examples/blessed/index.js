import React, {Component} from 'react';
const Arda = require('../../node')(React);
global.Arda = Arda;

import {render, renderComponent} from '@mizchi/react-blessed';
import Layout from './layout';
import FooContext from './foo-context';

// Rendering a simple centered box
class App extends Component {
  constructor(){
    super();
    this.state = {cnt: 1};
  }

  componentDidMount() {
    this._id =setInterval(() => {
      this.incrementCounter();
    }, 1000)
  }

  componentWillUnmount() {
    clearInterval(this._id);
  }

  incrementCounter() {
    this.setState({cnt: this.state.cnt + 1});
  }

  render() {
    return <box top="center"
                left="center"
                width="50%"
                height="50%"
                border={{type: 'line'}}
                style={{border: {fg: 'blue'}}}>
                {this.state.cnt.toString()}
            </box>;
  }
}


class AppContext extends Arda.Context {
  get component() {
    return App;
  }

  expandComponentProps(props, state) {
    return {name: props.name};
  }

  delegate(subscribe) {
    super.delegate();
    subscribe('context:created', () => console.log('created', this.props.name));
  }
};

let screen;
let context;
const router = new Arda.Router(Layout, (el) => {
  screen = render(el, {
    autoPadding: true,
    smartCSR: true,
    title: 'react-blessed hello world'
  });
  screen.key(['escape', 'q', 'C-c'], function(ch, key) {
    return process.exit(0);
  });

  screen.key(['a'], function(ch, key) {
    // router.pushContext(AppContext, {});
    // console.log('a aaa')
    const c = context.getActiveComponent();
    c.incrementCounter();
  });

  screen.key(['b'], function(ch, key) {
    router.pushContext(FooContext, {});
  });

  return screen._component;
});

router.pushContext(AppContext, {})
.then(_context => {
  // cons
  context = _context;
})
.catch(e => {
  console.log('error', e.stack);
});
