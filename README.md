# Arda

[![Build Status](https://drone.io/github.com/mizchi/arda/status.png)](https://drone.io/github.com/mizchi/arda/latest)

Meta-Flux framework for real world.

```
$ npm install arda --save
```

## Concept

Today's Flux is weak at scene transitions. Arda make it simple by `router` and `context`(chunk of flux).

Context has Flux features and its stack is very simple.

- Dispatcher is just EventEmitter
- View is just React.Component (with mixin)
- Store should be covered by typesafe steps with promise

I need to develop to make my company's react project simple. Arda is started from extraction of my works and well dogfooded. Thx [Increments Inc.](https://github.com/increments "Increments Inc.")


## Goals

- Transition with Promise
- Loose coupling and testable
- *TypeScript*, *CoffeeScript*, and *ES6* friendly
- Protect mutable state and make it atomic.

## Intro

Context, it extends way of react, is just one flux loop and has data flow, `Props => State => ComponentProps`

simple example by coffeescript is below.

```coffee
window.React   = require 'react'
window.Promise = require 'bluebird'
Arda = require 'arda'

Clicker = React.createClass
  mixins: [Arda.mixin]
  render: -> React.createElement 'button', {onClick: @onClick.bind(@)}, @props.cnt
  onClick: -> @dispatch 'clicker:++'

class ClickerContext extends Arda.Context
  component: Clicker
  initState: (props) -> cnt: 0
  expandComponentProps: (props, state) -> cnt: state.cnt
  delegate: (subscribe) ->
    super
    # subscribe lifecycle event. See detail later of this README
    subscribe 'context:created', -> console.log 'created'

    # subscribe ui events
    subscribe 'clicker:++', =>
      # state is changed by only context.update(...)
      @update((s) => cnt: s.cnt+1)
      .then -> console.log 'updated!'

window.addEventListener 'DOMContentLoaded', ->
  router = new Arda.Router(Arda.DefaultLayout, document.body)
  router.pushContext(ClickerContext, {})
```

![](http://i.gyazo.com/7b2dffed4f296beddc8a305270db884a.png)

## Transition

Arda.Router has `pushContext`, `popContext` and `replaceContext` and return promise object.

```coffee
router = new Arda.Router(Arda.DefaultLayout, document.body)
router.pushContext(MainContext, {})             # Main
.then => router.pushContext(SubContext, {})     # Main, Sub
.then => router.pushContext(MainContext, {})    # Main, Sub, Main
.then => router.popContext()                    # Main, Sub
.then => router.replaceContext(MainContext, {}) # Main, Main
.then => console.log router.history
```

`pushContext` and `replsceContext`'s second argument is to be context.props as immutable object.

## LifeCycle

```coffee
subscriber = (context, subscribe) ->
  subscribe 'context:created', -> console.log 'created'
  subscribe 'context:started', -> console.log 'started'
  subscribe 'context:paused', -> console.log 'paused'
  subscribe 'context:resumed', -> console.log 'resumed'
  subscribe 'context:disposed', -> console.log 'disposed'

class MyContext extends Arda.Context
  component: MyComponent
  subscribers: [subscriber]
```

![](http://i.gyazo.com/ff7ddb2643ea4d1587f1ce236da0f918.png)

static `subscribers` is automatic delegator on instantiate.

## with TypeScript

To achive purpose to make mutable state typesafe, Arda with TypeScript is better than other AltJS.

```javascript
interface Props {firstName: string; lastName: string;}
interface State {age: number;}
interface ComponentProps {greeting: string;}

class MyContext extends Arda.Context<Props, State, ComponentProps> {
  static component = React.createClass({
    mixins: [Arda.mixin],
    render: function(){return React.createElement('h1', {}, this.props.greeting);}
  });

  initState(props){
    // Can use promise  (State | Promise<State>)
    return new Promise<State>(done => {
      setTimeout(done({age:10}), 1000)
    })
  }
  expandComponentProps(props, state) {
    // Can use promise  (ComponentProps | Promise<ComponentProps>)
    return {greeting: 'Hello, '+props.firstName+', '+state.age+' years old'}
  }
}

var router = new Arda.Router(Arda.DefaultLayout, document.body);
// Unfortunately, initial props by router are not validated yet
// If you want, you can create your original router wrapper
router.pushContext(MyContext, {firstName: 'Jonh', lastName: 'Doe'})
.then(context => {
  setInterval(() => {
    context.state(state => {age: state.age+1}) // this is validated
  }, 1000 * 60 * 60 * 24 * 360) // fire once by each year haha:)
});
```

See [typescript working example](examples/typescript/index.ts)

Or see mizchi's starter project[mizchi-sandbox/arda-starter-project](https://github.com/mizchi-sandbox/arda-starter-project "mizchi-sandbox/arda-starter-project")

## Dependencies

- React v0.13.0 >=

## API

See detail at [arda.d.ts](arda.d.ts)

## LICENSE

MIT
