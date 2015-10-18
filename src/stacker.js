import {Component, Provider} from './flux-core';
import React from 'react';
import {EventEmitter} from 'events';

export class Stacker extends EventEmitter {
  constructor(render, {debug} = {}) {
    super();
    this._render = render;
    this.debug = !!debug;
    this._updatingLock = false;

    this.activeScene = null;
    this.activeComponent = null;
    this.history = [];
  }

  log(...args) {
    if (this.debug) {
      console.log('[log]', ...args);
    }
  }

  async pushScene(nextScene) {
    if (this._updatingLock) {
      throw new Error('pushScene failde by other state lock');
    }
    this._updatingLock = true;

    const prevScene = this.activeScene;
    if (prevScene) {
      prevScene.emit('scene:paused');
    }

    this.history.push(nextScene);
    await this._updateActiveScene(nextScene);
    nextScene.emit('scene:created');
    nextScene.emit('scene:started');
    this.emit(':pushed');
    this._updatingLock = false;
    this.log('pushScene', nextScene.constructor.name, '[', this.history.map(a => a.constructor.name).join(', '), ']');
    return this.activeScene;
  }

  async pushSceneAndWait(nextScene) {
    await this.pushScene(nextScene);
    return new Promise(done => {
      nextScene.on('scene:disposed', done);
    });
  }

  async popScene() {
    if (this._updatingLock) {
      throw new Error('pushScene failde by other state lock');
    }
    this._updatingLock = true;

    const prevScene = this.activeScene;
    this.history.pop();
    const nextScene = this.history[this.history.length - 1];
    await this._updateActiveScene(nextScene);

    nextScene.emit('scene:resumed');
    this.emit(':popped');
    this._updatingLock = false;

    prevScene.emit('scene:disposed');
    await prevScene.dispose();

    this.log('popScene', nextScene.constructor.name, '[', this.history.map(a => a.constructor.name).join(', '), ']');
    return this.activeScene;
  }

  async replaceScene(nextScene) {
    if (this._updatingLock) {
      throw new Error('pushScene failde by other state lock');
    }
    this._updatingLock = true;

    const prevScene = this.activeScene;
    this.history.pop();
    this.history.push(nextScene);
    await this._updateActiveScene(nextScene);
    nextScene.emit('scene:created');
    nextScene.emit('scene:started');

    this.emit(':replaced');
    this._updatingLock = false;

    prevScene.emit('scene:disposed');
    await prevScene.dispose();

    this.log('replaceScene', nextScene.constructor.name, '[', this.history.map(a => a.constructor.name).join(', '), ']');
    return this.activeScene;
  }

  async _updateActiveScene(scene) {
    this.activeScene = scene;
    scene._router = this;
    await scene.initialize();
    const params = await scene.expandProps();
    const el = this._renderToElement(scene.constructor.component, params);
  }

  _renderToElement(Component, params) {
    return <Provider emitter={this.activeScene}>
      <Component {...params}/>
    </Provider>;
  }
}
