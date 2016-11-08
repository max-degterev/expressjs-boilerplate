import React from 'react';

const [a, ...b] = [1, 2, 3, 4, 5];
console.log({ a, b });

let sum = 0;
for (const number of b) {
  sum += number;
}

console.log(sum);


class Animal {
  move(name = 'Animal') {
    console.log(`${name} moves!`, this);
  }
}

class Dog extends Animal {
  constructor(name) {
    super();
    this.name = name;
  }

  run() {
    super.move(this.name);
  }
}

const rex = new Dog('Rex');
rex.run();

const Component = function () {
  return (<div className="amazing-component">Awesome Stuff!</div>);
};

export default () => console.log('Babel works!', Component);
