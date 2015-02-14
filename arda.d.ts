declare module Arda {
  // Agnostic Promise
  export interface Thenable<R> {
    then<U>(onFulfilled?: (value: R) => Thenable<U>, onRejected?: (error: any) => Thenable<U>): Thenable<U>;
    then<U>(onFulfilled?: (value: R) => Thenable<U>, onRejected?: (error: any) => U): Thenable<U>;
    then<U>(onFulfilled?: (value: R) => Thenable<U>, onRejected?: (error: any) => void): Thenable<U>;
    then<U>(onFulfilled?: (value: R) => U, onRejected?: (error: any) => Thenable<U>): Thenable<U>;
    then<U>(onFulfilled?: (value: R) => U, onRejected?: (error: any) => U): Thenable<U>;
    then<U>(onFulfilled?: (value: R) => U, onRejected?: (error: any) => void): Thenable<U>;
    then<U>(onFulfilled?: (value: R) => U, onRejected?: (error: any) => void): Thenable<any>;
    then<U>(onFulfilled?: (value: any) => any, onRejected?: (error: any) => void): Thenable<any>;
    // TODO: fix this optional later
    catch?<U>(onRejected?: (error: any) => U): Thenable<U>;
    catch?<U>(onRejected?: (error: any) => void): Thenable<U>;
    catch?(onRejected?: (error: any) => void): Thenable<any>;
  }

  export class Router {
    constructor(layout: Component<any, any>, el: HTMLElement);
    pushState(context: typeof Context, args?: any): Thenable<Context<any, any, any>>;
    pushStateAndWaitForBack(context: typeof Context, args?: any): Thenable<Context<any, any, any>>;
    replaceState(context: typeof Context, args?: any): Thenable<Context<any, any, any>>;
    popState(): Thenable<Context<any, any, any>>;
  }

  export class Component<TemplateProps, InternalState> {
    props: TemplateProps;
    state: InternalState;
    dispatch: (...args: any[]) => boolean;
    render(): any; //React
  }

  export class Context<Props, State, TemplateProps> {
    static component: typeof Component;
    static subscribers: Function[];

    // Immutable object given by pushContext
    props: Props;

    // Mutable object update by initState and context.update
    state: State;

    _component: Component<TemplateProps, any>;
    getActiveComponent(): any;
    initState(p: Props): State | Thenable<State>;
    expandTemplate(p: Props, s: State): TemplateProps | Thenable<TemplateProps>;
    update(updater?: (s: State) => State | void): Thenable<any>;
    delegate(
      fn: (
        subscribe:
          ((eventName: string, fn?: (...args: any[]) => any) => any)
      ) => void
    )
  }

  export function subscriber<Props, State>
  (
    fn: (
      context: Context<Props, State, any>,
      subscribe:
        ((eventName: string, fn?: (...args: any[]) => any) => any)
    ) => void
  ):
  (
    fn: (
      context: Context<Props, State, any>,
      subscribe:
        ((eventName: string, fn?: (...args: any[]) => any) => any)
    ) => void
  ) => void
}
