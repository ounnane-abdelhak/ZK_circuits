import { buildPoseidon } from "circomlibjs";

async function main() {
    const poseidon = await buildPoseidon();
    const F = poseidon.F;

    const votersecret = BigInt("1234");

    // circuit hashes votersecret internally to get leaf
    const leaf = F.toObject(poseidon(poseidon([votersecret])));
    console.log("leaf:", leaf.toString());

    // sibling at level 0
    const sibling1 = BigInt("9876");

    // Hash(leaf, sibling1) since idx[0] = 0, leaf is on the left
    const node01 = F.toObject(poseidon([leaf, sibling1]));
    console.log("node01:", node01.toString());

    // sibling at level 1
    const sibling2 = BigInt("11111");

    // Hash(node01, sibling2) since idx[1] = 0, node01 is on the left
    const root = F.toObject(poseidon([node01, sibling2]));
    console.log("root:", root.toString());

    const input = {
        electionID: "42",
        root: root.toString(),
        salt: "9999",
        vote: "2",
        votersecret: "1234",
        siblings: [sibling1.toString(), sibling2.toString()],
        idx: ["0", "0"]
    };

    console.log(JSON.stringify(input, null, 2));
}

main();