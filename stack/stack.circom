include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/gates.circom";

template AND3() {
  signal input in[3];
  signal output out;
  
  signal temp;
  temp <== in[0] * in[1];
  out <== temp * in[2];
}

template ShouldCopy(j, bits) {
  signal input sp;
  signal input is_pop;
  signal input is_push;
  signal input is_nop;

  signal output out;
  
  
  is_pop + is_push + is_nop === 1;
  is_nop * (1 - is_nop) === 0;
  is_push * (1 - is_push) === 0;
  is_pop * (1 - is_pop) === 0;

  signal spEqZero;
  signal spGteOne;
  spEqZero <== IsZero()(sp);
  spGteOne <== 1 - spEqZero;

  signal spEqOne;
  signal spGteTwo;
  spEqOne <== IsEqual()([sp, 1]);
  spGteTwo <== (1 - spEqOne) * (1 - spEqZero);


 signal oneBelowSp <== LessEqThan(bits)([j, sp - 1]);
 signal twoBelowSP <== LessEqThan(bits)([j, sp - 2]);

  component a3A = AND3();
  a3A.in[0] <== spGteOne;
  a3A.in[1] <== oneBelowSp;
  a3A.in[2] <== is_push + is_nop;
  
  component a3B = AND3();
  a3B.in[0] <== spGteTwo;
  a3B.in[1] <== twoBelowSP;
  a3B.in[2] <== is_pop;

  component or = OR();
  or.a <== a3A.out;
  or.b <== a3B.out;  
  out <== or.out;

}

template CopyStack(m) {
    var nBits = 4;
    signal output out[m];
    signal input sp;
    signal input is_pop;
    signal input is_push;
    signal input is_nop;
    component ShouldCopys[m];

    for (var j = 0; j < m; j++) {
        ShouldCopys[j] = ShouldCopy(j, nBits);
        ShouldCopys[j].sp <== sp;
        ShouldCopys[j].is_pop <== is_pop;
        ShouldCopys[j].is_push <== is_push;
        ShouldCopys[j].is_nop <== is_nop;
        out[j] <== ShouldCopys[j].out;
    }
}

template StackBuilder(n) {
  var NOP = 0;
  var PUSH = 1;
  var POP = 2;

  signal input instr[2 * n];
  signal output sp[n + 1];

  signal output stack[n][n];

  var IS_NOP = 0;
  var IS_PUSH = 1;
  var IS_POP = 2;
  var ARG = 3;
  
  signal metaTable[n][4];
  (instr[0] - PUSH) * (instr[0] - NOP) === 0;

  signal first_op_is_push;
  first_op_is_push <== IsEqual()([instr[0], PUSH]);

  stack[0][0] <== first_op_is_push * instr[1];

  for (var i = 1; i < n; i++) {
      stack[0][i] <== 0;
  }
  sp[0] <== 0;
  sp[1] <== first_op_is_push;
  metaTable[0][IS_PUSH] <== first_op_is_push;
  metaTable[0][IS_POP] <== 0;
  metaTable[0][IS_NOP] <== 1 - first_op_is_push;
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
  component EqPop[n];

  component eqSP[n][n];
  signal eqSPAndIsPush[n][n];
  for (var i = 0; i < n; i++) {
      eqSPAndIsPush[0][i] <== 0;
  }

  component CopyStack[n];
  signal previousCellIfShouldCopy[n][n];
  for (var i = 0; i < n; i++) {
    previousCellIfShouldCopy[0][i] <== 0;
  }
  for (var i = 1; i < n; i++) {
    EqPush[i] = IsEqual();
    EqPush[i].in[0] <== instr[2 * i];
    EqPush[i].in[1] <== PUSH;
    metaTable[i][IS_PUSH] <== EqPush[i].out;

    EqNop[i] = IsEqual();
    EqNop[i].in[0] <== instr[2 * i];
    EqNop[i].in[1] <== NOP;
    metaTable[i][IS_NOP] <== EqNop[i].out;

    EqPop[i] = IsEqual();
    EqPop[i].in[0] <== instr[2 * i];
    EqPop[i].in[1] <== POP;
    metaTable[i][IS_POP] <== EqPop[i].out;

    metaTable[i][ARG] <== instr[2 * i + 1];

    CopyStack[i] = CopyStack(n);
    CopyStack[i].sp <== sp[i];
    CopyStack[i].is_push <== metaTable[i][IS_PUSH];
    CopyStack[i].is_nop <== metaTable[i][IS_NOP];
    CopyStack[i].is_pop <== metaTable[i][IS_POP];
    for (var j = 0; j < n; j++) {
      previousCellIfShouldCopy[i][j] <== CopyStack[i].out[j] * stack[i - 1][j];

      eqSP[i][j] = IsEqual();
      eqSP[i][j].in[0] <== j;
      eqSP[i][j].in[1] <== sp[i];
      eqSPAndIsPush[i][j] <== eqSP[i][j].out * metaTable[i][IS_PUSH];

      stack[i][j] <== eqSPAndIsPush[i][j] * metaTable[i][ARG] + previousCellIfShouldCopy[i][j];
    }

    spBranch[i][INC] <== metaTable[i][IS_PUSH] * (sp[i] + 1);
    spBranch[i][SAME] <== metaTable[i][IS_NOP] * (sp[i]);
    spBranch[i][DEC] <== metaTable[i][IS_POP] * (sp[i] - 1);
    sp[i + 1] <== spBranch[i][INC] + spBranch[i][SAME] + spBranch[i][DEC];
  }
}

component main = StackBuilder(3);