puts "Adding Admin user..."

  User.find_or_create_by!(name: "Admin") do |u|
    u.name = "Admin"
    u.email = "admin@admin.com"
    u.password = "password"
    u.password_confirmation = "password"
    u.remember_me = false
    u.admin = true
  end
 