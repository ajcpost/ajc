export DYLD_LIBRARY_PATH=/usr/local/mysql/lib
../../script/daby_create.pl model DB DBIC::Schema Daby::Schema create=static components=TimeStamp,PassphraseColumn dbi:mysql:daby daby daby
