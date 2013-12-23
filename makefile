.PHONY: test

test:
	cutest -r ./test/helper test/*.rb
