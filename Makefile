.PHONY: all bitonic blockchain clean

all: bitonic blockchain

bitonic:
	cd ocaml && ocamlfind ocamlopt -package str -linkpkg bitonic_sort.ml -o bitonic_sort 2>/dev/null || ocaml bitonic_sort.ml

blockchain:
	cd ocaml && ocamlfind ocamlopt -linkpkg blockchain_mining.ml -o blockchain_mining 2>/dev/null || ocaml blockchain_mining.ml

clean:
	cd ocaml && rm -f *.cmi *.cmo *.cmx *.o bitonic_sort blockchain_mining
