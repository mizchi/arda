import React from 'react';
import {EventEmitter} from 'events';

export class Scene extends EventEmitter {
  constructor(initializers = {}, query = null) {
    super();
    this.initializers = initializers;
    this.query = query;
    this.disposed = false;
    this._router = null;
  }

  async initialize() {
    if (this.query == null) {
      this.query = await this.initQuery();
    }
  }

  initQuery() {return {}}
  expandProps() {return {}}

  subscribe(...args) {
    this.on(...args);
  }

  async updateQuery(fn) {
    if (this.disposed) {
      throw new Error('scene is disposed');
    }

    const nextState = await fn(this.query);
    this.query = nextState || this.query;

    if (this._router) {
      await this._router._updateActiveScene(this);
    }
    return this.query;
  }

  async dispose() {
    delete this._router;
    delete this.initializers;
    delete this.query;
    this.disposed = true;
    this.removeAllListeners();
  }

  initState() {return {};}
  expandViewProps() {return {};}
}
