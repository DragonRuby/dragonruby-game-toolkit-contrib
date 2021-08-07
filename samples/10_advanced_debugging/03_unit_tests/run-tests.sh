# fswatch ./samples/10_advanced_debugging/03_unit_tests/benchmark_api_tests.rb | xargs -n1 -I{} sh ./samples/10_advanced_debugging/03_unit_tests/run-tests.sh
# set -e
# rake
# ./dragonruby mygame --test samples/10_advanced_debugging/03_unit_tests/require_tests.rb
# ./dragonruby mygame --test samples/10_advanced_debugging/03_unit_tests/gen_docs.rb
# ./dragonruby mygame --test samples/10_advanced_debugging/03_unit_tests/geometry_tests.rb
# ./dragonruby mygame --test samples/10_advanced_debugging/03_unit_tests/http_tests.rb
# ./dragonruby mygame --test samples/10_advanced_debugging/03_unit_tests/object_to_primitive_tests.rb
# ./dragonruby mygame --test samples/10_advanced_debugging/03_unit_tests/parsing_tests.rb
# ./dragonruby mygame --test samples/10_advanced_debugging/03_unit_tests/require_tests.rb
# ./dragonruby mygame --test samples/10_advanced_debugging/03_unit_tests/serialize_deserialize_tests.rb
# ./dragonruby mygame --test samples/10_advanced_debugging/03_unit_tests/state_serialization_experimental_tests.rb
# ./dragonruby mygame --test samples/10_advanced_debugging/03_unit_tests/suggest_autocompletion_tests.rb
# ./dragonruby mygame --test samples/10_advanced_debugging/03_unit_tests/nil_coercion_tests.rb
# ./dragonruby mygame --test samples/10_advanced_debugging/03_unit_tests/fn_tests.rb
# ./dragonruby mygame --test samples/10_advanced_debugging/03_unit_tests/pretty_format_test.rb
./dragonruby mygame --test samples/10_advanced_debugging/03_unit_tests/benchmark_api_tests.rb
