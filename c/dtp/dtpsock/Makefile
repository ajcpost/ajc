
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
	@echo "T3 Targets: $(T3_OBJ)"
	@echo "------------------------------------------"

$(PROJ_BUILD)/libdtpsock.a: $(T1_OBJ)
	ar rcs $@ $^

$(PROJ_BUILD)/test_client.exe: $(T2_OBJ)
	$(CC) $^ -o $@ $(LIB_FLAG) $(LIBS)

$(PROJ_BUILD)/test_server.exe: $(T3_OBJ)
	$(CC) $^ -o $@ $(LIB_FLAG) $(LIBS)

checkdirs: $(TGTS)
$(TGTS):
	@mkdir -p $@

.PHONY: all checkdirs clean
clean:
	@echo "Cleaning...$(PROJ_BUILD)"
	@rm -rf $(PROJ_BUILD)/*

all: clean checkdirs print $(PROJ_BUILD)/libdtpsock.a $(PROJ_BUILD)/test_client.exe $(PROJ_BUILD)/test_server.exe

$(foreach bdir, $(TGTS), $(eval $(call make-goal, $(bdir))))

