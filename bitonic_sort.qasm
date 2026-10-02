// ============================================================
// TRI BITONIQUE — circuit OpenQASM 2.0 (version CORRIGEE et
// VERIFIEE EXHAUSTIVEMENT sur les 16 entrees possibles)
// ============================================================
//
// Registres :
//   a[4]    : les 4 elements a trier (1 bit chacun)
//   copy[2] : ancillas "copie" REUTILISABLES d'un comparateur a
//             l'autre (toujours remises a 0 avant le comparateur
//             suivant -> voir la 2e moitie, en miroir, de chaque bloc)
//   cond[6] : une ancilla "condition" DEDIEE par comparateur (il y en
//             a 6 dans le reseau de tri bitonique pour n=4). Elle
//             reste "sale" (non remise a 0) apres usage : ce n'est
//             pas un probleme puisqu'elle n'est jamais mesuree, mais
//             cela explique pourquoi il en faut une par comparateur
//             plutot qu'une seule reutilisee.
//   out[4]  : resultat classique, apres mesure de a[0..3]
//
// Principe d'un compare_and_swap(i,j) REVERSIBLE ET CORRECT :
//   1) copier a[i] et a[j] dans des ancillas "copy" (CNOT)
//   2) calculer la condition de swap dans "cond" (Toffoli/CCX) a
//      partir de ces copies
//   3) DEFAIRE les copies "copy" IMMEDIATEMENT (avant le swap !),
//      en utilisant encore les valeurs a[i]/a[j] d'AVANT le swap
//   4) appliquer le swap conditionnel (CSWAP / porte de Fredkin),
//      controle par "cond"
// L'erreur classique (presente dans une version anterieure de ce
// fichier) est de vouloir defaire les ancillas APRES le swap : a ce
// moment les valeurs de a[i]/a[j] ont change, donc les operations
// d'annulation ne correspondent plus a celles qui ont cree les
// ancillas -> resultat FAUX. Ce fichier corrige ce piege.
//
// Reseau de comparateurs pour n=4 (identique a l'arbre d'appels
// bitonic_sort_rec / bitonic_merge d'ocaml/bitonic_sort.ml) :
//   etape 1 : (0,1) croissant ; (2,3) decroissant  -> suite bitonique
//   etape 2 : (0,2) croissant ; (1,3) croissant     -> merge distance 2
//   etape 3 : (0,1) croissant ; (2,3) croissant     -> merge distance 1
//
// Verifie par simulation (Qiskit/AerSimulator) sur les 16 entrees
// possibles de {0,1}^4 : sortie toujours egale a la version triee
// croissante de l'entree. Voir openqasm/simulate_qasm.py.
// ============================================================

OPENQASM 2.0;
include "qelib1.inc";
qreg a[4];
qreg copy[2];
qreg cond[6];
creg out[4];

// ---- donnees de test : a = [1,0,1,0] ----
x a[0];
x a[2];

// ============ ETAPE 1 : former la suite bitonique ============
// compare_and_swap(0,1) croissant
cx a[0],copy[0];
cx a[1],copy[1];
x copy[1];
ccx copy[0],copy[1],cond[0];
x copy[1];
cx a[1],copy[1];
cx a[0],copy[0];
cswap cond[0],a[0],a[1];

// compare_and_swap(2,3) decroissant
cx a[2],copy[0];
x copy[0];
cx a[3],copy[1];
ccx copy[0],copy[1],cond[1];
cx a[3],copy[1];
x copy[0];
cx a[2],copy[0];
cswap cond[1],a[2],a[3];

// ============ ETAPE 2 : bitonic_merge, distance 2 ============
// compare_and_swap(0,2) croissant
cx a[0],copy[0];
cx a[2],copy[1];
x copy[1];
ccx copy[0],copy[1],cond[2];
x copy[1];
cx a[2],copy[1];
cx a[0],copy[0];
cswap cond[2],a[0],a[2];

// compare_and_swap(1,3) croissant
cx a[1],copy[0];
cx a[3],copy[1];
x copy[1];
ccx copy[0],copy[1],cond[3];
x copy[1];
cx a[3],copy[1];
cx a[1],copy[0];
cswap cond[3],a[1],a[3];

// ============ ETAPE 3 : bitonic_merge, distance 1 ============
// compare_and_swap(0,1) croissant
cx a[0],copy[0];
cx a[1],copy[1];
x copy[1];
ccx copy[0],copy[1],cond[4];
x copy[1];
cx a[1],copy[1];
cx a[0],copy[0];
cswap cond[4],a[0],a[1];

// compare_and_swap(2,3) croissant
cx a[2],copy[0];
cx a[3],copy[1];
x copy[1];
ccx copy[0],copy[1],cond[5];
x copy[1];
cx a[3],copy[1];
cx a[2],copy[0];
cswap cond[5],a[2],a[3];

// ---- Mesure : resultat classique, doit etre trie croissant ----
measure a[0] -> out[0];
measure a[1] -> out[1];
measure a[2] -> out[2];
measure a[3] -> out[3];