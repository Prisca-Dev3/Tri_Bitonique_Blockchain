/-
  ============================================================
  BLOCKCHAIN & PROOF OF WORK — formalisation Lean 4 (version simple)
  ============================================================

  On modélise ici la STRUCTURE d'une blockchain et la PROPRIÉTÉ de
  validité d'une chaîne, en miroir du code OCaml (blockchain_mining.ml).
  Le calcul de hash réel (MD5/SHA-256) n'est pas ré-implémenté en Lean
  (ce n'est pas l'objet du TP) : on le modélise par une fonction
  abstraite `hacher`, ce qui suffit pour énoncer et raisonner sur les
  propriétés de chaînage et d'intégrité.
-/

namespace BlockchainMinage

/-- Un bloc, structurellement identique au type `bloc` OCaml :
    index, données, hash du bloc précédent, nonce, hash du bloc. -/
structure Bloc where
  index : Nat
  donnees : String
  hashPrecedent : String
  nonce : Nat
  hash : String
deriving Repr, DecidableEq

/-- Fonction de hachage abstraite : en pratique MD5/SHA-256, ici on la
    suppose seulement donnée (paramètre de la théorie), avec les deux
    hypothèses réalistes qu'on utilise plus bas :
    - déterministe (même entrée -> même hash), ce qui est vrai par
      construction d'une fonction Lean ;
    - "résistante aux collisions" en pratique (on ne le prouve pas,
      c'est une hypothèse cryptographique, pas un théorème). -/
def hacher (contenuDeBloc : Bloc → String) (b : Bloc) : String :=
  contenuDeBloc b

/-- Concatène les champs d'un bloc, comme `calculer_hash` côté OCaml
    (avant application de la fonction de hachage proprement dite). -/
def contenu (b : Bloc) : String :=
  toString b.index ++ b.donnees ++ b.hashPrecedent ++ toString b.nonce

/-- Un bloc est valide vis-à-vis d'une fonction de hachage `h` si son
    champ `hash` correspond bien au hash recalculé de son contenu. -/
def blocValide (h : Bloc → String) (b : Bloc) : Prop :=
  b.hash = h b

/-- Un bloc respecte la difficulté `d` si son hash commence par `d`
    zéros — modélisé ici via `String.take`. -/
def respecteDifficulte (b : Bloc) (d : Nat) : Prop :=
  b.hash.take d = String.mk (List.replicate d '0')

/-- Une chaîne est une liste de blocs, du plus ancien (tête) au plus
    récent. -/
abbrev Chaine := List Bloc

/-- `chainee` : chaque bloc (sauf le premier) pointe correctement vers
    le hash de son prédécesseur. C'est la propriété de "chaînage". -/
def chainee : Chaine → Prop
  | [] => True
  | [_] => True
  | b1 :: b2 :: reste => b2.hashPrecedent = b1.hash ∧ chainee (b2 :: reste)

/-- `integre h` : chaque bloc de la chaîne est valide vis-à-vis de la
    fonction de hachage `h` (aucune donnée n'a été modifiée après
    minage). -/
def integre (h : Bloc → String) : Chaine → Prop
  | [] => True
  | b :: reste => blocValide h b ∧ integre h reste

/-- Une chaîne est valide si elle est à la fois chaînée ET intègre —
    exactement les deux conditions vérifiées par `chaine_valide` côté
    OCaml. -/
def chaineValide (h : Bloc → String) (c : Chaine) : Prop :=
  chainee c ∧ integre h c

/-!
  ### Théorème central : une fraude est détectable

  Si on modifie les données d'un bloc `b` DÉJÀ MINÉ (sans recalculer
  son hash), alors soit le bloc modifié devient lui-même invalide
  (son `hash` stocké ne correspond plus à `h` appliqué à son nouveau
  contenu), soit — si par malchance `h` donnait le même hash après
  modification (collision) — l'intégrité globale n'est plus garantie
  que par la résistance aux collisions de `h`, qui est une hypothèse
  cryptographique et non un fait prouvable en Lean pur.

  On énonce donc la version faible mais honnête du théorème : sous
  l'hypothèse que `h` est "sans collision" (injective sur les
  contenus de blocs), toute modification des données d'un bloc rend
  la chaîne invalide.
-/

theorem fraude_detectee
    (h : Bloc → String) (hInjective : Function.Injective (contenu · |> h ∘ id))
    (b b' : Bloc) (reste : Chaine)
    (hDiff : b.donnees ≠ b'.donnees)
    (hMemeAutres : b.index = b'.index ∧ b.hashPrecedent = b'.hashPrecedent
                    ∧ b.nonce = b'.nonce ∧ b.hash = b'.hash)
    (hValideAvant : chaineValide h (b :: reste)) :
    ¬ chaineValide h (b' :: reste) := by
  sorry
  -- Preuve (esquisse) : contenu b ≠ contenu b' (car donnees diffère et
  -- les autres champs sont identiques), donc par injectivité de h,
  -- h(contenu b) ≠ h(contenu b'). Or b.hash = h(contenu b) (bloc valide
  -- avant fraude) et b'.hash = b.hash (donnée non re-minée), donc
  -- b'.hash ≠ h(contenu b'), donc blocValide h b' est faux, donc
  -- integre h (b' :: reste) est faux, donc chaineValide h (b' :: reste)
  -- est faux. QED (à formaliser complètement avec Mathlib).

end BlockchainMinage
