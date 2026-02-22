pragma circom 2.2.3;
include "../node_modules/circomlib/circuits/comparators.circom";
// n is the number of conditions
template branchN(n){
    signal input x;
    signal switches[n];
    signal input conds[n];
    signal input branches[n+1];
    signal otherwise;
    signal output out;
    var sum = 0;
    component swit[n];
    for(var i=0;i<n;i++){
        swit[i] = IsEqual();
        swit[i].in[0] <== x;
        swit[i].in[1] <== conds[i];
        switches[i] <== swit[i].out;
        sum += switches[i];
    }
    otherwise <== IsZero()(sum);
    var sum2 = 0;
    signal branchsum[n];
    for(var i=0;i<n;i++){
        branchsum[i] <== switches[i] * branches[i];
        sum2 += branchsum[i];
    }
    sum2 += branches[n] * otherwise;
    out <== sum2;

}
component main = branchN(10);






// include "./node_modules/circomlib/circuits/comparators.circom";
// include "./node_modules/circomlib/circuits/multiplexer.circom";

// template BranchN(n) {
//   assert(n > 1); // too small

//   signal input x;

//   // conds n - 1 is otherwise
//   signal input conds[n - 1];
  
//   // branch n - 1 is the otherwise branch
//   signal input branches[n];
//   signal output out;
  
//   signal switches[n];
  
//   component EqualityChecks[n - 1];
  
//   // only compute IsEqual up to the second-to-last switch
//   for (var i = 0; i < n - 1; i++) {
//     EqualityChecks[i] = IsEqual();
    
//     EqualityChecks[i].in[0] <== x;
//     EqualityChecks[i].in[1] <== conds[i];
//     switches[i] <== EqualityChecks[i].out;
//   }
  
//   // check the last condition
//   var total = 0;
//   for (var i = 0; i < n - 1; i++) {
//     total += switches[i];
//   }
  
//   // if none of the first n - 1 switches
//   // are active, then `otherwise` must be 1
//   switches[n - 1] <== IsZero()(total);
  
//   component InnerProduct = EscalarProduct(n);
//   for (var i = 0; i < n; i++) {
//     InnerProduct.in1[i] <== switches[i];
//     InnerProduct.in2[i] <== branches[i];
//   }
  
//   out <== InnerProduct.out;
// }

// template MultiBranchConditional() {
// 	signal input x;
	
// 	signal output out;
	
// 	component branchn = BranchN(4);

//   var conds[3] = [5, 9, 10];
//   var branches[4] = [14, 22, 23, 45];
//   for (var i = 0; i < 4; i++) {
//     if (i < 3) {
//         branchn.conds[i] <== conds[i];
//     }
    
//     branchn.branches[i] <== branches[i];
//   }

//   branchn.x <== x;
//   branchn.out ==> out; // same as out <== branch4.out
// }

// component main = MultiBranchConditional();
