.PHONY: test

test:
	cutest -r ./test/helper test/*_test.rb
