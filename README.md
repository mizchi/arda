# Arda

[![Build Status](https://drone.io/github.com/mizchi/arda/status.png)](https://drone.io/github.com/mizchi/arda/latest)

Meta-Flux framework for real world.

```
$ npm install arda --save
```

## Features

- Context(one flux) can stack by router
- Transition with Promise
- Protect mutable state by types(typescript) and make it atomic.

- TypeScript, CoffeeScript, and ES6 friendly
- Headless(by node) testing friendly
- Loose coupling and testable by each module

## Dependencies

- React
- Promise (I reccomend `bluebird`)
- RxJS (Optional)

## Intro

- `initState` -> `expandTemplate` -> `render` -> UserInput -> `dispatch` -> `update` -> `expandTempalte` -> `...`

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
  expandTemplate: (props, state) -> cnt: state.cnt
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

If you want to use with rx, make event Rx.Observable

```coffee
window.Rx = require 'rx'
# ...
  delegate: (subscribe) ->
    super
    # Rx.Observable
    @clicks = subscribe 'clicker:++'
    @clicks.subscribe => @update(({cnt}) => cnt: cnt+1)
```

Context instance is just EventEmitter.

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

`pushContext` and `repalceContext`'s second argument is to be context.props as immutable object.

## with TypeScript

```javascript
interface Props {firstName: string; lastName: string;}
interface State {age: number;}
interface TemplateProps {greeting: string;}

class MyContext extends Arda.Context<Props, State, TemplateProps>
  static component: React.createClass({
    mixins: [Arda.mixin],
    render: function(){return React.createElement('h1', {}, this.props.greeting);}
  })

  initState(props){
    // Can use promise  (State | Promise<State>)
    return new Promise<State>(done => {
      setTimeout(done({age:10}), 1000)
    })
  }
  expandTemplate(props, state) {
    // Can use promise  (TemplateProps | Promise<TemplateProps>)
    return {greeting: 'Hello, '+props.firstName+', '+state.age+' years old'}
  }

var router = new Arda.Router(Arda.DefaultLayout, document.body);
// Unfortunately, initial props by router are not validated yet
// If you want, you can create your original router wrapper
router.pushContext(MyContext, {firstName: 'Jonh', lastName: 'Doe'})
.then(context => {
  setInterval(() => {
    context.state(state => {age: state.age+1}) // this is validated
  }, 1000 * 60 * 60 * 24 * 360) // fire once by each year haha:)
})
```

## API

See [arda.d.ts](arda.d.ts)

## LICENSE

MIT
