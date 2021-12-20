# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe RegistrationForm do
    subject do
      described_class.from_params(
        attributes
      ).with_context(
        context
      )
    end

    let(:organization) { create(:organization) }
    let(:name) { "User" }
    let(:first_name) { "A great" }
    let(:nickname) { "justme" }
    let(:email) { "user@example.org" }
    let(:password) { "S4CGQ9AM4ttJdPKS" }
    let(:password_confirmation) { password }
    let(:tos_agreement) { "1" }
    let(:cq_interested) { "1" }
    let(:address) { "282 Kevin Brook, Imogeneborough, CA 58517" }
    let(:address_id) { "06004_0710" }
    let(:registration_metadata) do
      {
        cq_interested: cq_interested,
        address: address,
        address_id: address_id
      }
    end

    let(:body_address) { address }
    let(:body_address_id) { address_id }
    let(:body) do
      JSON.dump(
        "type": "FeatureCollection",
        "version": "draft",
        "features": [
          {
            "type": "Feature",
            "geometry": {
              "type": "Point",
              "coordinates": [
                3.824727,
                43.577467
              ]
            },
            "properties": {
              "label": body_address.to_s,
              "score": 0.3143790909090909,
              "id": body_address_id.to_s,
              "name": "Rue",
              "postcode": "34430",
              "citycode": "34270",
              "x": 766_637.42,
              "y": 6_275_726.47,
              "city": "Saint-Jean-de-Védas",
              "context": "34, Hérault, Occitanie",
              "type": "street",
              "importance": 0.45817
            }
          }
        ],
        "attribution": "BAN",
        "licence": "ETALAB-2.0",
        "query": "rue des ",
        "limit": 5
      )
    end

    let(:attributes) do
      {
        name: name,
        first_name: first_name,
        nickname: nickname,
        email: email,
        password: password,
        password_confirmation: password_confirmation,
        tos_agreement: tos_agreement,
        registration_metadata: registration_metadata
      }
    end

    let(:context) do
      {
        current_organization: organization
      }
    end

    before do
      stub_request(:get, "https://api-adresse.data.gouv.fr/search/?q=#{address}")
        .with(
          headers: {
            "Accept" => "*/*",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Host" => "api-adresse.data.gouv.fr",
            "User-Agent" => "Ruby"
          }
        )
        .to_return(status: 200, body: body, headers: {})
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    context "when the email is a disposable account" do
      let(:email) { "user@mailbox92.biz" }

      it { is_expected.to be_invalid }
    end

    context "when the firstname is not present" do
      let(:first_name) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the name is not present" do
      let(:name) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the nickname is not present" do
      let(:nickname) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the email is not present" do
      let(:email) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the email already exists" do
      let!(:user) { create(:user, organization: organization, email: email) }

      it { is_expected.to be_invalid }

      context "and is pending to accept the invitation" do
        let!(:user) { create(:user, organization: organization, email: email, invitation_token: "foo", invitation_accepted_at: nil) }

        it { is_expected.to be_invalid }
      end
    end

    context "when the nickname already exists" do
      let!(:user) { create(:user, organization: organization, nickname: nickname) }

      it { is_expected.to be_invalid }

      context "and is pending to accept the invitation" do
        let!(:user) { create(:user, organization: organization, nickname: nickname, invitation_token: "foo", invitation_accepted_at: nil) }

        it { is_expected.to be_valid }
      end
    end

    context "when the nickname is too long" do
      let(:nickname) { "verylongnicknamethatcreatesanerror" }

      it { is_expected.to be_invalid }
    end

    context "when the password is not present" do
      let(:password) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the password is weak" do
      let(:password) { "aaaabbbbcccc" }

      it { is_expected.to be_invalid }
    end

    context "when the password confirmation is not present" do
      let(:password_confirmation) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the password confirmation is different from password" do
      let(:password_confirmation) { "invalid" }

      it { is_expected.to be_invalid }
    end

    context "when the tos_agreement is not accepted" do
      let(:tos_agreement) { "0" }

      it { is_expected.to be_invalid }
    end

    context "when registration_metadata is empty" do
      let(:registration_metadata) { {} }

      it { is_expected.to be_invalid }
    end

    context "when cq_interested is not checked" do
      let(:cq_interested) { "0" }

      it { is_expected.to be_valid }
    end

    context "when address is empty" do
      let(:address) { nil }

      it { is_expected.to be_invalid }
    end

    context "when address_id is empty" do
      let(:address_id) { nil }

      it { is_expected.to be_invalid }
    end

    context "when address id and address doesn't match with API" do
      let(:body_address_id) { "1234" }

      it { is_expected.to be_invalid }
    end
  end
end
