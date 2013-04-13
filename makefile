all:
	RUBYLIB=./lib cutest -r ./test/helper test/*_test.rb
