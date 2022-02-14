# frozen_string_literal: true

require "uri"
require "net/http"

module Decidim
  # A form object used to handle user registrations
  class RegistrationForm < Form
    include JsonbAttributes
    mimic :user

    attribute :name, String
    attribute :first_name, String
    attribute :nickname, String
    attribute :email, String
    attribute :password, String
    attribute :password_confirmation, String
    attribute :newsletter, Boolean
    attribute :tos_agreement, Boolean
    attribute :current_locale, String
    jsonb_attribute :registration_metadata, [
      [:cq_interested, Boolean],
      [:address, String],
      [:address_id, String]
    ]

    validates :name, presence: true
    validates :first_name, presence: true
    validates :nickname, presence: true, format: /\A[\w\-]+\z/, length: { maximum: Decidim::User.nickname_max_length }
    validates :email, presence: true, 'valid_email_2/email': { disposable: true }
    validates :password, confirmation: true
    validates :password, password: { name: :name, email: :email, username: :nickname }
    validates :password_confirmation, presence: true
    validates :tos_agreement, allow_nil: false, acceptance: true
    validates :address, presence: true
    validates :address_id, presence: true

    validate :email_unique_in_organization
    validate :nickname_unique_in_organization
    validate :no_pending_invitations_exist
    validate :address_exists?

    def newsletter_at
      return nil unless newsletter?

      Time.current
    end

    private

    def email_unique_in_organization
      errors.add :email, :taken if User.no_active_invitation.find_by(email: email, organization: current_organization).present?
    end

    def nickname_unique_in_organization
      errors.add :nickname, :taken if User.no_active_invitation.find_by(nickname: nickname, organization: current_organization).present?
    end

    def no_pending_invitations_exist
      errors.add :base, I18n.t("devise.failure.invited") if User.has_pending_invitations?(current_organization.id, email)
    end

    def address_exists?
      return if address.blank?
      return if address_id.blank?
      return if list_address_ids.include?(address_id)

      errors.add :address, I18n.t("devise.address.no_match")
    end

    def list_address_ids
      JSON.parse(query_api).fetch("features").map { |feature| feature.dig("properties", "id") }
    end

    def query_api
      url = URI("https://api-adresse.data.gouv.fr/search/?q=#{CGI.escape(address)}")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      request = Net::HTTP::Get.new(url)
      response = https.request(request)
      response.read_body
    end
  end
end
