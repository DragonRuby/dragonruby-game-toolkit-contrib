db = FFI::DuckDB.new
# db.raw("create table integers(i integer, j integer);")
# db.raw("insert into integers values (1, 2) (3, 4) (5, 6);")
# rows = db.query("select * from integers")
# rows.each do |row|
#   puts row[:i]
#   puts row[:j]
# end
