
# Configuration
include Make.config

## Targets
print:
	@echo "Info..."
	@echo "------------------------------------------"
	@echo "SRC: $(MODULES_SRC)"
	@echo "INC: $(MODULES_INCLUDE)"
	@echo "External INC: $(EXTERNAL_INCLUDE)"
	@echo "Targets: $(MODULE_TARGETS)"
	@echo "T1 Targets: $(T1_OBJ)"
	@echo "T2 Targets: $(T2_OBJ)"
	@echo "------------------------------------------"

$(PROJ_BUILD)/test_server.exe: $(T2_OBJ)
	$(CC) $^ -o $@ $(LIB_FLAG) $(LIBS)

$(PROJ_BUILD)/test_client.exe: $(T1_OBJ)
	$(CC) $^ -o $@ $(LIB_FLAG) $(LIBS)

checkdirs: $(MODULE_TARGETS)
$(MODULE_TARGETS):
	@mkdir -p $@

.PHONY: all checkdirs clean
clean:
	@echo "Cleaning...$(PROJ_BUILD)"
	@rm -rf $(PROJ_BUILD)/*

all: clean checkdirs print $(PROJ_BUILD)/test_server.exe $(PROJ_BUILD)/test_client.exe

$(foreach bdir, $(MODULE_TARGETS), $(eval $(call make-goal, $(bdir))))

