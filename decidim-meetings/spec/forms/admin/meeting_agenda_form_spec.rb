# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::MeetingAgendaForm do
    subject(:form) { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create(:organization, available_locales: [:en]) }
    let(:context) do
      {
        current_organization: organization,
        current_component: current_component,
        current_participatory_space: participatory_process,
        meeting: meeting
      }
    end
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "meetings" }
    let(:meeting) { create :meeting, component: current_component }

    let(:title) do
      Decidim::Faker::Localized.sentence(3)
    end
    let(:visible) { true }
    let(:agenda_items) do
      [
        {
          title: Decidim::Faker::Localized.sentence(2),
          description: Decidim::Faker::Localized.sentence(5),
          duration: 12,
          position: 0
        },
        {
          title: Decidim::Faker::Localized.sentence(2),
          description: Decidim::Faker::Localized.sentence(5),
          duration: 24,
          position: 1
        }
      ]
    end

    let(:attributes) do
      {
        title: title,
        visible: visible,
        agenda_items: agenda_items
      }
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    describe "when title is missing" do
      let(:title) { { en: nil } }

      it { is_expected.not_to be_valid }
    end

    describe "when a agenda_item is not valid" do
      let(:agenda_items) do
        [
          {
            title: nil,
            description: Decidim::Faker::Localized.sentence(5),
            duration: 12,
            position: 0
          },
        ]
      end

      it { is_expected.not_to be_valid }
    end
  end
end
