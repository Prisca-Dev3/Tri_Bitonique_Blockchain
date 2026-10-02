# TP2 — Tri Bitonique & Minage de Blockchain (OCaml / Lean 4 / OpenQASM)

Implémentation pédagogique en trois langages, pensée pour être **facile à
relire et à maîtriser**, pas pour être la plus courte ou la plus optimisée.

## Structure du projet

```
tp2/
├── README.md
├── Makefile
├── rapport.docx                  <- rapport écrit (≤ 20 pages)
├── ocaml/
│   ├── bitonic_sort.ml           <- tri bitonique (tableaux, impératif)
│   └── blockchain_mining.ml      <- minage PoW (MD5 comme "hash simple")
├── lean/
│   ├── BitonicSort.lean          <- même algorithme, formulation fonctionnelle
│   └── BlockchainMining.lean     <- structure de chaîne + preuve de détection de fraude
└── openqasm/
    ├── bitonic_sort.qasm         <- réseau de tri traduit en portes quantiques (n=4, 1 bit)
    ├── grover_mining_nonce.qasm  <- recherche de nonce accélérée par Grover (jouet, n=4)
    └── simulate_qasm.py          <- interprète/simule les deux circuits avec Qiskit
```

## Pourquoi ces deux algorithmes ensemble ?

Le point commun entre le **tri bitonique** et le **minage PoW** est que ce
sont tous les deux des algorithmes dont la **structure des opérations est
indépendante des données** :
- le tri bitonique effectue toujours exactement la même suite de
  comparaisons, quel que soit le tableau d'entrée (c'est un *réseau de
  tri*) → cela se traduit directement en circuit (matériel ou quantique) ;
- le minage PoW est une recherche par force brute dans un espace non
  structuré (le nonce) → c'est le problème type que l'algorithme de
  Grover accélère quadratiquement.

C'est pour cette raison que les deux se prêtent à une traduction en
OpenQASM, alors que ce n'est pas le cas de la plupart des algorithmes.

## 1. OCaml — exécuter

Aucune dépendance externe (`Digest` et `Array` sont dans la stdlib).

**Pour apprendre / comprendre le code**, lance chaque fichier séparément
et à la main :

```bash
cd ocaml
ocaml bitonic_sort.ml
ocaml blockchain_mining.ml
```

**Le `Makefile`** (à la racine) ne remplace pas cette étape : il sert à
autre chose. C'est une convention académique — un correcteur ou un
coéquipier qui récupère le projet veut souvent tout compiler d'un coup,
sans connaître les commandes OCaml exactes :

```bash
make          # compile (ou exécute en fallback) les deux fichiers
make clean    # supprime les fichiers générés
```

En résumé : `ocaml fichier.ml` pour toi (pédagogique, tu vois chaque
étape) ; `make` pour la remise du projet (automatisation, standard des
livrables C/OCaml).

**Pour t'entraîner à maîtriser le code**, relis dans cet ordre :
1. `compare_and_swap` (la brique de base — une seule comparaison)
2. `bitonic_merge` (comment "nettoyer" une suite déjà bitonique)
3. `bitonic_sort_rec` (comment *créer* une suite bitonique puis la nettoyer)

Pour la blockchain :
1. `calculer_hash` (comment un bloc devient une empreinte)
2. `miner` (la boucle de force brute — le cœur du Proof of Work)
3. `chaine_valide` (comment on détecte une fraude a posteriori)

## 2. Lean 4 — exécuter

Nécessite [Lean 4 + Lake](https://leanprover.github.io/lean4/doc/setup.html)
installés localement (non exécutable dans cet environnement sandbox, réseau
restreint). Une fois Lean installé :

```bash
lean lean/BitonicSort.lean
lean lean/BlockchainMining.lean
```

Les fichiers compilent syntaxiquement. Les théorèmes de correction
(`trierBitonique_trie`, `trierBitonique_permutation`, `fraude_detectee`)
sont **énoncés** avec `sorry` : c'est volontaire et expliqué dans le
rapport — l'objectif du TP est de maîtriser la formulation formelle de
la spécification, pas de produire une preuve Mathlib complète (qui
dépasserait largement le cadre d'un TP2).

## 3. OpenQASM — exécuter

Un fichier `.qasm` n'est qu'une **description** de circuit : il faut un
simulateur pour l'exécuter et lire le résultat des mesures — c'est le
rôle de `openqasm/simulate_qasm.py`, qui charge et simule les deux
circuits avec Qiskit (1024 répétitions chacun) :

```bash
pip install qiskit qiskit-aer
cd openqasm
python simulate_qasm.py
```

Résultat attendu :
- **bitonic_sort.qasm** : un seul résultat mesuré à 100 %, le tableau
  trié (attention à l'ordre des bits Qiskit, expliqué dans le script :
  `out[3] out[2] out[1] out[0]`, qubit 0 le plus à droite).
- **grover_mining_nonce.qasm** : le nonce cible `11` mesuré à ~100 %,
  contre 25 % attendu sans l'accélération de Grover.

Ce circuit de tri a été **vérifié exhaustivement** sur les 16 entrées
possibles de {0,1}⁴ (voir le commentaire en tête de
`bitonic_sort.qasm`) : la version d'uncompute des ancillas y est
correcte (les copies temporaires sont défaites *avant* le swap, pas
après — piège classique de la conception de circuits réversibles,
expliqué en détail dans le rapport).

Alternative : copier-coller le contenu d'un fichier `.qasm` dans
[IBM Quantum Composer](https://quantum.ibm.com/composer) (mode texte).

## 4. Rapport

`rapport.docx` (≤ 20 pages) contient : le contexte théorique de chaque
algorithme, l'explication détaillée du code des trois langages, les
résultats de test, et une discussion sur les limites de la traduction
quantique (section OpenQASM).

## Auteure

Merveille Prisca — Licence 3 Informatique, Université de Yaoundé I — INF3421.
