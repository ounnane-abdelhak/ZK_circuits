pragma circom 2.2.3;
include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/gates.circom";

template AND3(){
    signal input a,b,c;
    signal output out;
    signal v;
    v <== a*b;
    out <== v*c;
}


template ShouldCopy(i,bits){
      signal input sp;
  signal input is_push;
  signal input is_nop;
  signal input is_add;
  signal input is_mul;
  signal output out;

  is_mul * (is_mul-1) === 0;
  is_push * (is_push-1) === 0;
  is_nop * (is_nop-1) === 0;
  is_add * (is_add-1) === 0;

  is_add + is_mul + is_nop + is_push === 1;

  signal spEQ0,spEQ1,spGE1,spGE2,oneBelowSp,threeBelowSp;
  spEQ0 <== IsZero()(sp);
  spGE1 <== 1-spEQ0;
  spEQ1 <== IsEqual()([sp,1]);
  spGE2 <== spGE1*(1-spEQ1);
    component a3a=AND3(),a3b=AND3(),or=OR();
  oneBelowSp <== LessEqThan(bits)([i,sp-1]);

  threeBelowSp <== LessEqThan(bits)([i,sp-3]);
  a3a.a <== spGE1;
  a3a.b <== oneBelowSp;
  a3a.c <== is_nop+is_push;

  a3b.a <== spGE2;
  a3b.b <== threeBelowSp;
  a3b.c <== is_add+is_mul;
  or.a <== a3a.out;
  or.b <== a3b.out;
  out <== or.out;
}


template CopyStack(m){
      var nBits = 4;
    signal output out[m];
    signal input sp;
    signal input is_add;
    signal input is_mul;
    signal input is_push;
    signal input is_nop;

    component ShouldCopys[m];

    for(var i=0;i<m;i++)
    {   
        ShouldCopys[i]=ShouldCopy(i,nBits);
        ShouldCopys[i].sp <== sp;
        ShouldCopys[i].is_add <== is_add;
        ShouldCopys[i].is_mul <== is_mul;
        ShouldCopys[i].is_nop <== is_nop;
        ShouldCopys[i].is_push <== is_push;
        out[i] <== ShouldCopys[i].out;
    }
}

template ZKVM(n){
  var NOP = 0;
  var PUSH = 1;
  var ADD = 2;
  var MUL = 3;

  signal input instr[2 * n];
  signal output sp[n + 1];
  signal output stack[n][n];
  var IS_NOP = 0;
  var IS_PUSH = 1;
  var IS_ADD = 2;
  var IS_MUL = 3;
  var ARG = 4;
  signal metaTable[n][5];

  (instr[0] - PUSH) * (instr[0] - NOP) === 0;
  signal first_op_is_push;
  first_op_is_push <== IsEqual()([instr[0], PUSH]);
  stack[0][0] <== first_op_is_push*instr[1];
  for(var i=1;i<n;i++){
    stack[0][i] <== 0;
  }
  sp[0] <== 0;
  sp[1] <== first_op_is_push;
  metaTable[0][IS_NOP] <== 1 - first_op_is_push;
  metaTable[0][IS_PUSH] <== first_op_is_push;
  metaTable[0][IS_ADD] <== 0;
  metaTable[0][IS_MUL] <== 0;
  metaTable[0][ARG] <== instr[1];

  var SAME = 0;
  var INC = 1;
  var DEC = 2;
  signal spBranch[n][3];
  spBranch[0][INC] <== first_op_is_push * 1;
  spBranch[0][SAME] <== (1 - first_op_is_push) * 0;
  spBranch[0][DEC] <== 0;

  component EqPush[n];
  component EqNop[n];
  component EqAdd[n];
  component EqMul[n];
  component eqSP[n][n];
  signal eqSPAndIsPush[n][n];

  for (var i = 0; i < n; i++) {
    eqSPAndIsPush[0][i] <== 0;
  }

  component copystack[n];
  signal previousCellIfShouldCopy[n][n];
  for (var i = 0; i < n; i++) {
    previousCellIfShouldCopy[0][i] <== 0;
  }

  component eqSPMinus2[n][n];
  signal eqSPMinus2AndIsAdd[n][n];
  signal eqSPMinus2AndIsMul[n][n];
  for (var i = 0; i < n; i++) {
    eqSPMinus2AndIsAdd[0][i] <== 0;
    eqSPMinus2AndIsMul[0][i] <== 0;
  }


  signal eqSPMinus2AndIsAddWithValue[n][n];
  signal eqSPMinus2AndIsMulWithValue[n][n];

  signal sum_result[n][n];
  signal mul_result[n][n];
  for (var i = 0; i < n; i++) {
    eqSPMinus2AndIsAddWithValue[0][i] <== 0;
    eqSPMinus2AndIsMulWithValue[0][i] <== 0;
    sum_result[0][i] <== 0;
    mul_result[0][i] <== 0; 
  }

  for (var i = 1; i < n; i++) {
  EqPush[i] = IsEqual();
  EqPush[i].in[0] <== PUSH;
  EqPush[i].in[1] <== instr[2*i];
  metaTable[i][IS_PUSH] <== EqPush[i].out;

  EqAdd[i] = IsEqual();
  EqAdd[i].in[0] <== ADD;
  EqAdd[i].in[1] <== instr[2*i];
  metaTable[i][IS_ADD] <== EqAdd[i].out;

  EqMul[i] = IsEqual();
  EqMul[i].in[0] <== MUL;
  EqMul[i].in[1] <== instr[2*i];
  metaTable[i][IS_MUL] <== EqMul[i].out;


  EqNop[i] = IsEqual();
  EqNop[i].in[0] <== NOP;
  EqNop[i].in[1] <== instr[2*i];
  metaTable[i][IS_NOP] <== EqNop[i].out;

  metaTable[i][ARG] <== instr[2*i+1];

    for (var j = 0; j < n - 1; j++) {
      sum_result[i][j] <== stack[i - 1][j] + stack[i - 1][j + 1];
      mul_result[i][j] <== stack[i - 1][j] * stack[i - 1][j + 1];
    }

    sum_result[i][n - 1] <== 0;
    mul_result[i][n - 1] <== 0;

    copystack[i] = CopyStack(n);
    copystack[i].sp <== sp[i];
    copystack[i].is_push <== metaTable[i][IS_PUSH];
    copystack[i].is_nop <== metaTable[i][IS_NOP];
    copystack[i].is_mul <== metaTable[i][IS_MUL];
    copystack[i].is_add <== metaTable[i][IS_ADD];

    for (var j = 0; j < n ; j++) {
      previousCellIfShouldCopy[i][j] <== stack[i-1][j] * copystack[i].out[j];

      eqSP[i][j] = IsEqual();
      eqSP[i][j].in[0] <== j;
      eqSP[i][j].in[1] <== sp[i];
      eqSPAndIsPush[i][j] <== eqSP[i][j].out * metaTable[i][IS_PUSH];

      eqSPMinus2[i][j] = IsEqual();
      eqSPMinus2[i][j].in[0] <== j;
      eqSPMinus2[i][j].in[1] <== sp[i] - 2;

      eqSPMinus2AndIsAdd[i][j] <== eqSPMinus2[i][j].out * metaTable[i][IS_ADD];
      eqSPMinus2AndIsMul[i][j] <== eqSPMinus2[i][j].out * metaTable[i][IS_MUL];


      eqSPMinus2AndIsAddWithValue[i][j] <== eqSPMinus2AndIsAdd[i][j] * sum_result[i][j];
      eqSPMinus2AndIsMulWithValue[i][j] <== eqSPMinus2AndIsMul[i][j] * mul_result[i][j];

      stack[i][j] <== eqSPMinus2AndIsAddWithValue[i][j] + eqSPMinus2AndIsMulWithValue[i][j] + eqSPAndIsPush[i][j] * metaTable[i][ARG] + previousCellIfShouldCopy[i][j];
    }

    spBranch[i][INC] <== metaTable[i][IS_PUSH] * (sp[i]+1);
    spBranch[i][SAME] <== metaTable[i][IS_NOP] * sp[i];
    spBranch[i][DEC] <== (metaTable[i][IS_ADD] + metaTable[i][IS_MUL]) * (sp[i]-1);
    sp[i+1] <== spBranch[i][INC] + spBranch[i][SAME] + spBranch[i][DEC];

  }

}

component main=ZKVM(5);