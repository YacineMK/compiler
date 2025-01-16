BUILD_DIR := build
OUT_DIR := out
TEST_DIR := test
LIB_DIR := lib

FLEX_SRC := $(LIB_DIR)/lang.l
BISON_SRC := $(LIB_DIR)/parser.y

TEST_FILE := $(TEST_DIR)/test.txt
TS_HEADER := $(LIB_DIR)/ts.h

LEX_FILE := $(OUT_DIR)/lex.yy.c
BISON_FILE := $(OUT_DIR)/parser.tab.c
BISON_HEADER := $(OUT_DIR)/parser.tab.h

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

build: $(BUILD_DIR) $(OUT_DIR) $(LEX_FILE) $(BISON_FILE)

$(LEX_FILE): $(FLEX_SRC)
	flex -o $(LEX_FILE) $(FLEX_SRC)

$(BISON_FILE) $(BISON_HEADER): $(BISON_SRC)
	bison -d $(BISON_SRC) -o $(BISON_FILE)

copy_header: $(OUT_DIR)
	cp $(TS_HEADER) $(OUT_DIR)

compile: build copy_header
	gcc -o $(BUILD_DIR)/main $(LEX_FILE) $(BISON_FILE)

test: compile
	cp $(TEST_FILE) $(BUILD_DIR)/program.txt
	cd $(BUILD_DIR) && ./main < program.txt

clean:
	rm -rf $(BUILD_DIR) $(OUT_DIR)/*

all: build compile test
