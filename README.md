# Arda

[![Build Status](https://drone.io/github.com/mizchi/arda/status.png)](https://drone.io/github.com/mizchi/arda/latest)

Meta-Flux framework for real world.

```
$ npm install arda --save
```

## Dependencies

- React v0.14.0 >=
- Promise or its poryfill
- `require('babel/polyfill')`

## Goals

- Transition Scenes with Promise
- *TypeScript* and *ES6* friendly
- Protect mutable state and make it atomic.

## Example

```js
window.React = require('react');
const Dom = require('react-dom');
require('babel/polyfill');
const {Stacker, Scene, mixin} = require('../../src/');

var Clicker = React.createClass({
  mixins: [mixin],
  render() {
    return <button onClick={this.onClick}>{this.props.cnt}</button>;
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
```

![](http://i.gyazo.com/7b2dffed4f296beddc8a305270db884a.png)

## Transition

Arda.Router has `pushContext`, `popContext` and `replaceContext` and return promise object.

(coffeescript)

```js
const router = new Stacker(el => {
  return Dom.render(el, document.body);
});
(async () => {
  router.pushScene(new Main)          # Main
  await router.pushScene(new Sub)     # Main, Sub
  await router.pushScene(new Main)    # Main, Sub, Main
  await router.popScene()             # Main, Sub
  await router.replaceScene(new Main) # Main, Main
  console.log(router.history);
})();
```

`pushScene` and `replsceScene`'s second argument is to be context.props as immutable object.

## LifeCycle

```js
class MyScene extends Arda.Scene {
  constructor() {
    super();
    this.subscribe('scene:created',  () => console.log('created'));
    this.subscribe('scene:started',  () => console.log('started'));
    this.subscribe('scene:paused',   () => console.log('paused'));
    this.subscribe('scene:resumed',  () => console.log('resumed'));
    this.subscribe('scene:disposed', () => console.log('disposed'));
  }
}
```

(old api)
![](http://i.gyazo.com/ff7ddb2643ea4d1587f1ce236da0f918.png)

## with TypeScript

To achive purpose to make mutable state typesafe, Arda with TypeScript is better than other AltJS.

```javascript
///<reference path='../../index.d.ts' />
declare var require: any;
declare var global: any;
declare var React: any;
require("babel/polyfill");
global.React = require("react");
global.Arda = require("../../src");
const {Scene, Stacker, Component} = Arda;
const Dom = require("react-dom");

interface MyComponentProps {greeting: string;}

class MyComponent extends Component<MyComponentProps, {}> {
  render(){
    return React.createElement("h1", {}, this.props.greeting);
  }
}

class MyScene extends Scene<{
  firstName: string; lastName: string;
}, {
  age: number;
}
, MyComponentProps
> {
  static get component() {
    return MyComponent;
  }

  initQuery(){
    return {age: 10};
  }

  expandProps() {
    return {greeting: `Hello, ${this.initializers.firstName}, ${this.query.age} years old`}
  }
}

const target = document.querySelector(".content");
const router = new Stacker( (el: any) => {
  return Dom.render(el, target);
});
router.pushScene(new MyScene({firstName: "Jonh", lastName: "Doe"}))
.then(s => {
  setInterval(() => {
    s.updateQuery(q => ({age: q.age+1}))
  }, 1000);
})
```

See [typescript working example](examples/typescript/index.ts)

## API

See detail at [index.d.ts](index.d.ts)

## LICENSE

MIT
