pragma circom 2.2.3;
include "../node_modules/circomlib/circuits/comparators.circom";
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
  signal input idx;
  signal output out;
  
  component lessThan = LessThan(4);
  lessThan.in[0] <== idx;
  lessThan.in[1] <== choices;
  lessThan.out === 1;

  component calcTotal = CalculateTotal(choices);
  component eqs[choices];

  for (var i = 0; i < choices; i ++) {
    eqs[i] = IsEqual();
    eqs[i].in[0] <== i;
    eqs[i].in[1] <== idx;

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

template GetMinAtIdxStartingAt(n, start) {
    signal input in[n];
    signal output min, idx;
    var minn=in[start],inx=start;
    for(var i=start+1;i<n;i++){
        if(minn>in[i])
        {
            minn = in[i];
            inx = i; 
        }
    }
    min <-- minn;
    idx <-- inx;


    component eq[n-start];
    for(var i=start+1;i<n;i++){
        eq[i-start-1]=LessThan(252);
        eq[i-start-1].in[0] <== min ;
        eq[i-start-1].in[1] <== in[i];
        eq[i-start-1].out === 1;
    }

    component qs=QuinSelector(n);
    qs.idx <== idx;
    for(var i=0;i<n;i++){
        qs.in[i] <== in[i];
    }
    qs.out === min;

}


template Select(n, start) {
    signal input in[n];
    signal output out[n];

    component getmin = GetMinAtIdxStartingAt(n,start);
    for(var i=0;i<n;i++){
        getmin.in[i] <== in[i];
    } 
    component swp=Swap(n);
    for(var i=0;i<n;i++){
        swp.in[i] <== in[i];
    } 
    swp.t <== start;
    swp.s <== getmin.idx;
    for(var i=0;i<n;i++){
        swp.out[i] ==> out[i];
    } 
    
}


template SelectionSort(n) {
    assert(n > 0);
    signal input in[n];
    signal output out[n];
    signal inter[n][n];
    component sort[n-1];
    for(var i=0;i<n;i++){
        if(i==0){
            for(var j=0;j<n;j++){
                inter[0][j] <== in[j];
            } 
        }
        else{
            sort[i-1]= Select(n,i);
            for(var j=0;j<n;j++){
                inter[i-1][j] ==> sort[i-1].in[j];
            }  
            for(var j=0;j<n;j++){
                inter[i][j] <== sort[i-1].out[j];
            }
        }
    } 
    for(var j=0;j<n;j++){
                inter[n-1][j] ==> out[j];
    }  
}




component main = SelectionSort(9);