import React, {Component} from 'react'
const Arda = require('../../node')(React);

export class Foo extends Component {
  constructor(){
    super();
    this.state = {cnt: 1};
  }

  render() {
    return <box top="center"
                left="center"
                width="50%"
                height="50%"
                border={{type: 'line'}}
                style={{border: {fg: 'red'}}}>
                Fooooooooooooooooooooo
            </box>;
  }
}

export default class FooContext extends Arda.Context {
  get component() {
    return Foo;
  }
  expandComponentProps(props, state) {
    return {};
  }
};
