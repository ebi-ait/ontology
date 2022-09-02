[![Build Status](https://travis-ci.org/HumanCellAtlas/ontology.svg?branch=master)](https://travis-ci.org/HumanCellAtlas/ontology)
[![Docker Repository on Quay](https://quay.io/repository/humancellatlas/ontology/status "Docker Repository on Quay")](https://quay.io/repository/humancellatlas/ontology)

# hcao

An application ontology for the Human Cell Atlas.  

## Components: 

### Anatomy:

Mamalian anatomy and cell type terms from Uberon and the cell ontology;  Human-specific labels from the Foundational Model of Anatomy

## Versions

### Stable release versions

The latest version of the ontology can always be found at:

http://purl.obolibrary.org/obo/hcao.owl

(note this will not show up until the request has been approved by obofoundry.org)

### Editors' version

Editors of this ontology should use the edit version, [src/ontology/hcao-edit.owl](src/ontology/hcao-edit.owl)

## Build a OLS docker instance with ontologies in

```
docker build . -t hcao-ols
docker run -p 8080:8080 -t hcao-ols 
``` 

OLS should now be running at http://localhost:8080

## Build the ontologies

To build all the relevant files:

```
make all
```

to move the built files to the correct directory:

```
make prepare_release
```

If you want to use `docker` to run the pipeline above, just call the `make` commands through the docker wrapper script `run.sh`:

```
sh run.sh make all
sh run.sh make prepare_release
```

## Ontologies included in HCAO OLS

### HCA-maintained component ontologies

- hcao.owl
- efo_slim.owl
- hpo_slim.owl
- fbbi_hcao.owl

### Externally managed ontologies

- Mondo (http://purl.obolibrary.org/obo/mondo.obo)
- HANCESTRO (https://raw.githubusercontent.com/EBISPOT/ancestro/master/hancestro.owl): The unreasoned version of HANCESTRO.
- EDAM (http://edamontology.org/EDAM.owl)


## Contact

Please use this GitHub repository's [Issue tracker](https://github.com/HumanCellAtlas/ontology/issues) to request new terms/classes or report errors or specific concerns related to the ontology.

## Acknowledgements

This ontology repository was created using the [ontology starter kit](https://github.com/INCATools/ontology-starter-kit)
