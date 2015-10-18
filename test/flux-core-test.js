import test from 'ava';
import React from 'react';
import {Component, createFlux, Provider} from '../src/flux-core';

// jsdom
import DomServer from 'react-dom/server';
import {EventEmitter} from 'events';

class Content extends Component {
  render() {
    return (
      <span
        onClick={() => this.dispatch('foo')}
      >
      {this.props.count}
      </span>
    );
  }
}
const MContent = React.createClass({
  render() {
    return (
      <span
        onClick={() => this.dispatch('foo')}
      >
      {this.props.count}
      </span>
    );
  }
});

test('flux', async (t) => {
  const emitter = new EventEmitter();
  const state = {count: 1};
  const flux = createFlux(() => {
    return DomServer.renderToStaticMarkup(
      <Provider emitter={emitter}>
        <Content {...state}/>
      </Provider>
    );
  });

  emitter.on('foo', () => {
    state.count += 1;
    flux.update(state);
  });

  const ret1 = flux.update(state);
  t.same(ret1, '<span>1</span>');

  emitter.emit('foo');
  const ret2 = flux.update(state);
  t.same(ret2, '<span>2</span>');
});
