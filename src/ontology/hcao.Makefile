## Customize Makefile settings for hcao
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile




##############################
##############################
###### 
###### N.B. For historical reasons this combined Makefile contains rules for
###### four SEPARATE targets:
######
######   1. HCAO
######   2. EFO slim
######   3. HPO slim
######   4. FBBI slim
######
###### These targets are NOT interdependent and should probably be separated
###### into different ODK projects in the future.
######
##############################
##############################



### Custom mirror for MONDO: used by both HCAO and the HPO slim

.PHONY: mirror-mondo
.PRECIOUS: $(MIRRORDIR)/mondo.owl
mirror-mondo: | $(TMPDIR)
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then curl -L $(OBOBASE)/mondo.owl --create-dirs -o $(MIRRORDIR)/mondo.owl --retry 4 --max-time 200 &&\
		$(ROBOT) convert -i $(MIRRORDIR)/mondo.owl -o $@.tmp.owl &&\
		mv $@.tmp.owl $(TMPDIR)/$@.owl; fi





##################
###### HCAO ######
##################

# ===============================
# HCAO: Release artefact override
# ===============================

$(ONT)-full.owl: $(EDIT_PREPROCESSED) $(OTHER_SRC) $(IMPORT_FILES)
	$(ROBOT) merge --input $< -o $(TMPDIR)/hcao_merged.owl &&\
	$(ROBOT) remove --input $(TMPDIR)/hcao_merged.owl -T terms_to_delete.txt -p false -o $(TMPDIR)/hcao_cleaned.owl &&\
	$(ROBOT) remove --input $(TMPDIR)/hcao_cleaned.owl --axioms "DisjointClasses" -o $(TMPDIR)/hcao_cleaned_temp.owl &&\
	$(ROBOT) reason --input $(TMPDIR)/hcao_cleaned_temp.owl -r ELK reduce -r ELK annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@
	
	
# =======================
# HCAO: Custom components
# =======================

$(COMPONENTSDIR)/uberon_human_extended.owl: $(TMPDIR)/fma_uberon.owl $(TMPDIR)/uberon_human.owl
	$(ROBOT) merge --input $(TMPDIR)/fma_uberon.owl --input $(TMPDIR)/uberon_human.owl relax reduce --output $@

$(COMPONENTSDIR)/go_cell_cycle.owl: $(MIRRORDIR)/go.owl
	$(ROBOT) extract --input $(MIRRORDIR)/go.owl --method MiREOT -b GO:0022403 --output $@

$(COMPONENTSDIR)/cl_import.owl: $(MIRRORDIR)/cl.owl $(TMPDIR)/uberon_axioms_in_cl.owl
	$(ROBOT) merge -i $< unmerge -i $(TMPDIR)/uberon_axioms_in_cl.owl -o $@

$(COMPONENTSDIR)/clo_import.owl: ./clo_terms.txt $(MIRRORDIR)/clo.owl
	$(ROBOT) extract --method BOT --input $(MIRRORDIR)/clo.owl --term-file ./clo_terms.txt remove -t "OBI:0000759" -o $@


# =====================
# HCAO: Temporary files 
# =====================

$(TMPDIR)/fma_uberon.owl: $(TMPDIR)/uberon_human.owl $(MIRRORDIR)/fma.owl
	$(ROBOT) extract --input $(MIRRORDIR)/fma.owl --method MiREOT -L fma_terms.txt -u FMA:67135 rename --mappings fma_uberon_mappings.csv --output $@

$(TMPDIR)/uberon_human.owl: $(TMPDIR)/uberon_with_fma_labels.ttl $(TMPDIR)/uberon_terms_combined.txt $(MIRRORDIR)/uberon.owl 
	$(ROBOT) extract --method BOT \
		--input $(MIRRORDIR)/uberon.owl \
		--term-file $(TMPDIR)/uberon_terms_combined.txt \
		merge \
		--input $(TMPDIR)/uberon_with_fma_labels.ttl \
		--output $(TMPDIR)/uberon_human.owl

$(TMPDIR)/uberon_with_fma_labels.ttl: $(MIRRORDIR)/fma.owl
	$(ROBOT) merge --input $(MIRRORDIR)/fma.owl --input $(MIRRORDIR)/uberon.owl query --format ttl --construct ../sparql/construct_fma_labels.sparql $(TMPDIR)/uberon_with_fma_labels.ttl

$(TMPDIR)/uberon_terms_combined.txt: $(MIRRORDIR)/uberon.owl uberon_terms.txt
	$(ROBOT) query -f csv --input $(MIRRORDIR)/uberon.owl --query ../sparql/select_added_for_hca.sparql $(TMPDIR)/uberon_added_for_hca.txt ; \
	$(ROBOT) query -f csv --input $(MIRRORDIR)/uberon.owl --query ../sparql/select_human_anatomy_subset.sparql $(TMPDIR)/uberon_human_anatomy_subset.txt ; \
	cat uberon_terms.txt $(TMPDIR)/uberon_added_for_hca.txt $(TMPDIR)/uberon_human_anatomy_subset.txt | grep -v ^# | sort | uniq > $@ ; \

$(TMPDIR)/uberon_axioms_in_cl.owl: $(TMPDIR)/uberon_axioms_in_cl.ofn
	sed '/^Declaration/d' $< > $@

$(TMPDIR)/uberon_axioms_in_cl.ofn: $(MIRRORDIR)/cl.owl
	$(ROBOT) merge -i $< remove --base-iri http://purl.obolibrary.org/obo/UBERON_ --axioms external --trim false -o $@

# ====================
# HCAO: Custom mirrors
# ====================

.PHONY: mirror-uberon
.PRECIOUS: $(MIRRORDIR)/uberon.owl
mirror-uberon: | $(TMPDIR)
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then curl -L $(OBOBASE)/uberon.owl --create-dirs -o $(MIRRORDIR)/uberon.owl --retry 4 --max-time 200 &&\
		$(ROBOT) convert -i $(MIRRORDIR)/uberon.owl -o $@.tmp.owl &&\
		mv $@.tmp.owl $(TMPDIR)/$@.owl; fi

.PHONY: mirror-cl
.PRECIOUS: $(MIRRORDIR)/cl.owl
mirror-cl: | $(TMPDIR)
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then curl -L $(OBOBASE)/cl.owl --create-dirs -o $(MIRRORDIR)/cl.owl --retry 4 --max-time 200 &&\
		$(ROBOT) convert -i $(MIRRORDIR)/cl.owl -o $@.tmp.owl &&\
		mv $@.tmp.owl $(TMPDIR)/$@.owl; fi

.PHONY: mirror-go
.PRECIOUS: $(MIRRORDIR)/go.owl
mirror-go: | $(TMPDIR)
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then curl -L $(OBOBASE)/go.owl --create-dirs -o $(MIRRORDIR)/go.owl --retry 4 --max-time 200 &&\
		$(ROBOT) convert -i $(MIRRORDIR)/go.owl -o $@.tmp.owl &&\
		mv $@.tmp.owl $(TMPDIR)/$@.owl; fi

.PHONY: mirror-clo
.PRECIOUS: $(MIRRORDIR)/clo.owl
mirror-clo: | $(TMPDIR)
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then curl -L $(OBOBASE)/clo.owl --create-dirs -o $(MIRRORDIR)/clo.owl --retry 4 --max-time 200 &&\
		$(ROBOT) convert -i $(MIRRORDIR)/clo.owl -o $@.tmp.owl &&\
		mv $@.tmp.owl $(TMPDIR)/$@.owl; fi

.PHONY: mirror-fma
.PRECIOUS: $(MIRRORDIR)/fma.owl
mirror-fma: | $(TMPDIR)
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then curl -L $(OBOBASE)/fma.owl --create-dirs -o $(MIRRORDIR)/fma.owl --retry 4 --max-time 200 &&\
		$(ROBOT) convert -i $(MIRRORDIR)/fma.owl -o $@.tmp.owl &&\
		mv $@.tmp.owl $(TMPDIR)/$@.owl; fi







#####################
###### EFO SLIM #####
#####################

# ==================================
# EFO SLIM: Custom release artefacts
# ==================================

efo_slim.owl: $(TMPDIR)/efo_inferred.owl 
	$(ROBOT) extract -i $(TMPDIR)/efo_inferred.owl --method MIREOT -B efo_slim_terms.txt annotate --ontology-iri http://ontology.data.humancellatlas.org/ontologies/efo -o efo_slim.owl


# =========================
# EFO SLIM: Temporary files
# =========================

$(TMPDIR)/efo_inferred.owl: $(MIRRORDIR)/efo.owl
	$(ROBOT) -v reason -s true -m true -r hermit -i $< -o $@


# ========================
# EFO SLIM: Custom mirrors
# ========================

.PHONY: mirror-efo
.PRECIOUS: $(MIRRORDIR)/efo.owl
mirror-efo: | $(TMPDIR)
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then curl -L https://www.ebi.ac.uk/efo/efo.owl --create-dirs -o $(MIRRORDIR)/efo.owl --retry 4 --max-time 200 &&\
		$(ROBOT) convert -i $(MIRRORDIR)/efo.owl -o $@.tmp.owl &&\
		mv $@.tmp.owl $(TMPDIR)/$@.owl; fi







#####################
###### HPO SLIM #####
#####################

# ==================================
# HPO SLIM: Custom release artefacts
# ==================================

hpo_slim.owl: $(MIRRORDIR)/hp.owl $(TMPDIR)/hpo_remove_terms.txt
	$(ROBOT) extract -i $< --method MIREOT -B hpo_slim_terms.txt \
	remove -T $(TMPDIR)/hpo_remove_terms.txt \
	annotate --ontology-iri http://ontology.data.humancellatlas.org/ontologies/hp -o $@

# =========================
# HPO SLIM: Temporary files
# =========================

$(TMPDIR)/hpo_remove_terms.txt: $(MIRRORDIR)/mondo.owl
	$(ROBOT) query -i $< --query ../sparql/hp-mondo-exact.sparql $@

# ========================
# HPO SLIM: Custom mirrors
# ========================

.PHONY: mirror-hp
.PRECIOUS: $(MIRRORDIR)/hp.owl
mirror-hp: | $(TMPDIR)
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then curl -L $(OBOBASE)/hp.owl --create-dirs -o $(MIRRORDIR)/hp.owl --retry 4 --max-time 200 &&\
		$(ROBOT) convert -i $(MIRRORDIR)/hp.owl -o $@.tmp.owl &&\
		mv $@.tmp.owl $(TMPDIR)/$@.owl; fi





#######################
###### FBBI SLIM ######
#######################

# ===================================
# FBBI SLIM: Custom release artefacts
# ===================================

fbbi_hcao.owl: $(TMPDIR)/fbbi_terms.txt $(MIRRORDIR)/fbbi.owl
	$(ROBOT) extract --method BOT --input $(MIRRORDIR)/fbbi.owl --term-file $(TMPDIR)/fbbi_terms.txt annotate --ontology-iri "http://ontology.data.humancellatlas.org/ontologies/fbbi" --output $@

# ==========================
# FBBI SLIM: Temporary files
# ==========================

$(TMPDIR)/fbbi_terms.txt: $(MIRRORDIR)/fbbi.owl
	echo "'microscopy'" | $(OWLTOOLS) $< --reasoner-query -r elk -d --stdin | cut -d ' ' -f2 > $@ && \
	echo "'fluorescent label'" | $(OWLTOOLS) $< --reasoner-query -r elk -d --stdin | cut -d ' ' -f2 >> $@

# =========================
# FBBI SLIM: Custom mirrors
# =========================

.PHONY: mirror-fbbi
.PRECIOUS: $(MIRRORDIR)/fbbi.owl
mirror-fbbi: | $(TMPDIR)
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then curl -L $(OBOBASE)/fbbi.owl --create-dirs -o $(MIRRORDIR)/fbbi.owl --retry 4 --max-time 200 &&\
		$(ROBOT) convert -i $(MIRRORDIR)/fbbi.owl -o $@.tmp.owl &&\
		mv $@.tmp.owl $(TMPDIR)/$@.owl; fi
