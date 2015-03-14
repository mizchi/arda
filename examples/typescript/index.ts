///<reference path='typings/bundle.d.ts' />
///<reference path='../../arda.d.ts' />

declare var React: any;
global.React = require('react');
//global.Promise = require('bluebird');*/
global.Arda = require('../../lib');

interface Props {firstName: string; lastName: string;}
interface State {age: number;}
interface ComponentProps {greeting: string;}

class MyContext extends Arda.Context<Props, State, ComponentProps> {
  get component() {
    return React.createClass({
      mixins: [Arda.mixin],
      render: function(){return React.createElement('h1', {}, this.props.greeting);}
    });
  }

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

window.addEventListener('DOMContentLoaded', () => {
  var router = new Arda.Router(Arda.DefaultLayout, document.body);
  // Unfortunately, initial props by router are not validated yet
  // If you want, you can create your original router wrapper
  router.pushContext(MyContext, {firstName: 'Jonh', lastName: 'Doe'})
  .then(context => {
    setInterval(() => {
      context.state(state => {age: state.age+1}) // this is validated
    }, 1000 * 60 * 60 * 24 * 360) // fire once by each year haha:)
  })
});
