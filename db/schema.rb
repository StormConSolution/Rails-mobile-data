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

ActiveRecord::Schema.define(version: 20150921203154) do

  create_table "accounts", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "can_view_support_desk", default: false, null: false
    t.boolean  "can_view_ad_spend",     default: true,  null: false
    t.boolean  "can_view_sdks",         default: false, null: false
  end

  add_index "accounts", ["name"], name: "index_accounts_on_name", using: :btree

  create_table "android_app_categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "android_app_categories", ["name"], name: "index_android_app_categories_on_name", using: :btree

  create_table "android_app_categories_snapshots", force: true do |t|
    t.integer  "android_app_category_id"
    t.integer  "android_app_snapshot_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "kind"
  end

  add_index "android_app_categories_snapshots", ["android_app_category_id"], name: "index_android_app_category_id", using: :btree
  add_index "android_app_categories_snapshots", ["android_app_snapshot_id", "android_app_category_id"], name: "index_android_app_snapshot_id_category_id", using: :btree

  create_table "android_app_snapshot_exceptions", force: true do |t|
    t.integer  "android_app_snapshot_id"
    t.text     "name"
    t.text     "backtrace"
    t.integer  "try"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "android_app_snapshot_job_id"
  end

  add_index "android_app_snapshot_exceptions", ["android_app_snapshot_id"], name: "index_android_app_snapshot_exceptions_on_android_app_snapshot_id", using: :btree
  add_index "android_app_snapshot_exceptions", ["android_app_snapshot_job_id"], name: "index_android_app_snapshot_job_id", using: :btree

  create_table "android_app_snapshot_jobs", force: true do |t|
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "android_app_snapshots", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "price"
    t.integer  "size",                             limit: 8
    t.date     "updated"
    t.string   "seller_url"
    t.string   "version"
    t.date     "released"
    t.text     "description"
    t.integer  "android_app_id"
    t.integer  "google_plus_likes"
    t.boolean  "top_dev"
    t.boolean  "in_app_purchases"
    t.string   "required_android_version"
    t.string   "content_rating"
    t.string   "seller"
    t.decimal  "ratings_all_stars",                          precision: 3, scale: 2
    t.integer  "ratings_all_count"
    t.integer  "status"
    t.integer  "android_app_snapshot_job_id"
    t.integer  "in_app_purchase_min"
    t.integer  "in_app_purchase_max"
    t.integer  "downloads_min",                    limit: 8
    t.integer  "downloads_max",                    limit: 8
    t.string   "icon_url_300x300"
    t.string   "developer_google_play_identifier"
    t.boolean  "apk_access_forbidden"
  end

  add_index "android_app_snapshots", ["android_app_id", "name"], name: "index_android_app_id_and_name", using: :btree
  add_index "android_app_snapshots", ["android_app_id", "released"], name: "index_android_app_id_and_released", using: :btree
  add_index "android_app_snapshots", ["android_app_id"], name: "index_android_app_id", using: :btree
  add_index "android_app_snapshots", ["android_app_snapshot_job_id"], name: "index_android_app_snapshot_job_id", using: :btree
  add_index "android_app_snapshots", ["android_app_snapshot_job_id"], name: "index_android_app_snapshots_on_android_app_snapshot_job_id", using: :btree
  add_index "android_app_snapshots", ["apk_access_forbidden"], name: "index_apk_access_forbidden", using: :btree
  add_index "android_app_snapshots", ["developer_google_play_identifier"], name: "index_developer_google_play_identifier", using: :btree
  add_index "android_app_snapshots", ["name"], name: "index_name", using: :btree
  add_index "android_app_snapshots", ["released"], name: "index_released", using: :btree

  create_table "android_apps", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "app_identifier"
    t.integer  "app_id"
    t.integer  "newest_android_app_snapshot_id"
    t.integer  "user_base"
    t.integer  "mobile_priority"
    t.boolean  "taken_down"
    t.integer  "newest_apk_snapshot_id"
    t.boolean  "data_flag"
  end

  add_index "android_apps", ["app_identifier"], name: "index_android_apps_on_app_identifier", using: :btree
  add_index "android_apps", ["data_flag"], name: "index_android_apps_on_data_flag", using: :btree
  add_index "android_apps", ["mobile_priority"], name: "index_android_apps_on_mobile_priority", using: :btree
  add_index "android_apps", ["newest_android_app_snapshot_id"], name: "index_android_apps_on_newest_android_app_snapshot_id", using: :btree
  add_index "android_apps", ["newest_apk_snapshot_id"], name: "index_android_apps_on_newest_apk_snapshot_id", using: :btree
  add_index "android_apps", ["taken_down"], name: "index_android_apps_on_taken_down", using: :btree
  add_index "android_apps", ["user_base"], name: "index_android_apps_on_user_base", using: :btree

  create_table "android_apps_websites", force: true do |t|
    t.integer  "android_app_id"
    t.integer  "website_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "android_apps_websites", ["android_app_id"], name: "index_android_apps_websites_on_android_app_id", using: :btree
  add_index "android_apps_websites", ["website_id", "android_app_id"], name: "index_android_apps_websites_on_website_id_and_android_app_id", using: :btree

  create_table "android_developers", force: true do |t|
    t.string   "name"
    t.string   "identifier"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "android_developers", ["company_id"], name: "index_android_developers_on_company_id", using: :btree
  add_index "android_developers", ["identifier"], name: "index_android_developers_on_identifier", using: :btree
  add_index "android_developers", ["name"], name: "index_android_developers_on_name", using: :btree

  create_table "android_fb_ad_appearances", force: true do |t|
    t.string   "aws_assignment_identifier"
    t.string   "hit_identifier"
    t.integer  "m_turk_worker_id"
    t.integer  "android_app_id"
    t.string   "heroku_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "android_fb_ad_appearances", ["android_app_id"], name: "index_android_fb_ad_appearances_on_android_app_id", using: :btree
  add_index "android_fb_ad_appearances", ["aws_assignment_identifier"], name: "index_android_fb_ad_appearances_on_aws_assignment_identifier", using: :btree
  add_index "android_fb_ad_appearances", ["heroku_identifier"], name: "index_android_fb_ad_appearances_on_heroku_identifier", using: :btree
  add_index "android_fb_ad_appearances", ["hit_identifier"], name: "index_android_fb_ad_appearances_on_hit_identifier", using: :btree
  add_index "android_fb_ad_appearances", ["m_turk_worker_id"], name: "index_android_fb_ad_appearances_on_m_turk_worker_id", using: :btree

  create_table "android_packages", force: true do |t|
    t.string   "package_name"
    t.integer  "apk_snapshot_id"
    t.integer  "android_package_tag"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "identified"
    t.boolean  "not_useful"
  end

  add_index "android_packages", ["android_package_tag"], name: "index_android_packages_on_android_package_tag", using: :btree
  add_index "android_packages", ["apk_snapshot_id"], name: "index_android_packages_on_apk_snapshot_id", using: :btree
  add_index "android_packages", ["package_name"], name: "index_android_packages_on_package_name", using: :btree

  create_table "android_sdk_companies", force: true do |t|
    t.string   "name"
    t.string   "website"
    t.string   "favicon"
    t.boolean  "flagged",           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "open_source",       default: false
    t.integer  "parent_company_id"
  end

  add_index "android_sdk_companies", ["flagged"], name: "index_android_sdk_companies_on_flagged", using: :btree
  add_index "android_sdk_companies", ["name"], name: "index_android_sdk_companies_on_name", using: :btree
  add_index "android_sdk_companies", ["open_source"], name: "android_sdk_companies_open_source_index", using: :btree
  add_index "android_sdk_companies", ["parent_company_id"], name: "android_sdk_companies_parent_company_index", using: :btree
  add_index "android_sdk_companies", ["website"], name: "index_android_sdk_companies_on_website", using: :btree

  create_table "android_sdk_companies_android_apps", force: true do |t|
    t.integer  "android_sdk_company_id"
    t.integer  "android_app_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "android_sdk_companies_android_apps", ["android_app_id", "android_sdk_company_id"], name: "index_android_app_id_android_sdk_company_id", using: :btree
  add_index "android_sdk_companies_android_apps", ["android_sdk_company_id"], name: "android_sdk_company_id", using: :btree

  create_table "android_sdk_companies_apk_snapshots", force: true do |t|
    t.integer  "android_sdk_company_id"
    t.integer  "apk_snapshot_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "android_sdk_companies_apk_snapshots", ["android_sdk_company_id"], name: "android_sdk_company_id", using: :btree
  add_index "android_sdk_companies_apk_snapshots", ["apk_snapshot_id", "android_sdk_company_id"], name: "index_apk_snapshot_id_android_sdk_company_id", unique: true, using: :btree

  create_table "android_sdk_package_prefixes", force: true do |t|
    t.string  "prefix"
    t.integer "android_sdk_company_id"
  end

  add_index "android_sdk_package_prefixes", ["android_sdk_company_id"], name: "index_android_sdk_package_prefixes_on_android_sdk_company_id", using: :btree
  add_index "android_sdk_package_prefixes", ["prefix"], name: "index_android_sdk_package_prefixes_on_prefix", using: :btree

  create_table "android_sdk_packages", force: true do |t|
    t.string   "package_name"
    t.integer  "android_sdk_package_prefix_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "android_sdk_packages", ["android_sdk_package_prefix_id"], name: "index_android_sdk_packages_on_android_sdk_package_prefix_id", using: :btree
  add_index "android_sdk_packages", ["package_name"], name: "index_android_sdk_packages_on_package_name", using: :btree

  create_table "android_sdk_packages_apk_snapshots", force: true do |t|
    t.integer  "android_sdk_package_id"
    t.integer  "apk_snapshot_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "android_sdk_packages_apk_snapshots", ["android_sdk_package_id"], name: "android_sdk_package_id", using: :btree
  add_index "android_sdk_packages_apk_snapshots", ["apk_snapshot_id", "android_sdk_package_id"], name: "index_apk_snapshot_id_android_sdk_package_id", using: :btree

  create_table "api_keys", force: true do |t|
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  add_index "api_keys", ["account_id"], name: "index_api_keys_on_account_id", using: :btree
  add_index "api_keys", ["key"], name: "index_api_keys_on_key", using: :btree

  create_table "apk_files", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "apk_file_name"
    t.string   "apk_content_type"
    t.integer  "apk_file_size"
    t.datetime "apk_updated_at"
  end

  create_table "apk_snapshot_exceptions", force: true do |t|
    t.integer  "apk_snapshot_id"
    t.text     "name"
    t.text     "backtrace"
    t.integer  "try"
    t.integer  "apk_snapshot_job_id"
    t.integer  "google_account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status_code"
  end

  add_index "apk_snapshot_exceptions", ["apk_snapshot_id"], name: "index_apk_snapshot_exceptions_on_apk_snapshot_id", using: :btree
  add_index "apk_snapshot_exceptions", ["apk_snapshot_job_id"], name: "index_apk_snapshot_exceptions_on_apk_snapshot_job_id", using: :btree
  add_index "apk_snapshot_exceptions", ["google_account_id"], name: "index_apk_snapshot_exceptions_on_google_account_id", using: :btree
  add_index "apk_snapshot_exceptions", ["status_code"], name: "index_apk_status_code", using: :btree

  create_table "apk_snapshot_jobs", force: true do |t|
    t.text     "notes"
    t.boolean  "is_fucked"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "apk_snapshots", force: true do |t|
    t.string   "version"
    t.integer  "google_account_id"
    t.integer  "android_app_id"
    t.float    "download_time",       limit: 24
    t.float    "unpack_time",         limit: 24
    t.integer  "status"
    t.integer  "apk_snapshot_job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "try"
    t.text     "auth_token"
    t.integer  "micro_proxy_id"
    t.integer  "last_device"
    t.integer  "apk_file_id"
    t.integer  "scan_status"
  end

  add_index "apk_snapshots", ["android_app_id"], name: "index_apk_snapshots_on_android_app_id", using: :btree
  add_index "apk_snapshots", ["apk_file_id"], name: "index_apk_snapshots_on_apk_file_id", using: :btree
  add_index "apk_snapshots", ["apk_snapshot_job_id"], name: "index_apk_snapshots_on_apk_snapshot_job_id", using: :btree
  add_index "apk_snapshots", ["google_account_id"], name: "index_apk_snapshots_on_google_account_id", using: :btree
  add_index "apk_snapshots", ["last_device"], name: "index_apk_snapshots_on_last_device", using: :btree
  add_index "apk_snapshots", ["micro_proxy_id"], name: "index_apk_snapshots_on_micro_proxy_id", using: :btree
  add_index "apk_snapshots", ["scan_status"], name: "index_apk_snapshots_on_scan_status", using: :btree
  add_index "apk_snapshots", ["try"], name: "index_apk_snapshots_on_try", using: :btree

  create_table "app_stores", force: true do |t|
    t.string   "country_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "app_stores", ["country_code"], name: "index_app_stores_on_country_code", using: :btree

  create_table "app_stores_ios_apps", force: true do |t|
    t.integer  "app_store_id"
    t.integer  "ios_app_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "app_stores_ios_apps", ["app_store_id"], name: "index_app_stores_ios_apps_on_app_store_id", using: :btree
  add_index "app_stores_ios_apps", ["ios_app_id", "app_store_id"], name: "index_app_stores_ios_apps_on_ios_app_id_and_app_store_id", using: :btree

  create_table "apps", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.string   "name"
  end

  create_table "clearbit_contacts", force: true do |t|
    t.integer  "website_id"
    t.string   "clearbit_id"
    t.string   "given_name"
    t.string   "family_name"
    t.string   "full_name"
    t.string   "title"
    t.string   "email"
    t.string   "linkedin"
    t.date     "updated"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "clearbit_contacts", ["clearbit_id"], name: "index_clearbit_contacts_on_clearbit_id", using: :btree
  add_index "clearbit_contacts", ["website_id"], name: "index_clearbit_contacts_on_website_id", using: :btree

  create_table "companies", force: true do |t|
    t.string   "name"
    t.string   "website"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "fortune_1000_rank"
    t.string   "ceo_name"
    t.string   "street_address"
    t.string   "city"
    t.string   "zip_code"
    t.string   "state"
    t.integer  "employee_count"
    t.string   "industry"
    t.string   "type"
    t.integer  "funding"
    t.integer  "inc_5000_rank"
    t.string   "country"
    t.integer  "app_store_identifier"
    t.string   "google_play_identifier"
  end

  add_index "companies", ["app_store_identifier"], name: "index_app_store_identifier", using: :btree
  add_index "companies", ["fortune_1000_rank"], name: "index_companies_on_fortune_1000_rank", using: :btree
  add_index "companies", ["google_play_identifier"], name: "index_google_play_identifier", using: :btree
  add_index "companies", ["status"], name: "index_companies_on_status", using: :btree
  add_index "companies", ["website"], name: "index_companies_on_website", unique: true, using: :btree

  create_table "dupes", force: true do |t|
    t.string   "app_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "count"
  end

  add_index "dupes", ["app_identifier"], name: "index_dupes_on_app_identifier", using: :btree
  add_index "dupes", ["count"], name: "index_dupes_on_count", using: :btree

  create_table "epf_full_feeds", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "epf_full_feeds", ["name"], name: "index_epf_full_feeds_on_name", using: :btree

  create_table "google_accounts", force: true do |t|
    t.string   "email"
    t.string   "password"
    t.string   "android_identifier"
    t.integer  "proxy_id"
    t.boolean  "blocked"
    t.integer  "flags"
    t.datetime "last_used"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "in_use"
    t.integer  "device"
    t.integer  "scrape_type",        default: 0
  end

  add_index "google_accounts", ["blocked"], name: "index_google_accounts_on_blocked", using: :btree
  add_index "google_accounts", ["device"], name: "index_google_accounts_on_device", using: :btree
  add_index "google_accounts", ["flags"], name: "index_google_accounts_on_flags", using: :btree
  add_index "google_accounts", ["last_used"], name: "index_google_accounts_on_last_used", using: :btree
  add_index "google_accounts", ["proxy_id"], name: "index_google_accounts_on_proxy_id", using: :btree
  add_index "google_accounts", ["scrape_type"], name: "index_google_accounts_on_scrape_type", using: :btree

  create_table "installations", force: true do |t|
    t.integer  "company_id"
    t.integer  "service_id"
    t.integer  "scraped_result_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status"
    t.integer  "scrape_job_id"
  end

  add_index "installations", ["company_id", "created_at"], name: "index_installations_on_company_id_and_created_at", using: :btree
  add_index "installations", ["scrape_job_id"], name: "index_installations_on_scrape_job_id", using: :btree
  add_index "installations", ["scraped_result_id"], name: "index_installations_on_scraped_result_id", using: :btree
  add_index "installations", ["service_id", "created_at"], name: "index_installations_on_service_id_and_created_at", using: :btree
  add_index "installations", ["status", "created_at"], name: "index_installations_on_status_and_created_at", using: :btree

  create_table "ios_app_categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_app_categories", ["name"], name: "index_ios_app_categories_on_name", using: :btree

  create_table "ios_app_categories_snapshots", force: true do |t|
    t.integer  "ios_app_category_id"
    t.integer  "ios_app_snapshot_id"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_app_categories_snapshots", ["ios_app_category_id"], name: "index_ios_app_categories_snapshots_on_ios_app_category_id", using: :btree
  add_index "ios_app_categories_snapshots", ["ios_app_snapshot_id", "ios_app_category_id", "kind"], name: "index_ios_app_snapshot_id_category_id_kind", using: :btree
  add_index "ios_app_categories_snapshots", ["kind"], name: "index_ios_app_categories_snapshots_on_kind", using: :btree

  create_table "ios_app_download_snapshot_exceptions", force: true do |t|
    t.integer  "ios_app_download_snapshot_id"
    t.text     "name"
    t.text     "backtrace"
    t.integer  "try"
    t.integer  "ios_app_download_snapshot_job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_app_download_snapshot_exceptions", ["ios_app_download_snapshot_id"], name: "index_on_ios_app_download_snapshot_id", using: :btree
  add_index "ios_app_download_snapshot_exceptions", ["ios_app_download_snapshot_job_id"], name: "index_on_ios_app_download_snapshot_job_id", using: :btree

  create_table "ios_app_download_snapshot_jobs", force: true do |t|
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ios_app_download_snapshots", force: true do |t|
    t.integer  "downloads",                        limit: 8
    t.integer  "ios_app_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ios_app_download_snapshot_job_id"
    t.integer  "status"
  end

  add_index "ios_app_download_snapshots", ["ios_app_download_snapshot_job_id"], name: "index_on_ios_app_download_snapshot_job_id", using: :btree
  add_index "ios_app_download_snapshots", ["ios_app_id"], name: "index_ios_app_download_snapshots_on_ios_app_id", using: :btree
  add_index "ios_app_download_snapshots", ["status"], name: "index_ios_app_download_snapshots_on_status", using: :btree

  create_table "ios_app_epf_snapshots", force: true do |t|
    t.integer  "export_date",         limit: 8
    t.integer  "application_id"
    t.text     "title"
    t.string   "recommended_age"
    t.text     "artist_name"
    t.string   "seller_name"
    t.text     "company_url"
    t.text     "support_url"
    t.text     "view_url"
    t.text     "artwork_url_large"
    t.string   "artwork_url_small"
    t.date     "itunes_release_date"
    t.text     "copyright"
    t.text     "description"
    t.string   "version"
    t.string   "itunes_version"
    t.integer  "download_size",       limit: 8
    t.integer  "epf_full_feed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_app_epf_snapshots", ["application_id", "epf_full_feed_id"], name: "index_application_id_and_epf_full_feed_id", using: :btree
  add_index "ios_app_epf_snapshots", ["application_id"], name: "index_ios_app_epf_snapshots_on_application_id", using: :btree
  add_index "ios_app_epf_snapshots", ["artwork_url_small"], name: "index_ios_app_epf_snapshots_on_artwork_url_small", using: :btree
  add_index "ios_app_epf_snapshots", ["download_size"], name: "index_ios_app_epf_snapshots_on_download_size", using: :btree
  add_index "ios_app_epf_snapshots", ["epf_full_feed_id"], name: "index_ios_app_epf_snapshots_on_epf_full_feed_id", using: :btree
  add_index "ios_app_epf_snapshots", ["export_date"], name: "index_ios_app_epf_snapshots_on_export_date", using: :btree
  add_index "ios_app_epf_snapshots", ["itunes_release_date"], name: "index_ios_app_epf_snapshots_on_itunes_release_date", using: :btree
  add_index "ios_app_epf_snapshots", ["itunes_version"], name: "index_ios_app_epf_snapshots_on_itunes_version", using: :btree
  add_index "ios_app_epf_snapshots", ["recommended_age"], name: "index_ios_app_epf_snapshots_on_recommended_age", using: :btree
  add_index "ios_app_epf_snapshots", ["seller_name"], name: "index_ios_app_epf_snapshots_on_seller_name", using: :btree
  add_index "ios_app_epf_snapshots", ["version"], name: "index_ios_app_epf_snapshots_on_version", using: :btree

  create_table "ios_app_languages", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "ios_app_languages", ["name"], name: "index_ios_app_languages_on_name", using: :btree

  create_table "ios_app_snapshot_exceptions", force: true do |t|
    t.integer  "ios_app_snapshot_id"
    t.text     "name"
    t.text     "backtrace"
    t.integer  "try"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ios_app_snapshot_job_id"
  end

  add_index "ios_app_snapshot_exceptions", ["ios_app_snapshot_id"], name: "index_ios_app_snapshot_exceptions_on_ios_app_snapshot_id", using: :btree
  add_index "ios_app_snapshot_exceptions", ["ios_app_snapshot_job_id"], name: "index_ios_app_snapshot_job_id", using: :btree

  create_table "ios_app_snapshot_jobs", force: true do |t|
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ios_app_snapshots", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "price"
    t.integer  "size",                            limit: 8
    t.string   "seller_url"
    t.string   "support_url"
    t.string   "version"
    t.date     "released"
    t.string   "recommended_age"
    t.text     "description"
    t.integer  "ios_app_id"
    t.string   "required_ios_version"
    t.integer  "ios_app_snapshot_job_id"
    t.text     "release_notes"
    t.string   "seller"
    t.integer  "developer_app_store_identifier"
    t.decimal  "ratings_current_stars",                     precision: 3,  scale: 2
    t.integer  "ratings_current_count"
    t.decimal  "ratings_all_stars",                         precision: 3,  scale: 2
    t.integer  "ratings_all_count"
    t.boolean  "editors_choice"
    t.integer  "status"
    t.text     "exception_backtrace"
    t.text     "exception"
    t.string   "icon_url_350x350"
    t.string   "icon_url_175x175"
    t.decimal  "ratings_per_day_current_release",           precision: 10, scale: 2
    t.date     "first_released"
    t.string   "by"
    t.string   "copywright"
    t.string   "seller_url_text"
    t.string   "support_url_text"
  end

  add_index "ios_app_snapshots", ["developer_app_store_identifier"], name: "index_ios_app_snapshots_on_developer_app_store_identifier", using: :btree
  add_index "ios_app_snapshots", ["first_released"], name: "index_ios_app_snapshots_on_first_released", using: :btree
  add_index "ios_app_snapshots", ["ios_app_id", "name"], name: "index_ios_app_snapshots_on_ios_app_id_and_name", using: :btree
  add_index "ios_app_snapshots", ["ios_app_id", "released"], name: "index_ios_app_snapshots_on_ios_app_id_and_released", using: :btree
  add_index "ios_app_snapshots", ["ios_app_id"], name: "index_ios_app_snapshots_on_ios_app_id", using: :btree
  add_index "ios_app_snapshots", ["ios_app_snapshot_job_id"], name: "index_ios_app_snapshots_on_ios_app_snapshot_job_id", using: :btree
  add_index "ios_app_snapshots", ["name"], name: "index_ios_app_snapshots_on_name", using: :btree
  add_index "ios_app_snapshots", ["released"], name: "index_ios_app_snapshots_on_released", using: :btree
  add_index "ios_app_snapshots", ["support_url"], name: "index_ios_app_snapshots_on_support_url", using: :btree

  create_table "ios_app_snapshots_languages", force: true do |t|
    t.integer  "ios_app_snapshot_id"
    t.integer  "ios_app_language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_app_snapshots_languages", ["ios_app_language_id"], name: "index_ios_app_snapshots_languages_on_ios_app_language_id", using: :btree
  add_index "ios_app_snapshots_languages", ["ios_app_snapshot_id", "ios_app_language_id"], name: "index_ios_app_snapshot_id_language_id", using: :btree

  create_table "ios_apps", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "app_identifier"
    t.integer  "app_id"
    t.integer  "newest_ios_app_snapshot_id"
    t.integer  "user_base"
    t.integer  "mobile_priority"
    t.date     "released"
  end

  add_index "ios_apps", ["app_identifier"], name: "index_ios_apps_on_app_identifier", using: :btree
  add_index "ios_apps", ["mobile_priority"], name: "index_ios_apps_on_mobile_priority", using: :btree
  add_index "ios_apps", ["newest_ios_app_snapshot_id"], name: "index_ios_apps_on_newest_ios_app_snapshot_id", using: :btree
  add_index "ios_apps", ["released"], name: "index_ios_apps_on_released", using: :btree
  add_index "ios_apps", ["user_base"], name: "index_ios_apps_on_user_base", using: :btree

  create_table "ios_apps_websites", force: true do |t|
    t.integer  "ios_app_id"
    t.integer  "website_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_apps_websites", ["ios_app_id"], name: "index_ios_apps_websites_on_ios_app_id", using: :btree
  add_index "ios_apps_websites", ["website_id", "ios_app_id"], name: "index_website_id_and_ios_app_id", using: :btree

  create_table "ios_developers", force: true do |t|
    t.string   "name"
    t.string   "identifier"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_developers", ["company_id"], name: "index_ios_developers_on_company_id", using: :btree
  add_index "ios_developers", ["identifier"], name: "index_ios_developers_on_identifier", using: :btree
  add_index "ios_developers", ["name"], name: "index_ios_developers_on_name", using: :btree

  create_table "ios_fb_ad_appearances", force: true do |t|
    t.string   "aws_assignment_identifier"
    t.string   "hit_identifier"
    t.integer  "heroku_identifier"
    t.integer  "m_turk_worker_id"
    t.integer  "ios_app_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_fb_ad_appearances", ["aws_assignment_identifier"], name: "index_ios_fb_ad_appearances_on_aws_assignment_identifier", using: :btree
  add_index "ios_fb_ad_appearances", ["hit_identifier"], name: "index_ios_fb_ad_appearances_on_hit_identifier", using: :btree
  add_index "ios_fb_ad_appearances", ["ios_app_id"], name: "index_ios_fb_ad_appearances_on_ios_app_id", using: :btree
  add_index "ios_fb_ad_appearances", ["m_turk_worker_id"], name: "index_ios_fb_ad_appearances_on_m_turk_worker_id", using: :btree

  create_table "ios_in_app_purchases", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "ios_app_snapshot_id"
    t.integer  "price"
  end

  create_table "jp_ios_app_snapshots", force: true do |t|
    t.string   "name"
    t.integer  "price"
    t.integer  "size",                           limit: 8
    t.string   "seller_url"
    t.string   "support_url"
    t.string   "version"
    t.string   "recommended_age"
    t.text     "description"
    t.integer  "ios_app_id"
    t.string   "required_ios_version"
    t.text     "release_notes"
    t.string   "seller"
    t.integer  "developer_app_store_identifier"
    t.decimal  "ratings_current_stars",                    precision: 3, scale: 2
    t.integer  "ratings_current_count"
    t.decimal  "ratings_all_stars",                        precision: 3, scale: 2
    t.integer  "ratings_all_count"
    t.integer  "status"
    t.integer  "job_identifier"
    t.string   "category"
    t.integer  "user_base"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "business_country_code"
    t.string   "business_country"
  end

  add_index "jp_ios_app_snapshots", ["business_country"], name: "index_jp_ios_app_snapshots_on_business_country", using: :btree
  add_index "jp_ios_app_snapshots", ["business_country_code"], name: "index_jp_ios_app_snapshots_on_business_country_code", using: :btree
  add_index "jp_ios_app_snapshots", ["developer_app_store_identifier"], name: "index_jp_ios_app_snapshots_on_developer_app_store_identifier", using: :btree
  add_index "jp_ios_app_snapshots", ["ios_app_id"], name: "index_jp_ios_app_snapshots_on_ios_app_id", using: :btree
  add_index "jp_ios_app_snapshots", ["job_identifier"], name: "index_jp_ios_app_snapshots_on_job_identifier", using: :btree
  add_index "jp_ios_app_snapshots", ["name"], name: "index_jp_ios_app_snapshots_on_name", using: :btree
  add_index "jp_ios_app_snapshots", ["user_base"], name: "index_jp_ios_app_snapshots_on_user_base", using: :btree

  create_table "known_ios_words", force: true do |t|
    t.string "word"
  end

  add_index "known_ios_words", ["word"], name: "index_known_ios_words_on_word", using: :btree

  create_table "listables_lists", force: true do |t|
    t.integer  "listable_id"
    t.integer  "list_id"
    t.string   "listable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "listables_lists", ["list_id"], name: "index_listables_lists_on_list_id", using: :btree
  add_index "listables_lists", ["listable_id", "list_id", "listable_type"], name: "index_listable_id_list_id_listable_type", using: :btree
  add_index "listables_lists", ["listable_type"], name: "index_listables_lists_on_listable_type", using: :btree

  create_table "lists", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lists_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "list_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "lists_users", ["list_id", "user_id"], name: "index_lists_users_on_list_id_and_user_id", using: :btree
  add_index "lists_users", ["user_id"], name: "index_lists_users_on_user_id", using: :btree

  create_table "m_turk_workers", force: true do |t|
    t.string   "aws_identifier"
    t.integer  "age"
    t.string   "gender"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "iphone"
    t.string   "ios_version"
    t.string   "heroku_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "m_turk_workers", ["aws_identifier"], name: "index_m_turk_workers_on_aws_identifier", using: :btree

  create_table "matchers", force: true do |t|
    t.integer  "service_id"
    t.integer  "match_type"
    t.text     "match_string"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "matchers", ["service_id"], name: "index_matchers_on_service_id", using: :btree

  create_table "micro_proxies", force: true do |t|
    t.boolean  "active"
    t.string   "public_ip"
    t.string   "private_ip"
    t.date     "last_used"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "flags"
  end

  add_index "micro_proxies", ["active"], name: "index_micro_proxies_on_active", using: :btree
  add_index "micro_proxies", ["flags"], name: "index_micro_proxies_on_flags", using: :btree
  add_index "micro_proxies", ["last_used"], name: "index_micro_proxies_on_last_used", using: :btree
  add_index "micro_proxies", ["private_ip"], name: "index_micro_proxies_on_private_ip", using: :btree
  add_index "micro_proxies", ["public_ip"], name: "index_micro_proxies_on_public_ip", using: :btree

  create_table "oauth_users", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "oauth_token"
    t.string   "refresh_token"
    t.string   "instance_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
  end

  create_table "proxies", force: true do |t|
    t.boolean  "active"
    t.string   "public_ip"
    t.string   "private_ip"
    t.datetime "last_used"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "proxies", ["active"], name: "index_proxies_on_active", using: :btree
  add_index "proxies", ["last_used"], name: "index_proxies_on_last_used", using: :btree
  add_index "proxies", ["private_ip"], name: "index_proxies_on_private_ip", using: :btree

  create_table "scrape_jobs", force: true do |t|
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scraped_results", force: true do |t|
    t.integer  "company_id"
    t.string   "url"
    t.text     "raw_html"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "scrape_job_id"
  end

  add_index "scraped_results", ["company_id"], name: "index_scraped_results_on_company_id", using: :btree
  add_index "scraped_results", ["scrape_job_id"], name: "index_scraped_results_on_scrape_job_id", using: :btree

  create_table "sdk_companies", force: true do |t|
    t.string   "name"
    t.string   "website"
    t.string   "funding"
    t.string   "phone"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.text     "description"
    t.integer  "year_founded"
    t.string   "bloomberg_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "favicon"
    t.string   "alias_name"
    t.string   "alias_website"
    t.boolean  "flagged",       default: false
  end

  add_index "sdk_companies", ["alias_name"], name: "index_sdk_companies_on_alias_name", using: :btree
  add_index "sdk_companies", ["alias_website"], name: "index_sdk_companies_on_alias_website", using: :btree
  add_index "sdk_companies", ["bloomberg_id"], name: "index_sdk_companies_on_bloomberg_id", using: :btree
  add_index "sdk_companies", ["country"], name: "index_sdk_companies_on_country", using: :btree
  add_index "sdk_companies", ["flagged"], name: "index_sdk_companies_on_flagged", using: :btree
  add_index "sdk_companies", ["funding"], name: "index_sdk_companies_on_funding", using: :btree
  add_index "sdk_companies", ["name"], name: "index_sdk_companies_on_name", using: :btree
  add_index "sdk_companies", ["state"], name: "index_sdk_companies_on_state", using: :btree
  add_index "sdk_companies", ["website"], name: "index_sdk_companies_on_website", using: :btree
  add_index "sdk_companies", ["year_founded"], name: "index_sdk_companies_on_year_founded", using: :btree
  add_index "sdk_companies", ["zip"], name: "index_sdk_companies_on_zip", using: :btree

  create_table "sdk_packages", force: true do |t|
    t.string   "package_name"
    t.integer  "sdk_company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sdk_packages", ["package_name"], name: "index_sdk_packages_on_package_name", using: :btree
  add_index "sdk_packages", ["sdk_company_id"], name: "index_sdk_packages_on_sdk_company_id", using: :btree

  create_table "services", force: true do |t|
    t.string   "name"
    t.string   "website"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sidekiq_testers", force: true do |t|
    t.string   "test_string"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "super_proxies", force: true do |t|
    t.boolean  "active"
    t.string   "public_ip"
    t.string   "private_ip"
    t.integer  "port"
    t.datetime "last_used"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "super_proxies", ["active"], name: "index_super_proxies_on_active", using: :btree
  add_index "super_proxies", ["last_used"], name: "index_super_proxies_on_last_used", using: :btree
  add_index "super_proxies", ["port", "private_ip"], name: "index_super_proxies_on_port_and_private_ip", using: :btree
  add_index "super_proxies", ["port"], name: "index_super_proxies_on_port", using: :btree
  add_index "super_proxies", ["private_ip"], name: "index_super_proxies_on_private_ip", using: :btree
  add_index "super_proxies", ["public_ip"], name: "index_super_proxies_on_public_ip", using: :btree

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.boolean  "tos_accepted",    default: false
  end

  add_index "users", ["account_id"], name: "index_users_on_account_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["tos_accepted"], name: "index_users_on_tos_accepted", using: :btree

  create_table "websites", force: true do |t|
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "kind"
    t.integer  "company_id"
    t.integer  "ios_app_id"
  end

  add_index "websites", ["company_id"], name: "index_websites_on_company_id", using: :btree
  add_index "websites", ["id", "company_id"], name: "index_websites_on_id_and_company_id", using: :btree
  add_index "websites", ["ios_app_id"], name: "index_websites_on_ios_app_id", using: :btree
  add_index "websites", ["kind"], name: "index_websites_on_kind", using: :btree
  add_index "websites", ["url"], name: "index_websites_on_url", using: :btree

  create_table "word_occurences", force: true do |t|
    t.string   "word"
    t.integer  "good"
    t.integer  "bad"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "word_occurences", ["word"], name: "index_word_occurences_on_word", using: :btree

end
