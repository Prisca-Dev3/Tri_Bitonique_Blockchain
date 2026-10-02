(* ============================================================
   MINAGE DE BLOCKCHAIN — Proof of Work (PoW), version pédagogique
   ============================================================

   Idée générale :
   - Une blockchain est une liste chaînée de blocs. Chaque bloc
     contient des données, le hash du bloc précédent, et un
     "nonce" (nombre arbitraire).
   - Le hash d'un bloc dépend de TOUT son contenu (données + hash
     précédent + nonce). Changer une seule donnée change
     complètement le hash (effet avalanche).
   - "Miner" un bloc = trouver un nonce tel que le hash du bloc
     commence par un certain nombre de zéros (la "difficulté").
     Comme le hash est imprévisible, la seule stratégie est
     d'essayer des nonces les uns après les autres : c'est le
     "Proof of Work" (preuve de travail).

   Ici on utilise MD5 (module Digest, natif à OCaml) à la place de
   SHA-256 pour rester simple et sans dépendance externe : le
   principe (trouver un nonce qui donne un hash "petit") est
   rigoureusement le même.
   ============================================================ *)

type bloc = {
  index : int;
  mutable donnees : string;
  hash_precedent : string;
  mutable nonce : int;
  mutable hash : string;
}

(* --------------------------------------------------------------
   calculer_hash : concatène les champs du bloc et calcule leur
   empreinte MD5 (Digest.string), convertie en hexadécimal.
   -------------------------------------------------------------- *)
let calculer_hash (b : bloc) : string =
  let contenu =
    string_of_int b.index
    ^ b.donnees
    ^ b.hash_precedent
    ^ string_of_int b.nonce
  in
  Digest.to_hex (Digest.string contenu)

(* --------------------------------------------------------------
   hash_valide : vérifie que le hash commence par `difficulte`
   zéros (en hexadécimal). Plus `difficulte` est grand, plus il
   faut d'essais en moyenne (en moyenne 16^difficulte essais).
   -------------------------------------------------------------- *)
let hash_valide (h : string) (difficulte : int) : bool =
  let prefixe = String.make difficulte '0' in
  String.length h >= difficulte && String.sub h 0 difficulte = prefixe

(* --------------------------------------------------------------
   miner : cherche par force brute un nonce qui rend le hash du
   bloc valide (Proof of Work). Renvoie le nombre d'essais effectués.
   -------------------------------------------------------------- *)
let miner (b : bloc) (difficulte : int) : int =
  b.nonce <- 0;
  b.hash <- calculer_hash b;
  let essais = ref 0 in
  while not (hash_valide b.hash difficulte) do
    b.nonce <- b.nonce + 1;
    b.hash <- calculer_hash b;
    incr essais
  done;
  !essais

(* --------------------------------------------------------------
   creer_bloc_genese : le tout premier bloc de la chaîne, dont le
   hash précédent est conventionnellement une chaîne de zéros.
   -------------------------------------------------------------- *)
let creer_bloc_genese () : bloc =
  { index = 0; donnees = "Bloc Genese"; hash_precedent = String.make 64 '0';
    nonce = 0; hash = "" }

(* --------------------------------------------------------------
   creer_bloc_suivant : construit un nouveau bloc chaîné sur le
   précédent (recopie son hash comme hash_precedent).
   -------------------------------------------------------------- *)
let creer_bloc_suivant (precedent : bloc) (donnees : string) : bloc =
  { index = precedent.index + 1; donnees; hash_precedent = precedent.hash;
    nonce = 0; hash = "" }

(* --------------------------------------------------------------
   chaine_valide : parcourt la chaîne et vérifie deux choses pour
   chaque bloc :
   1) son hash stocké correspond bien au hash recalculé (intégrité
      des données) ;
   2) son hash_precedent correspond au hash du bloc qui le précède
      (chaînage correct).
   -------------------------------------------------------------- *)
let chaine_valide (chaine : bloc list) : bool =
  let rec verifier = function
    | [] | [ _ ] -> true
    | b1 :: (b2 :: _ as reste) ->
      calculer_hash b2 = b2.hash
      && b2.hash_precedent = b1.hash
      && verifier reste
  in
  match chaine with
  | [] -> true
  | genese :: _ -> calculer_hash genese = genese.hash && verifier chaine

(* ==================== PROGRAMME DE TEST ==================== *)
let () =
  let difficulte = 4 in (* le hash doit commencer par 4 zéros hexa *)
  Printf.printf "=== Minage d'une blockchain (difficulte = %d) ===\n\n" difficulte;

  let genese = creer_bloc_genese () in
  let essais0 = miner genese difficulte in
  Printf.printf "Bloc 0 (genese) mine en %d essais -> hash = %s\n" essais0 genese.hash;

  let b1 = creer_bloc_suivant genese "Alice paie 10 a Bob" in
  let essais1 = miner b1 difficulte in
  Printf.printf "Bloc 1 mine en %d essais -> hash = %s\n" essais1 b1.hash;

  let b2 = creer_bloc_suivant b1 "Bob paie 3 a Charlie" in
  let essais2 = miner b2 difficulte in
  Printf.printf "Bloc 2 mine en %d essais -> hash = %s\n" essais2 b2.hash;

  let chaine = [ genese; b1; b2 ] in
  Printf.printf "\nChaine valide ? %b\n" (chaine_valide chaine);

  (* On simule une attaque : on modifie les donnees du bloc 1 sans
     re-miner -> la chaine doit devenir invalide. *)
  b1.donnees <- "Alice paie 1000 a Bob (fraude)";
  Printf.printf "Apres modification frauduleuse du bloc 1, chaine valide ? %b\n"
    (chaine_valide chaine)
