# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to update meeting agenda items
      class MeetingAgendaForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        attribute :agenda_items, Array[MeetingAgendaItemsForm]
        attribute :visible, Boolean

        validates :title, translatable_presence: true
        validate :total_agenda_duration_lower_than_meeting_duration
        validate :agenda_item_childs_duration_lower_than_or_equal_than_parent

        def map_model(model)
          self.agenda_items = model.agenda_items.first_class.map do |agenda_item|
            MeetingAgendaItemsForm.from_model(agenda_item)
          end
        end

        private

        def meeting
          @meeting ||= context[:meeting]
        end

        def total_agenda_duration_lower_than_meeting_duration
          difference = agenda_duration - meeting_duration
          errors.add(:base, :too_many_minutes, count: difference) if agenda_duration > meeting_duration
        end

        def agenda_duration
          duration = 0
          duration_childs = 0

          duration += agenda_items.sum(&:duration)
          agenda_items.each do |agenda_item|
            duration_childs += agenda_item.agenda_item_childs.sum(&:duration)
          end
          duration + duration_childs
        end

        def meeting_duration
          start_time = meeting.start_time
          end_time = meeting.end_time

          ((end_time - start_time) / 1.minute).round
        end

        def agenda_item_childs_duration_lower_than_or_equal_than_parent
          # return true unless self.agenda_item_childs.presence
          duration_childs = 0

          agenda_items.each do |agenda_item|
            duration_childs += agenda_item.agenda_item_childs.sum(&:duration)
            difference = duration_childs - agenda_item.duration
            errors.add(:base, :too_many_minutes_child, agenda_parent: translated_attribute(agenda_item.title), count: difference) if duration_childs > agenda_item.duration
          end
        end
      end
    end
  end
end
