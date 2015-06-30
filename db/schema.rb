# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150630040055) do

  create_table "agents", force: :cascade do |t|
    t.string   "username",             limit: 11,  null: false
    t.string   "password",             limit: 255
    t.string   "auth_key",             limit: 200
    t.string   "password_reset_token", limit: 200
    t.string   "name",                 limit: 200, null: false
    t.integer  "province_id",          limit: 4,   null: false
    t.integer  "city_id",              limit: 4,   null: false
    t.integer  "district_id",          limit: 4,   null: false
    t.string   "address",              limit: 200, null: false
    t.string   "email",                limit: 200, null: false
    t.string   "phone",                limit: 20,  null: false
    t.integer  "status",               limit: 1,   null: false
    t.integer  "del",                  limit: 1,   null: false
    t.datetime "create_time"
  end

  add_index "agents", ["id"], name: "id_UNIQUE", unique: true, using: :btree
  add_index "agents", ["username"], name: "username_UNIQUE", unique: true, using: :btree

  create_table "appointment_logs", force: :cascade do |t|
    t.integer  "appointment_id", limit: 4
    t.integer  "user_id",        limit: 4
    t.integer  "operator_id",    limit: 4
    t.integer  "operator_type",  limit: 1
    t.text     "content",        limit: 65535
    t.integer  "type",           limit: 1
    t.string   "url",            limit: 120
    t.datetime "create_time"
  end

  add_index "appointment_logs", ["appointment_id"], name: "appointments_id_idx", using: :btree

  create_table "appointments", force: :cascade do |t|
    t.string   "appointment_number",   limit: 14
    t.integer  "project_id",           limit: 4
    t.integer  "user_id",              limit: 4
    t.string   "project_name",         limit: 120
    t.string   "masseuses_job_number", limit: 120
    t.integer  "type",                 limit: 1
    t.string   "member_tel",           limit: 20
    t.string   "member_username",      limit: 120, null: false
    t.integer  "staff_id",             limit: 4
    t.integer  "status",               limit: 1
    t.datetime "service_time"
    t.datetime "create_time"
  end

  add_index "appointments", ["appointment_number"], name: "appointment_number_UNIQUE", unique: true, using: :btree

  create_table "articles", force: :cascade do |t|
    t.integer  "sangna_config_id",   limit: 4
    t.integer  "forever_meida_id",   limit: 4
    t.string   "title",              limit: 255
    t.string   "author",             limit: 255
    t.string   "digest",             limit: 255
    t.boolean  "show_cover_pic",     limit: 1
    t.string   "content",            limit: 255
    t.string   "content_source_url", limit: 255
    t.string   "media_id",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coupon_orders", force: :cascade do |t|
    t.string   "prepay_id",          limit: 255
    t.string   "code_url",           limit: 255
    t.boolean  "is_subscribe",       limit: 1
    t.string   "trade_type",         limit: 255
    t.string   "transaction_id",     limit: 255
    t.string   "state",              limit: 255
    t.integer  "coupons_project_id", limit: 4
    t.integer  "coupons_rule_id",    limit: 4
    t.integer  "sangna_config_id",   limit: 4
    t.integer  "wechat_config_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coupons_records", force: :cascade do |t|
    t.string   "number",           limit: 14
    t.integer  "coupons_rules_id", limit: 4
    t.integer  "user_id",          limit: 4
    t.integer  "members_id",       limit: 4
    t.integer  "status",           limit: 1,  default: 1
    t.datetime "create_time"
  end

  add_index "coupons_records", ["id"], name: "id_UNIQUE", unique: true, using: :btree
  add_index "coupons_records", ["number"], name: "number_UNIQUE", unique: true, using: :btree

  create_table "coupons_rules", force: :cascade do |t|
    t.string   "name",                limit: 200
    t.integer  "face_value",          limit: 4
    t.integer  "price",               limit: 4
    t.datetime "validity_start_time"
    t.datetime "validity_end_time"
    t.datetime "effective_time"
    t.integer  "user_id",             limit: 4
    t.integer  "del",                 limit: 1,   default: 1
    t.integer  "status",              limit: 1,   default: 1, null: false
    t.string   "rule_info",           limit: 200
    t.datetime "create_time",                                 null: false
  end

  add_index "coupons_rules", ["name"], name: "name_UNIQUE", unique: true, using: :btree

  create_table "forever_media", force: :cascade do |t|
    t.string   "mtype",            limit: 255
    t.string   "url",              limit: 255
    t.string   "media_id",         limit: 255
    t.string   "info",             limit: 255
    t.integer  "sangna_config_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: :cascade do |t|
    t.string   "wcgroup_id",       limit: 255
    t.string   "name",             limit: 255
    t.integer  "sangna_config_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "masseuses_collects", force: :cascade do |t|
    t.integer  "per_user_id",          limit: 4
    t.integer  "per_user_masseuse_id", limit: 4
    t.integer  "member_id",            limit: 4
    t.integer  "del",                  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "masseuses_reviews", force: :cascade do |t|
    t.integer "user_id",                limit: 4
    t.integer "masseuses_id",           limit: 4
    t.integer "member_id",              limit: 4
    t.integer "best_project_id",        limit: 4
    t.string  "best_project_name",      limit: 200
    t.integer "star_level",             limit: 1
    t.integer "technique_evalution_id", limit: 4
    t.string  "technique_evalution",    limit: 200
    t.integer "del",                    limit: 1,   default: 1
  end

  add_index "masseuses_reviews", ["masseuses_id"], name: "masseuses_id_idx", using: :btree
  add_index "masseuses_reviews", ["member_id"], name: "member_id_idx", using: :btree
  add_index "masseuses_reviews", ["user_id"], name: "user_id_idx", using: :btree

  create_table "media", force: :cascade do |t|
    t.string   "mtype",            limit: 255
    t.text     "url",              limit: 65535
    t.string   "media_id",         limit: 255
    t.integer  "sangna_config_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.string   "username",    limit: 255
    t.string   "nick_name",   limit: 255, null: false
    t.string   "password",    limit: 255
    t.string   "email",       limit: 40,  null: false
    t.string   "img",         limit: 200, null: false
    t.integer  "sex",         limit: 1,   null: false
    t.integer  "del",         limit: 1
    t.datetime "create_time"
  end

  add_index "members", ["username"], name: "username_UNIQUE", unique: true, using: :btree

  create_table "menu_infos", force: :cascade do |t|
    t.integer  "menu_info_id", limit: 4
    t.string   "name",         limit: 255
    t.string   "m_type",       limit: 255
    t.integer  "level",        limit: 4
    t.integer  "order",        limit: 4
    t.string   "content",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_logs", force: :cascade do |t|
    t.string   "order_sn",         limit: 14
    t.integer  "order_project_id", limit: 4
    t.integer  "operator_id",      limit: 4
    t.integer  "operator_type",    limit: 1
    t.text     "content",          limit: 65535
    t.string   "url",              limit: 120
    t.datetime "createtime"
    t.integer  "user_id",          limit: 4
  end

  add_index "order_logs", ["order_sn"], name: "order_sn_idx", using: :btree
  add_index "order_logs", ["user_id"], name: "user_id_idx", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.string   "order_sn",        limit: 14
    t.string   "member_username", limit: 255
    t.decimal  "paid",                        precision: 10, scale: 2
    t.integer  "num",             limit: 4
    t.integer  "staff_id",        limit: 4
    t.integer  "status",          limit: 1,                            default: 1
    t.integer  "del",             limit: 1
    t.string   "create_time",     limit: 45
    t.datetime "paid_time",                                                        null: false
    t.datetime "reviews_time",                                                     null: false
  end

  add_index "orders", ["order_sn"], name: "order_sn_UNIQUE", unique: true, using: :btree

  create_table "orders_projects", force: :cascade do |t|
    t.string   "order_sn",     limit: 14
    t.string   "project_id",   limit: 200
    t.string   "project_name", limit: 120
    t.decimal  "price",                    precision: 10, scale: 2
    t.integer  "num",          limit: 4
    t.string   "member_hand",  limit: 120
    t.integer  "staff_id",     limit: 1
    t.datetime "status"
    t.datetime "service_time"
    t.datetime "reviews_time"
    t.datetime "create_time"
  end

  create_table "per_user_infos", force: :cascade do |t|
    t.integer "user_id",        limit: 4,     null: false
    t.string  "contact",        limit: 200,   null: false
    t.string  "contact_tel",    limit: 11,    null: false
    t.text    "info",           limit: 65535, null: false
    t.string  "main_img",       limit: 100,   null: false
    t.string  "license_number", limit: 15,    null: false
    t.string  "license_name",   limit: 200,   null: false
    t.string  "license_img",    limit: 200,   null: false
    t.string  "detail_img",     limit: 255,   null: false
  end

  create_table "per_user_masseuses", force: :cascade do |t|
    t.integer  "user_id",                limit: 4,     null: false
    t.string   "projects_id",            limit: 200
    t.datetime "entry_time"
    t.datetime "create_time"
    t.integer  "del",                    limit: 1
    t.string   "name",                   limit: 200
    t.string   "img",                    limit: 200
    t.string   "detail_img",             limit: 255
    t.integer  "province_id",            limit: 4
    t.integer  "district_id",            limit: 4
    t.integer  "city_id",                limit: 4
    t.string   "address",                limit: 255
    t.integer  "work_status",            limit: 1
    t.integer  "sex",                    limit: 1
    t.integer  "job_class_status",       limit: 1
    t.string   "job_number",             limit: 200
    t.string   "password",               limit: 120,   null: false
    t.integer  "collect_count",          limit: 4
    t.integer  "up_vote_count",          limit: 4
    t.string   "username",               limit: 255
    t.integer  "native_city_id",         limit: 4
    t.integer  "native_province_id",     limit: 4
    t.text     "info",                   limit: 65535
    t.string   "language",               limit: 20
    t.string   "identification_numbers", limit: 18
    t.integer  "status",                 limit: 1
    t.string   "client_id",              limit: 255
  end

  add_index "per_user_masseuses", ["username"], name: "login", unique: true, using: :btree

  create_table "per_user_projects", force: :cascade do |t|
    t.integer  "parent_id",        limit: 4
    t.integer  "user_id",          limit: 4
    t.string   "name",             limit: 200
    t.integer  "duration",         limit: 1
    t.decimal  "price",                          precision: 10, scale: 2
    t.integer  "add_duration",     limit: 1,                                          null: false
    t.decimal  "add_price",                      precision: 10, scale: 2,             null: false
    t.decimal  "favourable_price",               precision: 10, scale: 2,             null: false
    t.text     "info",             limit: 65535,                                      null: false
    t.text     "info_detail",      limit: 65535,                                      null: false
    t.integer  "status",           limit: 1,                              default: 1
    t.integer  "level",            limit: 1
    t.integer  "del",              limit: 1,                              default: 1
    t.datetime "create_time"
  end

  create_table "per_user_staffs", force: :cascade do |t|
    t.datetime "entry_time"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "del",                    limit: 1,                 null: false
    t.string   "name",                   limit: 200,               null: false
    t.string   "img",                    limit: 200,               null: false
    t.integer  "province_id",            limit: 4,                 null: false
    t.integer  "city_id",                limit: 4,                 null: false
    t.integer  "district_id",            limit: 4,                 null: false
    t.string   "address",                limit: 255,               null: false
    t.integer  "sex",                    limit: 1,                 null: false
    t.string   "job_number",             limit: 200,               null: false
    t.string   "username",               limit: 255
    t.integer  "native_city_id",         limit: 4,                 null: false
    t.integer  "native_province_id",     limit: 4,                 null: false
    t.text     "info",                   limit: 65535,             null: false
    t.string   "identification_numbers", limit: 18
    t.integer  "status",                 limit: 1,     default: 2, null: false
    t.string   "client_id",              limit: 255,               null: false
    t.string   "password_digest",        limit: 255
  end

  add_index "per_user_staffs", ["username"], name: "index_per_user_staffs_on_username", unique: true, using: :btree
  add_index "per_user_staffs", ["username"], name: "login", unique: true, using: :btree

  create_table "per_user_sys_menus", force: :cascade do |t|
    t.integer  "parent_id",   limit: 4
    t.string   "name",        limit: 255
    t.string   "url",         limit: 255
    t.integer  "level",       limit: 1
    t.integer  "son_count",   limit: 4
    t.string   "icon",        limit: 255, null: false
    t.integer  "status",      limit: 1
    t.integer  "del",         limit: 1
    t.datetime "create_time"
  end

  add_index "per_user_sys_menus", ["name"], name: "name_UNIQUE", unique: true, using: :btree

  create_table "per_users", force: :cascade do |t|
    t.string   "username",             limit: 11,  null: false
    t.string   "password",             limit: 120, null: false
    t.string   "auth_key",             limit: 32,  null: false
    t.string   "password_reset_token", limit: 32,  null: false
    t.string   "name",                 limit: 255, null: false
    t.integer  "province_id",          limit: 4,   null: false
    t.integer  "city_id",              limit: 4,   null: false
    t.integer  "district_id",          limit: 4,   null: false
    t.string   "address",              limit: 200, null: false
    t.string   "poll_code",            limit: 12,  null: false
    t.string   "poll_code_img",        limit: 200, null: false
    t.string   "phone",                limit: 10,  null: false
    t.string   "email",                limit: 40,  null: false
    t.integer  "status",               limit: 1,   null: false
    t.integer  "del",                  limit: 1,   null: false
    t.datetime "create_time",                      null: false
    t.integer  "agent_id",             limit: 4,   null: false
  end

  add_index "per_users", ["agent_id"], name: "agent_id_idx", using: :btree

  create_table "qrcodes", force: :cascade do |t|
    t.string   "expire_second",    limit: 255
    t.string   "action_name",      limit: 255
    t.string   "scene",            limit: 255
    t.string   "url",              limit: 255
    t.string   "ticket",           limit: 255
    t.text     "info",             limit: 65535
    t.integer  "sangna_config_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "receive_events", force: :cascade do |t|
    t.integer "receive_message_id", limit: 4
    t.string  "event",              limit: 255
    t.string  "event_key",          limit: 255
    t.string  "ticket",             limit: 255
  end

  create_table "receive_images", force: :cascade do |t|
    t.integer "receive_message_id", limit: 4
    t.string  "picurl",             limit: 255
    t.string  "media_id",           limit: 255
  end

  create_table "receive_links", force: :cascade do |t|
    t.integer "receive_message_id", limit: 4
    t.string  "title",              limit: 255
    t.text    "description",        limit: 65535
    t.string  "url",                limit: 255
  end

  create_table "receive_location_events", force: :cascade do |t|
    t.integer "receive_message_id", limit: 4
    t.float   "latitude",           limit: 24
    t.float   "longitude",          limit: 24
    t.float   "precision",          limit: 24
  end

  create_table "receive_messages", force: :cascade do |t|
    t.integer  "wechat_config_id", limit: 4
    t.integer  "sangna_config_id", limit: 4
    t.string   "msg_type",         limit: 255
    t.string   "msgid",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "receive_sentall_events", force: :cascade do |t|
    t.integer "receive_message_id", limit: 4
    t.integer "sentall_data_id",    limit: 4
    t.integer "total_count",        limit: 4
    t.integer "filter_count",       limit: 4
    t.integer "sent_count",         limit: 4
    t.integer "error_count",        limit: 4
    t.string  "state",              limit: 255
  end

  create_table "receive_templete_events", force: :cascade do |t|
    t.integer "receive_message_id", limit: 4
    t.integer "sent_templete_id",   limit: 4
    t.string  "status",             limit: 255
    t.text    "info",               limit: 65535
  end

  create_table "receive_texts", force: :cascade do |t|
    t.integer "receive_message_id", limit: 4
    t.text    "content",            limit: 65535
  end

  create_table "receive_videos", force: :cascade do |t|
    t.integer "receive_message_id", limit: 4
    t.string  "media_id",           limit: 255
    t.string  "thumb_media_id",     limit: 255
  end

  create_table "redbages", force: :cascade do |t|
    t.string   "nickname",         limit: 255
    t.string   "sendname",         limit: 255
    t.integer  "total_amount",     limit: 4
    t.integer  "min_value",        limit: 4
    t.integer  "max_value",        limit: 4
    t.integer  "total_num",        limit: 4
    t.string   "wishing",          limit: 255
    t.string   "action_name",      limit: 255
    t.string   "remark",           limit: 255
    t.string   "mch_billno",       limit: 255
    t.string   "logo_url",         limit: 255
    t.string   "share_content",    limit: 255
    t.string   "share_url",        limit: 255
    t.string   "share_imgurl",     limit: 255
    t.string   "send_listid",      limit: 255
    t.string   "sent_time",        limit: 255
    t.integer  "wechat_config_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "regions", primary_key: "regions_ID", force: :cascade do |t|
    t.string "regions_CODE",         limit: 100, null: false
    t.string "regions_NAME",         limit: 100, null: false
    t.float  "PARENT_ID",            limit: 53,  null: false
    t.float  "regions_LEVEL",        limit: 53,  null: false
    t.float  "regions_ORDER",        limit: 53,  null: false
    t.string "regions_NAME_EN",      limit: 100, null: false
    t.string "regions_SHORTNAME_EN", limit: 10,  null: false
  end

  create_table "reveive_locations", force: :cascade do |t|
    t.integer "receive_message_id", limit: 4
    t.float   "location_x",         limit: 24
    t.float   "location_y",         limit: 24
    t.float   "scale",              limit: 24
    t.string  "lable",              limit: 255
  end

  create_table "reveive_voices", force: :cascade do |t|
    t.integer "receive_message_id", limit: 4
    t.string  "media_id",           limit: 255
    t.string  "format",             limit: 255
  end

  create_table "sangna_configs", force: :cascade do |t|
    t.string   "code",          limit: 255
    t.string   "token",         limit: 255
    t.string   "refresh_token", limit: 255
    t.string   "appid",         limit: 255
    t.string   "func_info",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "per_user_id",   limit: 4
  end

  add_index "sangna_configs", ["per_user_id"], name: "index_sangna_configs_on_per_user_id", using: :btree

  create_table "sangna_infos", force: :cascade do |t|
    t.string   "nickname",         limit: 255
    t.string   "headimgurl",       limit: 255
    t.string   "service_type",     limit: 255
    t.string   "verify_type",      limit: 255
    t.string   "alias",            limit: 255
    t.string   "user_name",        limit: 255
    t.string   "qrcode_url",       limit: 255
    t.string   "location_report",  limit: 255
    t.string   "voice_recognize",  limit: 255
    t.string   "customer_service", limit: 255
    t.integer  "per_user_id",      limit: 4
    t.integer  "sangna_config_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sent_templetes", force: :cascade do |t|
    t.integer  "templete_message_id", limit: 4
    t.integer  "sangna_config_id",    limit: 4
    t.integer  "wechat_config_id",    limit: 4
    t.text     "date",                limit: 65535
    t.string   "url",                 limit: 255
    t.string   "msgid",               limit: 255
    t.string   "state",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sentall_data", force: :cascade do |t|
    t.integer  "sangna_config_id", limit: 4
    t.string   "type",             limit: 255
    t.string   "data",             limit: 255
    t.string   "info",             limit: 255
    t.string   "media_id",         limit: 255
    t.string   "state",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sentall_groups", force: :cascade do |t|
    t.integer  "group_id",         limit: 4
    t.integer  "sangna_config_id", limit: 4
    t.integer  "sentall_data_id",  limit: 4
    t.boolean  "is_to_all",        limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sentall_openids", force: :cascade do |t|
    t.integer  "sangna_config_id", limit: 4
    t.integer  "sentall_data_id",  limit: 4
    t.integer  "wechat_config_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "technique_evalutions", force: :cascade do |t|
    t.string  "name",   limit: 200
    t.integer "status", limit: 1,   default: 1
    t.integer "del",    limit: 1,   default: 1
  end

  add_index "technique_evalutions", ["name"], name: "name_UNIQUE", unique: true, using: :btree

  create_table "templete_messages", force: :cascade do |t|
    t.integer  "sangna_config_id",   limit: 4
    t.integer  "templete_number_id", limit: 4
    t.string   "tmplete_id",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "templete_numbers", force: :cascade do |t|
    t.string   "number",     limit: 255
    t.string   "industry",   limit: 255
    t.string   "topic",      limit: 255
    t.string   "fields",     limit: 255
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wechat_configs", force: :cascade do |t|
    t.string   "code",             limit: 255
    t.string   "token",            limit: 255
    t.string   "refresh_token",    limit: 255
    t.string   "openid",           limit: 255
    t.string   "scope",            limit: 255
    t.integer  "sangna_config_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "member_id",        limit: 4
  end

  add_index "wechat_configs", ["member_id"], name: "index_wechat_configs_on_member_id", using: :btree

  create_table "wechat_users", force: :cascade do |t|
    t.string   "nickname",         limit: 255
    t.boolean  "sex",              limit: 1
    t.string   "city",             limit: 255
    t.string   "country",          limit: 255
    t.string   "province",         limit: 255
    t.string   "language",         limit: 255
    t.string   "headimgurl",       limit: 255
    t.string   "subscribe_time",   limit: 255
    t.string   "remark",           limit: 255
    t.string   "unionid",          limit: 255
    t.integer  "group_id",         limit: 4
    t.integer  "member_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "wechat_config_id", limit: 4
  end

  add_foreign_key "appointment_logs", "appointments", name: "appointments_id"
  add_foreign_key "masseuses_reviews", "members", name: "member_id"
  add_foreign_key "masseuses_reviews", "per_user_masseuses", column: "masseuses_id", name: "masseuses_id"
  add_foreign_key "masseuses_reviews", "per_users", column: "user_id", name: "user_id"
end
