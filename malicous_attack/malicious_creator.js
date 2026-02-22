const fs = require('fs');

const filePath = 'witness.wtns';

const data = fs.readFileSync(filePath);
console.log("Before");
console.dir(data, {'maxArrayLength': null});

data[108] = 10; 
data[236] = 2;  

console.log("After");
console.dir(data, {'maxArrayLength': null});

fs.writeFileSync('exploit_witness.wtns', data);
