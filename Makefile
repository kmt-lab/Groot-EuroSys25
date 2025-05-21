GROOT_BUILD_DIR ?= build

all:
	( mkdir -p $(GROOT_BUILD_DIR) && cd $(GROOT_BUILD_DIR) && cmake -DCMAKE_BUILD_TYPE=Release .. && cmake --build . -j2 )

test:
	./$(GROOT_BUILD_DIR)/apps/mtx_converter -i toydata/cora.csr
	cp toydata/cora_groot.mtx ./
	./$(GROOT_BUILD_DIR)/apps/mtx_converter -i toydata/cora.csr
	diff cora_groot.mtx toydata/cora_groot.mtx

clean:
	( rm -rf $(GROOT_BUILD_DIR) )
