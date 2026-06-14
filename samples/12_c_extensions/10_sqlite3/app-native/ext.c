#include <dragonruby.h>
#include <mruby/array.h>
#include <stdio.h>
#include <stdlib.h>
#include "sqlite3.h"

static drb_api_t *drb_api;
static sqlite3 *db;
static char *game_dir;

static mrb_value ffi_sqlite3_open(mrb_state *mrb, mrb_value self) {
  mrb_value relative_path;
  drb_api->mrb_get_args(mrb, "o", &relative_path);
  char path_buffer[1024];
  snprintf(path_buffer, sizeof(path_buffer), "%s/%s", game_dir, drb_api->mrb_str_to_cstr(mrb, relative_path));
  if (sqlite3_open(path_buffer, &db) != SQLITE_OK) {
    drb_api->mrb_raise(mrb, drb_api->drb_getruntime_error(mrb), "* ERROR - Failed to open database.");
  }
  return drb_api->mrb_nil_value();
}

static mrb_value ffi_sqlite3_exec(mrb_state *mrb, mrb_value self) {
  if (!db) {
    drb_api->mrb_raise(mrb, drb_api->drb_getruntime_error(mrb), "* ERROR - Call SQLite3.open before executing SQL commands.");
  }
  mrb_value r_sql_string;
  drb_api->mrb_get_args(mrb, "o", &r_sql_string);
  const char *sql_string = drb_api->mrb_str_to_cstr(mrb, r_sql_string);
  char *err_msg = NULL;
  if (sqlite3_exec(db, sql_string, NULL, NULL, &err_msg) != SQLITE_OK) {
    drb_api->mrb_raise(mrb, drb_api->drb_getruntime_error(mrb), err_msg);
    sqlite3_free(err_msg);
  }
  return drb_api->mrb_nil_value();
}

static mrb_value ffi_sqlite3_query_json(mrb_state *mrb, mrb_value self) {
  if (!db) {
    drb_api->mrb_raise(mrb, drb_api->drb_getruntime_error(mrb), "* ERROR - Call SQLite3.open before executing SQL commands.");
  }

  mrb_value r_sql_string;
  drb_api->mrb_get_args(mrb, "o", &r_sql_string);
  const char *sql_string = drb_api->mrb_str_to_cstr(mrb, r_sql_string);

  int rc;
  sqlite3_stmt *stmt;
  rc = sqlite3_prepare_v2(db, sql_string, -1, &stmt, NULL);
  if (rc != SQLITE_OK) {
    char *sql_error_message = (char *)sqlite3_errmsg(db);
    const char *error_message = "* ERROR - Failed to prepare SQL statement: %s";
    char full_error_message[1024];
    snprintf(full_error_message, sizeof(full_error_message), error_message, sql_error_message);
    drb_api->mrb_raise(mrb, drb_api->drb_getruntime_error(mrb), full_error_message);
    return drb_api->mrb_nil_value();
  }

  mrb_value results = drb_api->mrb_ary_new(mrb);
  while ((rc = sqlite3_step(stmt)) == SQLITE_ROW) {
    const char *row_text = (const char *)sqlite3_column_text(stmt, 0);
    drb_api->mrb_ary_push(mrb, results, drb_api->mrb_str_new_cstr(mrb, row_text ? row_text : "null"));
  }
  sqlite3_finalize(stmt);
  return results;
}

DRB_FFI_EXPORT
void drb_register_c_extensions_with_api(mrb_state *mrb, struct drb_api_t *api) {
  db = NULL;
  drb_api = api;
  struct RClass *base = mrb->object_class;
  struct RClass *rclass_sqlite3 = drb_api->mrb_define_class(mrb, "SQLite3", base);
  drb_api->mrb_define_class_method(mrb, rclass_sqlite3, "open", ffi_sqlite3_open, MRB_ARGS_REQ(1));
  drb_api->mrb_define_class_method(mrb, rclass_sqlite3, "exec", ffi_sqlite3_exec, MRB_ARGS_REQ(1));
  drb_api->mrb_define_class_method(mrb, rclass_sqlite3, "query_json", ffi_sqlite3_query_json, MRB_ARGS_REQ(1));

  mrb_value runtime_global_instance = drb_api->mrb_gv_get(mrb, drb_api->mrb_intern_cstr(mrb, "$gtk"));
  mrb_value r_game_dir = drb_api->mrb_funcall(mrb, runtime_global_instance, "get_game_dir", 0);
  game_dir = strdup(drb_api->mrb_str_to_cstr(mrb, r_game_dir));
}
