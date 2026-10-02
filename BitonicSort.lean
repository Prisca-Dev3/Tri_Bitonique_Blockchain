/-
  ============================================================
  TRI BITONIQUE — formalisation Lean 4 (version simple)
  ============================================================

  Objectif pédagogique : traduire les MÊMES idées que le code OCaml
  (compare_and_swap, bitonic_merge, bitonic_sort) dans un langage
  à typage dépendant, et énoncer (sans forcément tout prouver de
  façon exhaustive) les propriétés qu'on attend d'un tri :
    - le résultat est trié
    - le résultat est une permutation de l'entrée

  On travaille sur `List Nat` par simplicité (au lieu d'un tableau
  mutable comme en OCaml).
-/

namespace TriBitonique

inductive Sens where
  | asc
  | desc
deriving Repr, DecidableEq

/-- Compare deux éléments selon le sens voulu, et les échange si besoin.
    Version "pure" (pas de mutation) : renvoie la paire éventuellement
    échangée. -/
def compareEtEchange (dir : Sens) (x y : Nat) : Nat × Nat :=
  match dir with
  | Sens.asc  => if x > y then (y, x) else (x, y)
  | Sens.desc => if x < y then (y, x) else (x, y)

/-- `estTrie dir l` : la liste `l` est triée dans le sens `dir`. -/
def estTrie (dir : Sens) : List Nat → Prop
  | [] => True
  | [_] => True
  | x :: y :: reste =>
      (match dir with
        | Sens.asc  => x ≤ y
        | Sens.desc => x ≥ y)
      ∧ estTrie dir (y :: reste)

/-- Découpe une liste en deux moitiés de même taille (n doit être pair).
    C'est l'équivalent du partage de tableau en OCaml (bas, bas+moitie). -/
def couper (l : List Nat) : List Nat × List Nat :=
  let n := l.length / 2
  (l.take n, l.drop n)

/-- Fusion bitonique : étant donné deux moitiés de même taille, on
    compare terme à terme (comme la boucle `for i` en OCaml), puis on
    fusionne récursivement chaque moitié résultante.
    Version simplifiée : on suppose |g| = |d|. -/
partial def bitonicMerge (dir : Sens) (l : List Nat) : List Nat :=
  match l with
  | [] => []
  | [x] => [x]
  | _ =>
    let (g, d) := couper l
    let paires := List.zip g d
    let gauche := paires.map (fun p => (compareEtEchange dir p.1 p.2).1)
    let droite := paires.map (fun p => (compareEtEchange dir p.1 p.2).2)
    bitonicMerge dir gauche ++ bitonicMerge dir droite

/-- Construit une suite bitonique (première moitié croissante, seconde
    décroissante) puis appelle bitonicMerge — exactement la même
    structure que `bitonic_sort_rec` en OCaml. -/
partial def bitonicSort (dir : Sens) (l : List Nat) : List Nat :=
  match l with
  | [] => []
  | [x] => [x]
  | _ =>
    let (g, d) := couper l
    let g' := bitonicSort Sens.asc g
    let d' := bitonicSort Sens.desc d
    bitonicMerge dir (g' ++ d')

/-- Tri en ordre croissant : point d'entrée, équivalent de
    `bitonic_sort` en OCaml. -/
def trierBitonique (l : List Nat) : List Nat :=
  bitonicSort Sens.asc l

-- ==================== EXEMPLES / TESTS ====================
-- #eval permet d'exécuter et de vérifier le résultat, comme un test
-- unitaire rapide.

#eval trierBitonique [5, 3, 8, 1, 9, 2, 7, 4]
-- attendu : [1, 2, 3, 4, 5, 7, 8, 9]

#eval trierBitonique [4, 3, 2, 1]
-- attendu : [1, 2, 3, 4]

/-!
  ### Propriétés que l'on énonce (spécification formelle)

  On énonce ici les théorèmes qui caractérisent un tri correct.
  Dans un développement Lean complet on les prouverait par
  induction sur la structure de `bitonicSort`/`bitonicMerge`
  (le cas `compareEtEchange` est le cas de base, `couper` fournit
  l'hypothèse d'induction sur des listes deux fois plus courtes).
  Ici, on les énonce comme spécification — objectif du TP étant la
  maîtrise du principe algorithmique plutôt qu'une preuve Lean
  complète, qui dépasserait le cadre de ce rendu.
-/

/-- Spécification 1 : le résultat est trié. -/
theorem trierBitonique_trie (l : List Nat) :
    estTrie Sens.asc (trierBitonique l) := by
  sorry

/-- Spécification 2 : le résultat est une permutation de l'entrée
    (aucune donnée n'est perdue ni inventée). -/
theorem trierBitonique_permutation (l : List Nat) :
    (trierBitonique l).Perm l := by
  sorry

end TriBitonique
