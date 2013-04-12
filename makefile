all:
	ITERATIONS=1 HASH_FUNCTION=SHA512 cutest -r ./test/helper test/*_test.rb
	ITERATIONS=2 HASH_FUNCTION=SHA512 cutest -r ./test/helper test/*_test.rb
	ITERATIONS=3 HASH_FUNCTION=SHA512 cutest -r ./test/helper test/*_test.rb
	ITERATIONS=5000 HASH_FUNCTION=SHA512 cutest -r ./test/helper test/*_test.rb
	ITERATIONS=10_000 HASH_FUNCTION=SHA1 cutest -r ./test/helper test/*_test.rb
