(* ============================================================
   TRI BITONIQUE (Bitonic Sort) — implémentation pédagogique
   ============================================================

   Idée générale :
   - Une suite est "bitonique" si elle croît puis décroît (ou est
     une rotation d'une telle suite). Ex : [1;3;5;4;2] est bitonique.
   - Le tri bitonique construit récursivement des suites bitoniques
     de plus en plus grandes, puis les "nettoie" (bitonic_merge)
     pour obtenir une suite triée.
   - Contrainte classique : la taille du tableau doit être une
     puissance de 2 (2, 4, 8, 16, ...).

   Complexité : O(n log^2 n) comparaisons — moins bon qu'un tri
   rapide en séquentiel, mais l'intérêt du tri bitonique est qu'il
   est un "réseau de tri" (sorting network) : la suite des
   comparaisons est fixée à l'avance, indépendamment des données.
   C'est ce qui le rend parallélisable et implémentable en circuit
   (matériel, GPU, ou même... quantique, voir openqasm/).
   ============================================================ *)

(* Sens du tri : croissant (Asc) ou décroissant (Desc) *)
type sens = Asc | Desc

(* --------------------------------------------------------------
   compare_and_swap : brique de base du réseau de tri.
   Compare deux éléments à deux positions i et j du tableau, et les
   échange si l'ordre ne correspond pas au sens voulu.
   -------------------------------------------------------------- *)
let compare_and_swap (a : int array) (i : int) (j : int) (dir : sens) : unit =
  let doit_echanger =
    match dir with
    | Asc -> a.(i) > a.(j)
    | Desc -> a.(i) < a.(j)
  in
  if doit_echanger then begin
    let tmp = a.(i) in
    a.(i) <- a.(j);
    a.(j) <- tmp
  end

(* --------------------------------------------------------------
   bitonic_merge : étant donné une sous-suite bitonique a.(bas..bas+n-1),
   la transforme en une suite triée dans le sens `dir`.

   Principe : on compare chaque élément de la première moitié avec
   l'élément "à distance n/2" dans la seconde moitié, puis on
   applique récursivement le même traitement sur chaque moitié.
   -------------------------------------------------------------- *)
let rec bitonic_merge (a : int array) (bas : int) (n : int) (dir : sens) : unit =
  if n > 1 then begin
    let moitie = n / 2 in
    for i = bas to bas + moitie - 1 do
      compare_and_swap a i (i + moitie) dir
    done;
    bitonic_merge a bas moitie dir;
    bitonic_merge a (bas + moitie) moitie dir
  end

(* --------------------------------------------------------------
   bitonic_sort_rec : trie récursivement a.(bas..bas+n-1) dans le sens `dir`.

   Principe (diviser pour régner) :
   1. On trie la première moitié en ordre croissant.
   2. On trie la seconde moitié en ordre décroissant.
      -> l'ensemble forme alors une suite bitonique.
   3. On appelle bitonic_merge pour "fusionner" cette suite bitonique
      en une suite triée dans le sens `dir`.
   -------------------------------------------------------------- *)
let rec bitonic_sort_rec (a : int array) (bas : int) (n : int) (dir : sens) : unit =
  if n > 1 then begin
    let moitie = n / 2 in
    bitonic_sort_rec a bas moitie Asc;
    bitonic_sort_rec a (bas + moitie) moitie Desc;
    bitonic_merge a bas n dir
  end

(* Point d'entrée : trie tout le tableau en ordre croissant.
   Précondition : Array.length a est une puissance de 2. *)
let bitonic_sort (a : int array) : unit =
  bitonic_sort_rec a 0 (Array.length a) Asc

(* --------------------------------------------------------------
   Vérification que n est une puissance de 2 (utile pour valider
   les entrées avant d'appeler bitonic_sort).
   -------------------------------------------------------------- *)
let is_power_of_two (n : int) : bool =
  n > 0 && n land (n - 1) = 0

(* ==================== PROGRAMME DE TEST ==================== *)
let afficher (a : int array) : unit =
  Array.iter (fun x -> Printf.printf "%d " x) a;
  print_newline ()

let () =
  let tableau = [| 5; 3; 8; 1; 9; 2; 7; 4 |] in
  Printf.printf "Tableau initial : ";
  afficher tableau;

  if not (is_power_of_two (Array.length tableau)) then
    failwith "La taille du tableau doit être une puissance de 2";

  bitonic_sort tableau;
  Printf.printf "Tableau trié    : ";
  afficher tableau;

  (* second test avec une taille différente, en décroissant *)
  let t2 = [| 12; 4; 7; 1; 0; 15; 3; 9; 2; 6; 11; 14; 5; 8; 10; 13 |] in
  bitonic_sort_rec t2 0 (Array.length t2) Desc;
  Printf.printf "Trié (décroissant, n=16) : ";
  afficher t2
