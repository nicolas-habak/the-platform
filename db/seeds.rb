puts "Seeding database..."

user = FactoryBot.create(:admin_user, email: "admin@example.com", password: "password123")
puts "Added admin #{user.email}"
10.times do
  user = FactoryBot.create(:actuary_user)
  puts "Added actuary #{user.email}"
end

3.times do
  provider = FactoryBot.create(:provider)
  puts "Added provider #{provider.name}"
end

3.times do
  employer = FactoryBot.create(:employer)
  puts "Added employer #{employer.name}"

  past_policy = FactoryBot.create(:policy, :past_policy, employer: employer, number: "POL-1234")
  present_policy_life = FactoryBot.create(:policy, :present_policy, employer: employer, number: "POL-LIFE")
  present_policy_hd = FactoryBot.create(:policy, :present_policy, employer: employer, number: "POL-HD")
  future_policy = FactoryBot.create(:policy, :future_policy, employer: employer, number: "POL-ABCD")

  3.times do |i|
    division = FactoryBot.create(:division, name: "Division #{i + 1}", code: "DIV-#{i + 1}", employer: employer)
    division.policies << [ present_policy_life, present_policy_hd ]
    puts "Added division #{division.code}"
  end


  3.times do
    employee = FactoryBot.create(:employee, employer: employer) # Ensure correct employer association
    puts "Added employee #{employee.first_name} #{employee.last_name}"

    core_profile = FactoryBot.create(:core_profile, employee: employee, start_date: 1.year.ago, end_date: nil) # Link core_profile to employee
    puts "Added employee #{core_profile.start_date}"

    insurance_profile = FactoryBot.create(:insurance_profile, employee: employee, start_date: 1.year.ago, end_date: nil, division: employer.divisions.first)
    puts "Added employee #{insurance_profile.start_date}"

    dependant = FactoryBot.create(:dependant, insurance_profile: insurance_profile)
    puts "Added dependant #{dependant.name}"
  end
end

puts "Seeding complete!"
