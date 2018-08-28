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

ActiveRecord::Schema.define(version: 20180503121127) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "calibrations", force: :cascade do |t|
    t.decimal  "amount"
    t.text     "remarks"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "pump_nozzle_id"
    t.integer  "shift_inventory_update_id"
    t.index ["pump_nozzle_id"], name: "index_calibrations_on_pump_nozzle_id", using: :btree
    t.index ["shift_inventory_update_id"], name: "index_calibrations_on_shift_inventory_update_id", using: :btree
  end

  create_table "deliveries", force: :cascade do |t|
    t.string   "delivery_type"
    t.string   "sales_order_num"
    t.string   "received_by"
    t.time     "time_received"
    t.string   "invoice_num"
    t.decimal  "amount"
    t.text     "remarks"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "shift_inventory_update_id"
    t.index ["shift_inventory_update_id"], name: "index_deliveries_on_shift_inventory_update_id", using: :btree
  end

  create_table "dipstick_measurements", force: :cascade do |t|
    t.decimal  "converted_vol"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "tank_id"
    t.integer  "shift_inventory_update_id"
    t.decimal  "beginning_amt"
    t.decimal  "deliveries"
    t.decimal  "dispensed"
    t.decimal  "ending_amt"
    t.index ["shift_inventory_update_id"], name: "index_dipstick_measurements_on_shift_inventory_update_id", using: :btree
    t.index ["tank_id"], name: "index_dipstick_measurements_on_tank_id", using: :btree
  end

  create_table "fuel_sales", force: :cascade do |t|
    t.decimal  "dispensed"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "shift_inventory_update_id"
    t.integer  "tank_id"
    t.index ["shift_inventory_update_id"], name: "index_fuel_sales_on_shift_inventory_update_id", using: :btree
    t.index ["tank_id"], name: "index_fuel_sales_on_tank_id", using: :btree
  end

  create_table "non_fuel_sales", force: :cascade do |t|
    t.integer  "qty_sold"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "product_id"
    t.integer  "shift_inventory_update_id"
    t.index ["product_id"], name: "index_non_fuel_sales_on_product_id", using: :btree
    t.index ["shift_inventory_update_id"], name: "index_non_fuel_sales_on_shift_inventory_update_id", using: :btree
  end

  create_table "price_updates", force: :cascade do |t|
    t.text     "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_deliveries", force: :cascade do |t|
    t.decimal  "qty_delivered"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "product_id"
    t.integer  "delivery_id"
    t.integer  "tank_id"
    t.index ["delivery_id"], name: "index_product_deliveries_on_delivery_id", using: :btree
    t.index ["product_id"], name: "index_product_deliveries_on_product_id", using: :btree
    t.index ["tank_id"], name: "index_product_deliveries_on_tank_id", using: :btree
  end

  create_table "product_price_updates", force: :cascade do |t|
    t.date     "effective_on"
    t.decimal  "new_price"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "price_update_id"
    t.integer  "product_id"
    t.index ["price_update_id"], name: "index_product_price_updates_on_price_update_id", using: :btree
    t.index ["product_id"], name: "index_product_price_updates_on_product_id", using: :btree
  end

  create_table "products", force: :cascade do |t|
    t.string   "type"
    t.string   "name"
    t.text     "description"
    t.string   "symbols",                     array: true
    t.string   "ref_color"
    t.string   "classification"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "pump_meter_readings", force: :cascade do |t|
    t.decimal  "ending_bal"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "pump_nozzle_id"
    t.integer  "shift_inventory_update_id"
    t.decimal  "beginning_bal"
    t.decimal  "calibration"
    t.decimal  "dispensed"
    t.index ["pump_nozzle_id"], name: "index_pump_meter_readings_on_pump_nozzle_id", using: :btree
    t.index ["shift_inventory_update_id"], name: "index_pump_meter_readings_on_shift_inventory_update_id", using: :btree
  end

  create_table "pump_nozzles", force: :cascade do |t|
    t.integer  "pump_island_num"
    t.integer  "loading_point_num"
    t.integer  "nozzle_num"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "tank_id"
    t.index ["tank_id"], name: "index_pump_nozzles_on_tank_id", using: :btree
  end

  create_table "pump_reconciliation_totals", force: :cascade do |t|
    t.decimal  "ending_bal"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "product_id"
    t.integer  "shift_inventory_update_id"
    t.decimal  "beginning_bal"
    t.decimal  "calibration"
    t.decimal  "dispensed"
    t.index ["product_id"], name: "index_pump_reconciliation_totals_on_product_id", using: :btree
    t.index ["shift_inventory_update_id"], name: "index_pump_reconciliation_totals_on_shift_inventory_update_id", using: :btree
  end

  create_table "shift_inventory_updates", force: :cascade do |t|
    t.date     "date"
    t.integer  "shift"
    t.text     "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_shift_inventory_updates_on_date", using: :btree
    t.index ["shift"], name: "index_shift_inventory_updates_on_shift", using: :btree
  end

  create_table "tanks", force: :cascade do |t|
    t.integer  "tank_num"
    t.decimal  "capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "product_id"
    t.index ["product_id"], name: "index_tanks_on_product_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "username"
    t.string   "name"
    t.string   "position"
    t.string   "account_type"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["username"], name: "index_users_on_username", unique: true, using: :btree
  end

  add_foreign_key "calibrations", "pump_nozzles"
  add_foreign_key "calibrations", "shift_inventory_updates"
  add_foreign_key "deliveries", "shift_inventory_updates"
  add_foreign_key "dipstick_measurements", "shift_inventory_updates"
  add_foreign_key "dipstick_measurements", "tanks"
  add_foreign_key "fuel_sales", "shift_inventory_updates"
  add_foreign_key "fuel_sales", "tanks"
  add_foreign_key "non_fuel_sales", "products"
  add_foreign_key "non_fuel_sales", "shift_inventory_updates"
  add_foreign_key "product_deliveries", "deliveries"
  add_foreign_key "product_deliveries", "products"
  add_foreign_key "product_deliveries", "tanks"
  add_foreign_key "product_price_updates", "price_updates"
  add_foreign_key "product_price_updates", "products"
  add_foreign_key "pump_meter_readings", "pump_nozzles"
  add_foreign_key "pump_meter_readings", "shift_inventory_updates"
  add_foreign_key "pump_nozzles", "tanks"
  add_foreign_key "pump_reconciliation_totals", "products"
  add_foreign_key "pump_reconciliation_totals", "shift_inventory_updates"
  add_foreign_key "tanks", "products"
end
