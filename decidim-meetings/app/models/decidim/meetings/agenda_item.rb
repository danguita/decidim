# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a Meeting in the Decidim::Meetings component. It stores a
    # title, description and any other useful information to render a custom meeting.
    class AgendaItem < Meetings::ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable

      belongs_to :agenda, -> { order(:position) }, foreign_key: "decidim_agenda_id", class_name: "Decidim::Meetings::Agenda"

      has_many :agenda_item_childs, foreign_key: "parent_id", class_name: "Decidim::Meetings::AgendaItem", inverse_of: :parent, dependent: :destroy
      belongs_to :parent, foreign_key: "parent_id", class_name: "Decidim::Meetings::AgendaItem", inverse_of: :agenda_item_childs, optional: true

      default_scope { order(:position) }

      def self.first_class
        where(parent_id: nil)
      end

      def parent?
        return true unless parent_id
      end

      def self.agenda_item_childs
        where.not(parent_id: nil)
      end

      def self.log_presenter_class_for(_log)
        Decidim::Meetings::AdminLog::AgendaItemPresenter
      end
    end
  end
end
