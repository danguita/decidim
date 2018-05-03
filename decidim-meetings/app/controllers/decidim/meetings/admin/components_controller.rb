# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # Controller that allows managing the compoments used in the meeting. E.g. The survey attached
      #  to the registration process.
      #
      class ComponentsController < Admin::ApplicationController
        include Decidim::Admin::Concerns::HasComponents

        def part_of
          meeting
        end
      end
    end
  end
end
