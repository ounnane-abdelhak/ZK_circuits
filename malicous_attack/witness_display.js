const fs = require('fs');

const filePath = 'witness.wtns';

const data = fs.readFileSync(filePath);

let data_arr = new Uint8Array(data);
console.dir(data_arr, {'maxArrayLength': null});
