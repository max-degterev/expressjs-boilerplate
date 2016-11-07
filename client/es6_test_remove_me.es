let [a, ...b] = [1, 2, 3, 4, 5];
console.log({ a, b });

let sum = 0;
for (let number of b) {
  sum += number;
}

console.log(sum);


class Animal {
  move (name = 'Animal') {
    console.log(`${name} moves!`);
  }
}

class Dog extends Animal {
  constructor (name) {
    super();
    this.name = name;
  }

  run () {
    super.move(this.name);
  }
}

let rex = new Dog('Rex');
rex.run()

let Component = function (props) {
  return (<div className="amazing-component">Awesome Stuff!</div>);
};

export default () => console.log('Babel works!')
