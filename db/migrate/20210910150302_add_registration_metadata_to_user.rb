# frozen_string_literal: true

class AddRegistrationMetadataToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :registration_metadata, :jsonb
  end
end
