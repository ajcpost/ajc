
# Configuration
include Make.config

## Targets
print:
	@echo "Info..."
	@echo "------------------------------------------"
	@echo "SRC: $(SRC)"
	@echo "INC: $(INC)"
	@echo "External INC: $(EXTERNAL_INC)"
	@echo "Targets: $(TGTS)"
	@echo "T1 Targets: $(T1_OBJ)"
	@echo "T2 Targets: $(T2_OBJ)"
	@echo "------------------------------------------"

$(PROJ_BUILD)/libcore.a: $(T1_OBJ)
	ar rcs $@ $^

checkdirs: $(TGTS)
$(TGTS):
	@mkdir -p $@

.PHONY: all checkdirs clean
clean:
	@echo "Cleaning...$(PROJ_BUILD)"
	@rm -rf $(PROJ_BUILD)/*

all: clean checkdirs print $(PROJ_BUILD)/libcore.a

$(foreach bdir, $(TGTS), $(eval $(call make-goal, $(bdir))))

