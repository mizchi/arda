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
, MyComponentProps> {
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
    s.updateQuery(q => ({age: q.age+1})) // this is validated
  }, 1000) // fire once by each year haha:)
})
