# ZK Circuits — Circom

A collection of zero-knowledge circuits implemented from scratch in [Circom](https://docs.circom.io), covering cryptographic primitives, arithmetic gadgets, data structures, and proof protocols.

---

## Circuits

### Cryptography# ZK Circuits — Circom

A collection of zero-knowledge circuits implemented from scratch in [Circom](https://docs.circom.io), covering cryptographic primitives, arithmetic gadgets, data structures, and proof protocols.

---

## Circuits

### Cryptography
| Circuit | Description |
|---|---|
| `MD5` | MD5 hash function implemented as a ZK circuit |
| `schnorr_protocol` | Schnorr signature scheme — prove knowledge of a private key |
| `malicous_attack` | Demonstrates malicious prover attack vectors |

### Arithmetic & Logic
| Circuit | Description |
|---|---|
| `multiplication` | Constrained multiplication gate |
| `comparison` | Compare two field elements |
| `iszero` | Prove a value is zero without revealing it |
| `max` | Prove knowledge of the maximum of a set |
| `sqrt` | Prove knowledge of a square root |
| `factorial` | Prove correct computation of a factorial |
| `fibonacci` | Prove knowledge of a Fibonacci sequence |
| `ops_on_32bits` | 32-bit arithmetic operations |

### Bit Operations
| Circuit | Description |
|---|---|
| `num2bits` | Decompose a field element into binary representation |
| `binaryN` | N-bit binary decomposition |
| `binaryNubmer` | Binary number constraints |

### Data Structures & Algorithms
| Circuit | Description |
|---|---|
| `stack` | Stack data structure as a circuit |
| `sorted_list` | Prove a list is sorted |
| `is_permutation` | Prove two arrays are permutations of each other |
| `swap` | Conditional swap gate |
| `increasingDistance` | Prove increasing distance constraints |

### Control Flow
| Circuit | Description |
|---|---|
| `if_branching` | Conditional branching via Quine selector |
| `signals_mul` | Signal multiplication gadget |

### Puzzles & Games
| Circuit | Description |
|---|---|
| `sudoku` | Prove a valid 4×4 Sudoku solution without revealing it |

### Advanced
| Circuit | Description |
|---|---|
| `plysol` | Polynomial solver circuit |
| `zkvm` | Zero-knowledge virtual machine |

---

## Stack

- **Language** — [Circom 2.x](https://docs.circom.io)
- **Libraries** — [circomlib](https://github.com/iden3/circomlib)
- **Proof system** — Groth16
- **Backend** — [snarkjs](https://github.com/iden3/snarkjs)

---

## Getting Started

### Prerequisites
```bash
npm install
circom --version   # 2.x required
snarkjs --version
```

### Compile a circuit
```bash
circom <circuit>/<circuit>.circom --r1cs --wasm --sym
```

### Generate a proof
```bash
# compute witness
node <circuit>/circuit_js/generate_witness.js \
     <circuit>/circuit_js/<circuit>.wasm \
     <circuit>/input.json \
     <circuit>/witness.wtns

# generate proof
snarkjs groth16 prove \
     <circuit>/<circuit>.zkey \
     <circuit>/witness.wtns \
     <circuit>/proof.json \
     <circuit>/public.json

# verify proof
snarkjs groth16 verify \
     <circuit>/verification_key.json \
     <circuit>/public.json \
     <circuit>/proof.json
```

---

## Notes

- All circuits are for **educational purposes only**
- Not audited — do not use in production
- Trusted setup uses a test ceremony — not suitable for production
| Circuit | Description |
|---|---|
| `MD5` | MD5 hash function implemented as a ZK circuit |
| `schnorr_protocol` | Schnorr signature scheme — prove knowledge of a private key |
| `malicous_attack` | Demonstrates malicious prover attack vectors |
