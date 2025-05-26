# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_23_180847) do
  create_table "core_profiles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "employee_id"
    t.string "address"
    t.float "salary"
    t.integer "hours_per_week"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_core_profiles_on_employee_id"
  end

  create_table "dependants", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "insurance_profile_id"
    t.string "name"
    t.date "date_of_birth"
    t.string "relation"
    t.boolean "has_disability"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["insurance_profile_id"], name: "index_dependants_on_insurance_profile_id"
  end

  create_table "divisions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.bigint "employer_id", null: false
    t.bigint "policy_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employer_id"], name: "index_divisions_on_employer_id"
    t.index ["policy_id"], name: "index_divisions_on_policy_id"
  end

  create_table "employees", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "sex"
    t.date "date_of_birth"
    t.bigint "employer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employer_id"], name: "index_employees_on_employer_id"
  end

  create_table "employers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "contact_id"
    t.index ["contact_id"], name: "index_employers_on_contact_id"
  end

  create_table "insurance_profiles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.bigint "division_id", null: false
    t.boolean "life"
    t.string "health"
    t.string "dental"
    t.boolean "smoker"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["division_id"], name: "index_insurance_profiles_on_division_id"
    t.index ["employee_id"], name: "index_insurance_profiles_on_employee_id"
  end

  create_table "policies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.bigint "employer_id", null: false
    t.string "number", null: false
    t.float "life"
    t.float "health_single"
    t.float "health_family"
    t.float "dental_single"
    t.float "dental_family"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employer_id"], name: "index_policies_on_employer_id"
    t.index ["provider_id"], name: "index_policies_on_provider_id"
  end

  create_table "providers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "user_profiles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "sex"
    t.date "date_of_birth"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
  end

  create_table "user_roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["token"], name: "index_users_on_token", unique: true
  end

  add_foreign_key "divisions", "employers"
  add_foreign_key "divisions", "policies"
  add_foreign_key "employees", "employers"
  add_foreign_key "employers", "employees", column: "contact_id"
  add_foreign_key "insurance_profiles", "divisions"
  add_foreign_key "insurance_profiles", "employees"
  add_foreign_key "policies", "employers"
  add_foreign_key "policies", "providers"
  add_foreign_key "user_profiles", "users"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
end
