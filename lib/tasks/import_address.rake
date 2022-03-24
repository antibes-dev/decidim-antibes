# frozen_string_literal: true

namespace :decidim do
  desc "Place a csv file containing addresses in tmp folder with the name 'import_address.csv', file must have headers: id, email, bal, address."
  task import_address: :environment do
    file = File.read("tmp/import_address.csv")
    csv_array = CSV.parse(file, headers: true)
                   .to_a
                   .drop(1)
                   .map { |row| row.first.split(";") }

    csv_array.each do |_id, email, bal, address|
      user = Decidim::User.find_by(email: email)
      next if user.nil?

      old_registration_metadata = user.registration_metadata.dup || {}

      # rubocop:disable Rails/SkipsModelValidations
      user.update_column(:registration_metadata, old_registration_metadata.merge(
                                                   address: address,
                                                   address_id: bal
                                                 ))
      # rubocop:enable Rails/SkipsModelValidations

      puts("Updated user #{user.email} with address #{address}, previous address: #{old_registration_metadata["address"]}")
    end
  end
end
