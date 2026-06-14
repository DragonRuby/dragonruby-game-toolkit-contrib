DR.dlopen "ext"

def self.boot args
  args.state = {}
end

def self.tick args
  if Kernel.tick_count == 0
    DR.delete_file_if_exist "data/game.db"

    SQLite3.open "data/game.db"

    SQLite3.exec <<~S
                   create table if not exists enemies (
                     id   integer primary key autoincrement,
                     name text    not null,
                     hp   integer not null
                   );
                   S

    SQLite3.exec <<~S
                   insert into enemies (name, hp) values ('slime', 10);
                   insert into enemies (name, hp) values ('goblin', 20);
                   insert into enemies (name, hp) values ('dragon', 100);
                   S

    rows = SQLite3.query_json <<~S
                               select json_object('id', id, 'name', name, 'hp', hp) from enemies;
                               S

    json_rows = rows.map do |row|
      DR.parse_json row
    end

    pp json_rows
  end
end

DR.reset
