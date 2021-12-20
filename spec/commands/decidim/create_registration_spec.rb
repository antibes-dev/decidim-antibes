# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CreateRegistration do
    describe "call" do
      let(:organization) { create(:organization) }

      let(:name) { "name" }
      let(:first_name) { "a great" }
      let(:complete_name) { "A Great NAME" }
      let(:nickname) { "nickname" }
      let(:email) { "user@example.org" }
      let(:password) { "Y1fERVzL2F" }
      let(:password_confirmation) { password }
      let(:tos_agreement) { "1" }
      let(:newsletter) { "1" }
      let(:current_locale) { "es" }
      let(:registration_metadata) do
        {
          cq_interested: "1",
          address: "282 Kevin Brook, Imogeneborough, CA 58517",
          address_id: "06004_0710"
        }
      end
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
                "label": "282 Kevin Brook, Imogeneborough, CA 58517",
                "score": 0.3143790909090909,
                "id": "06004_0710",
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

      let(:form_params) do
        {
          "user" => {
            "name" => name,
            "first_name" => first_name,
            "nickname" => nickname,
            "email" => email,
            "password" => password,
            "password_confirmation" => password_confirmation,
            "tos_agreement" => tos_agreement,
            "newsletter_at" => newsletter,
            "registration_metadata" => registration_metadata
          }
        }
      end
      let(:form) do
        RegistrationForm.from_params(
          form_params,
          current_locale: current_locale
        ).with_context(
          current_organization: organization
        )
      end
      let(:command) { described_class.new(form) }

      shared_examples "creates the user" do
        it "creates a new user" do
          expect(User).to receive(:create!).with(
            name: complete_name,
            nickname: form.nickname,
            email: form.email,
            password: form.password,
            password_confirmation: form.password_confirmation,
            tos_agreement: form.tos_agreement,
            newsletter_notifications_at: form.newsletter_at,
            email_on_notification: true,
            organization: organization,
            accepted_tos_version: organization.tos_version,
            locale: form.current_locale,
            registration_metadata: form.registration_metadata
          ).and_call_original

          expect { command.call }.to change(User, :count).by(1)
        end
      end

      before do
        stub_request(:get, "https://api-adresse.data.gouv.fr/search/?q=282%20Kevin%20Brook,%20Imogeneborough,%20CA%2058517")
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

      describe "when the form is not valid" do
        before do
          expect(form).to receive(:invalid?).and_return(true)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "doesn't create a user" do
          expect do
            command.call
          end.not_to change(User, :count)
        end

        context "when the user was already invited" do
          let(:user) { build(:user, email: email, organization: organization) }

          before do
            user.invite!
            clear_enqueued_jobs
          end

          it "receives the invitation email again" do
            expect do
              command.call
              user.reload
            end.to change(User, :count).by(0)
                                       .and broadcast(:invalid)
              .and change(user.reload, :invitation_token)
            expect(ActionMailer::DeliveryJob).to have_been_enqueued.on_queue("mailers")
          end
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it_behaves_like "creates the user"

        describe "when user keeps the newsletter unchecked" do
          let(:newsletter) { "0" }

          it "creates a user with no newsletter notifications" do
            expect do
              command.call
              expect(User.last.newsletter_notifications_at).to eq(nil)
            end.to change(User, :count).by(1)
          end
        end

        context "when registration metadata contains the address" do
          it "sets address" do
            expect do
              command.call
              expect(User.last.registration_metadata["address"]).to eq("282 Kevin Brook, Imogeneborough, CA 58517")
              expect(User.last.registration_metadata["address_id"]).to eq("06004_0710")
            end.to change(User, :count).by(1)
          end
        end

        describe "#complete_name" do
          context "when firstname or name starts have whitespaces" do
            let(:first_name) { " a great" }
            let(:name) { "name " }

            it_behaves_like "creates the user"
          end
        end
      end
    end
  end
end
