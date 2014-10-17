MXDRPATH:=$(shell pwd)/mxdrfunctions
XDRFILE=xdrfile-1.1.4
xdrpatch=patch -p0 <fix_buffer_overrun_1.1.4.patch
headerpatch=patch -p0 < ../headers.patch
create_thunk=matlab -nosplash -nodisplay -r "loadmxdrfile;quit"

all: mxdrfile
mxdrfile: xdrfile $(MXDRPATH)/include/xdrfile/patched.txt
$(MXDRPATH)/include/xdrfile/patched.txt:
	@cd $(MXDRPATH);\
		$(headerpatch);\
		echo "PATCHED" >include/xdrfile/patched.txt;\
		cd ..;\
		$(create_thunk) >/dev/null
xdrfile: $(MXDRPATH)/include/xdrfile/xdrfile.h
$(MXDRPATH)/include/xdrfile/xdrfile.h:
	@tar xzvf $(XDRFILE).tar.gz
	@$(xdrpatch)
	@cd $(XDRFILE) &&\
		./configure --enable-shared --prefix=$(MXDRPATH) &&\
		$(MAKE) install && $(MAKE) test
.PHONY : clean
clean:
	@rm -r \
	    $(XDRFILE) \
	    $(MXDRPATH)/bin \
	    $(MXDRPATH)/lib \
	    $(MXDRPATH)/include \
	    libxdr_thunk.so \
	    fileheaders.m
test:
	@matlab -nosplash -nodisplay -r "test_trr;quit"
