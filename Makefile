## Database setup adapted from an eliom-distillery project

# make db-init
# make db-start
# make db-create
# make db-psql

DB_PORT			       	   := 5433
DB_NAME                    := caqti_study

PSQL_DIR                   := local_db

DB_HOST                    := localhost

export PGHOST              := $(DB_HOST)
export PGDATABASE          := $(DB_NAME)
export PGPORT              := $(DB_PORT)


## If the LOCAL variable is set to yes, PSQL_LOG is the log directory.
PSQL_LOG                   := $(PSQL_DIR)/log

# Rule to get the pg_ctl binary.
ifeq ($(shell psql --version 2> /dev/null),)
$(error "PostgreSQL is not installed")
else
pg_ctl       = $(shell which pg_ctl || \
                       ls /usr/lib/postgresql/*/bin/pg_ctl | \
                       sort -nr -t / -k 5 | head -n 1)
endif

$(PSQL_DIR):
	-mkdir -p $@

db-init: $(PSQL_DIR)
	$(pg_ctl) initdb -o --encoding=UNICODE -D $(PSQL_DIR)
	echo unix_socket_directories = \'/tmp\' >> $(PSQL_DIR)/postgresql.conf

db-start:
	$(pg_ctl) -o "-p $(DB_PORT)" -D $(PSQL_DIR) -l $(PSQL_LOG) start

db-stop:
	$(pg_ctl) -D $(PSQL_DIR) -l $(PSQL_LOG) stop

db-status:
	$(pg_ctl) -D $(PSQL_DIR) -l $(PSQL_LOG) status

db-delete:
	$(pg_ctl) -D $(PSQL_DIR) -l $(PSQL_LOG) stop || true
	rm -f $(PSQL_LOG)
	rm -rf $(PSQL_DIR)

db-create:
	createdb --encoding UNICODE $(DB_NAME)

db-drop:
	dropdb $(DB_NAME)

db-psql:
	# Or just use:
	#   PGHOST=localhost PGDATABASE=caqti_study PGPORT=5433 psql
	psql $(DB_NAME)

# db-migrate:
# 	psql -d $(DB_NAME) --single-transaction -f ./db/init.sql

db-reset:
	$(MAKE) db-drop
	$(MAKE) db-create
#	$(MAKE) db-migrate
