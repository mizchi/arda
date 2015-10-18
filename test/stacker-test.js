import test from 'ava';
import {Scene, Stacker, Component} from '../src';
import React from 'react';
import Dom from 'react-dom';
import DomServer from 'react-dom/server';

const A = () => <span>A</span>;
const B = () => <span>B</span>;

class SceneA extends Scene {
  static get component() {return A;}
  constructor(props) {
    super();
  }
}

class SceneB extends Scene {
  static get component() {return B;}
}

test('stacker#pushScene/popScene/replaceScene', async (t) => {
  let buffer = '';
  const stack = new Stacker(el => {
    return new Promise(done => {
      buffer = DomServer.renderToStaticMarkup(el);
      done();
    });
  }, {debug: false});
  t.is(stack.history.length, 0);
  await stack.pushScene(new SceneA({}));

  t.is(buffer, '<span>A</span>');
  t.is(stack.history.length, 1);
  await stack.pushScene(new SceneB({}));
  t.is(buffer, '<span>B</span>');
  t.is(stack.history.length, 2);
  await stack.popScene();
  t.is(buffer, '<span>A</span>');
  t.is(stack.history.length, 1);
  await stack.replaceScene(new SceneB({}));
  t.is(buffer, '<span>B</span>');
  t.is(stack.history.length, 1);
  t.end();
});

test('stacker#pushScene', async (t) => {
  let buffer = '';
  const stack = new Stacker(el => {
    return new Promise(done => {
      buffer = DomServer.renderToStaticMarkup(el);
      done();
    });
  }, {debug: false});
  const scene = new SceneA({});

  t.plan(3);

  stack.on(':pushed', () => t.pass());
  scene.on('scene:created', () => t.pass());
  scene.on('scene:started', () => t.pass());
  await stack.pushScene(scene);
});

test('stacker#popScene', async (t) => {
  let buffer = '';
  const stack = new Stacker(el => {
    return new Promise(done => {
      buffer = DomServer.renderToStaticMarkup(el);
      done();
    });
  }, {debug: false});
  const scene1 = new SceneA({});
  const scene2 = new SceneA({});

  t.plan(4);
  scene1.on('scene:paused', () => t.pass());
  stack.on(':popped', () => t.pass());
  scene1.on('scene:resumed', () => t.pass());
  scene2.on('scene:disposed', () => t.pass());

  await stack.pushScene(scene1);
  await stack.pushScene(scene2);
  await stack.popScene();
});

test('stacker#replaceScene', async (t) => {
  let buffer = '';
  const stack = new Stacker(el => {
    return new Promise(done => {
      buffer = DomServer.renderToStaticMarkup(el);
      done();
    });
  }, {debug: false});
  const scene1 = new SceneA({});
  const scene2 = new SceneA({});
  const scene3 = new SceneA({});

  t.plan(4);
  stack.on(':replaced', () => t.pass());
  scene1.on('scene:paused', () => t.pass());
  scene2.on('scene:disposed', () => t.pass());
  scene3.on('scene:created', () => t.pass());

  await stack.pushScene(scene1);
  await stack.pushScene(scene2);
  await stack.replaceScene(scene3);
});
