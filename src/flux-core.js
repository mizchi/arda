// context
import React from 'react';
const SharedTypes = {emitter: React.PropTypes.any, rootProps: React.PropTypes.any};

export class Provider extends React.Component {
  static get childContextTypes() {return SharedTypes;}
  getChildContext() {
    return {emitter: this.props.emitter, rootProps: this.props};　
  }
  render() {
    return this.props.children;
  }
}

export class Component extends React.Component {
  static get contextTypes() {return SharedTypes;}
  dispatch(...args) {
    return this.context.emitter.emit(...args);
  }
}

export const mixin = {
  contextTypes: SharedTypes,
  dispatch(...args) {
    return this.context.emitter.emit(...args);
  }
};

export const createFlux = (render) => ({
  update(props) {
    return render(props);
  }
});
