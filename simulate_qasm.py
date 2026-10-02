"""
simulate_qasm.py — interprète et simule les circuits OpenQASM du TP2 avec Qiskit.

Pourquoi ce script ?
Un fichier .qasm n'est qu'une DESCRIPTION de circuit (comme un .ml est une
description de programme) : il faut un simulateur pour l'exécuter et lire
le résultat des mesures. Ce script joue ce rôle, avec plusieurs "shots"
(répétitions) pour observer la distribution des résultats mesurés.

Usage :
    python simulate_qasm.py
"""

from qiskit import QuantumCircuit
from qiskit_aer import AerSimulator

SIMULATEUR = AerSimulator()
NB_SHOTS = 1024


def simuler(fichier_qasm: str, nom: str) -> None:
    print(f"\n=== {nom} ({fichier_qasm}) ===")
    circuit = QuantumCircuit.from_qasm_file(fichier_qasm)
    circuit_transpile = circuit  # AerSimulator gère les portes standard directement
    resultat = SIMULATEUR.run(circuit_transpile, shots=NB_SHOTS).result()
    comptes = resultat.get_counts()

    # Tri des résultats par fréquence décroissante, pour lecture facile
    comptes_tries = sorted(comptes.items(), key=lambda kv: kv[1], reverse=True)
    print(f"{NB_SHOTS} exécutions ('shots'). Résultats mesurés (bit le plus à droite = qubit 0) :")
    for bits, occurrences in comptes_tries:
        pourcentage = 100 * occurrences / NB_SHOTS
        barre = "#" * int(pourcentage / 2)
        print(f"  {bits} : {occurrences:4d} fois ({pourcentage:5.1f}%)  {barre}")


if __name__ == "__main__":
    simuler("bitonic_sort.qasm", "Tri bitonique (n=4, 1 bit/élément)")
    simuler("grover_mining_nonce.qasm", "Recherche de nonce par Grover (n=4)")

    print(
        "\nInterprétation :\n"
        "- Pour le tri bitonique : le circuit étant construit sur des états de\n"
        "  base (pas de superposition en entrée), on doit observer UN SEUL\n"
        "  résultat avec ~100% de probabilité : celui du tableau trié.\n"
        "  ATTENTION à l'ordre des bits Qiskit : la chaîne mesurée s'écrit\n"
        "  'out[3] out[2] out[1] out[0]' (le qubit 0 est le plus à DROITE).\n"
        "  Exemple : entrée a=[1,0,1,0] -> chaîne mesurée '1100'\n"
        "  -> out[0]=0, out[1]=0, out[2]=1, out[3]=1 -> tableau trié [0,0,1,1]. OK.\n"
        "- Pour Grover : le nonce cible (11) doit apparaître avec une\n"
        "  probabilité nettement supérieure aux 3 autres (25% chacun en\n"
        "  l'absence d'amplification), ce qui illustre l'accélération de\n"
        "  la recherche par rapport à un tirage uniforme classique."
    )
