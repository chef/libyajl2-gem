TARGET = libyajl
DLLIB = $(TARGET).bundle
all:
	cd /Users/lamont/git/libyajl2-gem/ext/libyajl2/vendor/yajl/src && make
	cp /Users/lamont/git/libyajl2-gem/ext/libyajl2/vendor/yajl/src/$(DLLIB) .
install:
	cp $(DLLIB) /Users/lamont/git/libyajl2-gem/lib/libyajl2/vendored-libyajl2
clean:
	cd /Users/lamont/git/libyajl2-gem/ext/libyajl2/vendor/yajl/src && make clean
