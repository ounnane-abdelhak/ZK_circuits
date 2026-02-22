pragma circom 2.2.3;

template CalculateTotal(n) {
  signal input in[n];
  signal output out;

  signal sums[n];

  sums[0] <== in[0];

  for (var i = 1; i < n; i++) {
    sums[i] <== sums[i-1] + in[i];
  }

  out <== sums[n-1];
}

template QuinSelector(choices) {
  signal input in[choices];
  signal input index;
  signal output out;
  
  component lessThan = LessThan(4);
  lessThan.in[0] <== index;
  lessThan.in[1] <== choices;
  lessThan.out === 1;

  component calcTotal = CalculateTotal(choices);
  component eqs[choices];

  for (var i = 0; i < choices; i ++) {
    eqs[i] = IsEqual();
    eqs[i].in[0] <== i;
    eqs[i].in[1] <== index;

    calcTotal.in[i] <== eqs[i].out * in[i];
  }

  out <== calcTotal.out;
}


template Swap(n) {
  signal input in[n];
  signal input s;
  signal input t;
  signal output out[n];

  signal sEqT;
  sEqT <== IsEqual()([s, t]);

  component qss = QuinSelector(n);
  qss.idx <== s;
  for (var i = 0; i < n; i++) {
    qss.in[i] <== in[i];
  }

  component qst = QuinSelector(n);
  qst.idx <== t;
  for (var i = 0; i < n; i++) {
    qst.in[i] <== in[i];
  }

  component IdxEqS[n];
  component IdxEqT[n];
  component IdxNorST[n];
  signal branchS[n];
  signal branchT[n];
  signal branchNorST[n];
  for (var i = 0; i < n; i++) {
    IdxEqS[i] = IsEqual();
    IdxEqS[i].in[0] <== i;
    IdxEqS[i].in[1] <== s;

    IdxEqT[i] = IsEqual();
    IdxEqT[i].in[0] <== i;
    IdxEqT[i].in[1] <== t;


    IdxNorST[i] = IsZero();
    IdxNorST[i].in <== IdxEqS[i].out + IdxEqT[i].out;


    branchS[i] <== IdxEqS[i].out * qst.out;
    branchT[i] <== IdxEqT[i].out * qss.out;
    branchNorST[i] <== IdxNorST[i].out * in[i];
    

    out[i] <==  (1-sEqT) * (branchS[i]) + branchT[i] + branchNorST[i];
  }
}



component main = Swap(5);