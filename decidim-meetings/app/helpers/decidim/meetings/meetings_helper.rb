# frozen_string_literal: true

module Decidim
  module Meetings
    # Custom helpers used in meetings views
    module MeetingsHelper
      include Decidim::ApplicationHelper
      include Decidim::TranslationsHelper
      include Decidim::ResourceHelper

      # Public: truncates the meeting description
      #
      # meeting - a Decidim::Meeting instance
      # max_length - a number to limit the length of the description
      #
      # Returns the meeting's description truncated.
      def meeting_description(meeting, max_length = 120)
        link = resource_locator(meeting).path
        description = translated_attribute(meeting.description)
        tail = "... #{link_to(t("read_more", scope: "decidim.meetings"), link)}".html_safe
        CGI.unescapeHTML html_truncate(description, max_length: max_length, tail: tail)
      end

      
      def calc_start_and_end_time_of_agenda_items(agenda_items, meeting, start_time_parent = nil)
        array = []

        agenda_items.each_with_index do |agenda_item, index|
          hash = {
            agenda_item_id: agenda_item.id,
            start_time: nil,
            end_time: nil
          }
          if index.zero?
            start = if agenda_item.parent?
                      meeting.start_time
                    else
                      start_time_parent
                    end

            hash[:start_time] = start
          else
            hash[:start_time] = array[index - 1][:end_time]
          end

          hash[:end_time] = hash[:start_time] + agenda_item.duration.minutes

          array.push(hash)
        end

        array
      end

      def display_duration_agenda_items(agenda_item_id, index, agenda_items_times)
        html = ""
        if agenda_item_id == agenda_items_times[index][:agenda_item_id]
          html += "[ #{agenda_items_times[index][:start_time].strftime("%H:%M")} - #{agenda_items_times[index][:end_time].strftime("%H:%M")}]"
        end
        html.html_safe
      end
    end
  end
end
