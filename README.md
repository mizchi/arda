# Arda

[![Build Status](https://drone.io/github.com/mizchi/arda/status.png)](https://drone.io/github.com/mizchi/arda/latest)

Meta-Flux framework for real world.

```
$ npm install arda --save
```

## Features

- History management by context(flux) stack
- Transition with Promise
- Loose coupling and testable
- TypeScript, CoffeeScript, and ES6 friendly
- Protect mutable state by types(typescript) and make it atomic.

## Dependencies

- React
- Promise (I reccomend `bluebird`)

## Intro

Store(`initState`, `expandComponentProps`) -> View(`render` -> UserInput) -> Dispatcher(`dispatch`) -> Store(`update` -> `expandTempalte`) -> `...`

```coffee
window.React   = require 'react'
window.Promise = require 'bluebird'
Arda = require 'arda'

# extends React.Component or mixin `Arda.mixin` in React.createClass
class Clicker extends Arda.Component
  render: -> React.createElement 'button', {onClick: @onClick.bind(@)}, @props.cnt
  onClick: -> @dispatch 'clicker:++'

class ClickerContext extends Arda.Context
  @component: Clicker
  initState: (props) -> cnt: 0
  expandComponentProps: (props, state) -> cnt: state.cnt
  delegate: (subscribe) ->
    super
    # subscribe lifecycle event
    subscribe 'context:created', -> console.log 'created'

    # subscribe ui event
    subscribe 'clicker:++', =>
      # state is changed by only context.update(...)
      @update((s) => cnt: s.cnt+1)
      .then -> console.log 'updated!'

window.addEventListener 'DOMContentLoaded', ->
  router = new Arda.Router(Arda.DefaultLayout, document.body)
  router.pushContext(ClickerContext, {})
```

Context instance is just EventEmitter.

![](http://i.gyazo.com/ff7ddb2643ea4d1587f1ce236da0f918.png)

## Transition

Arda.Router has `pushContext`, `popContext` and `replaceContext` and return promise object.

```coffee
router = new Arda.Router(Arda.DefaultLayout, document.body)
router.pushContext(MainContext, {})             # Main
.then => router.pushContext(SubContext, {})     # Main, Sub
.then => router.pushContext(MainContext, {})    # Main, Sub, Main
.then => router.popContext()                    # Main, Sub
.then => router.replaceContext(MainContext, {}) # Main, Main
.then => router.replaceContext(SubContext, {})  # Main, Sub
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
  @component: MyComponent
  subscribers: [subscriber]
```


![](http://i.gyazo.com/7b2dffed4f296beddc8a305270db884a.png)

## with TypeScript

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

See [typescript example](examples/typescript/index.ts)

## API

See [arda.d.ts](arda.d.ts)

## LICENSE

MIT
