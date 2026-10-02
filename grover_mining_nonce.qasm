// ============================================================
// MINAGE / PROOF OF WORK — illustration quantique (Grover, jouet)
// ============================================================
//
// Le minage classique cherche par force brute un nonce n tel que
// hash(n) commence par des zeros (cf. blockchain_mining.ml).
// C'est un probleme de "recherche dans une liste non triee" :
// exactement le type de probleme que l'algorithme de Grover accelere
// (recherche en O(sqrt(N)) au lieu de O(N)).
//
// Ici, jouet pedagogique sur 2 bits (N=4 nonces possibles : 00,01,10,11) :
// on suppose qu'un seul nonce "n* = 11" est "valide" (marque par un
// oracle), et on utilise Grover pour le retrouver en UNE seule
// iteration (suffisant pour N=4).
//
// Cela NE remplace PAS un vrai calcul de hash (impossible a coder en
// portes reversibles simples ici) : c'est une demonstration du
// PRINCIPE algorithmique qui sous-tend les propositions de "minage
// quantique" academiques.
// ============================================================

OPENQASM 2.0;
include "qelib1.inc";

qreg q[2];     // les 2 bits du nonce candidat
qreg anc[1];   // ancilla pour l'oracle
creg c[2];     // resultat mesure (doit donner 11 avec forte probabilite)

// ---- Etape 1 : superposition uniforme des 4 nonces possibles ----
h q[0];
h q[1];

// ---- Etape 2 : oracle marquant n* = 11 ----
// (bascule la phase de l'etat |11> ; on utilise ici un CCZ obtenu via
// H + CCX + H sur l'ancilla, technique standard)
x anc[0];
h anc[0];
ccx q[0], q[1], anc[0];   // "marque" |11> en inversant sa phase
h anc[0];
x anc[0];

// ---- Etape 3 : diffuseur de Grover (inversion autour de la moyenne) ----
h q[0];
h q[1];
x q[0];
x q[1];
h q[1];
cx q[0], q[1];
h q[1];
x q[0];
x q[1];
h q[0];
h q[1];

// ---- Mesure : doit donner "11" avec une probabilite proche de 1 ----
measure q[0] -> c[0];
measure q[1] -> c[1];

// NOTE (voir rapport) : ce circuit est un exemple MINIMAL a des fins
// pedagogiques (N=4, une seule iteration de Grover suffit). Le
// rapport discute pourquoi une acceleration quantique reelle du
// minage SHA-256 reste hors de portee des ordinateurs quantiques
// actuels (NISQ), et se limite ici a illustrer le PRINCIPE.
