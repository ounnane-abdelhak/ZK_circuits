# ZK Circuits

A collection of zero-knowledge circuits and cryptographic primitives implemented in Circom

---

## Circuits

| Circuit | Description |
|---|---|
| `num2bits` | Decompose a field element into its binary representation |
| `is_permutation` | Prove two arrays are permutations of each other |
| `iszero` | Prove a value is zero without revealing it |
| `multiplication` | Constrained multiplication gate |
| `max` | Prove knowledge of the maximum of a set |
| `sqrt` | Prove knowledge of a square root |
| `swap` | Conditional swap gate |
| `stack` | Stack data structure as a circuit |
| `sorted_list` | Prove a list is sorted |
| `ops_on_32bits` | 32-bit arithmetic operations |
| `signals_mul` | Signal multiplication gadget |
| `increasingDistance` | Prove increasing distance constraints |
| `if_branching` | Conditional branching via Quine selector |
| `malicous_attack` | Malicious prover attack demonstrations |
| `plysol` | Polynomial solver circuit |
| `schnorr_protocol` | Schnorr signature scheme |
| `zkvm` | Zero-knowledge virtual machine |



---

## Notes

- All circuits are for educational purposes
- Not audited — do not use in production
