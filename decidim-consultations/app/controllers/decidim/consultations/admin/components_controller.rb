# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # Controller that allows managing the Question's Components in the
      # admin panel.
      class ComponentsController < Decidim::Admin::ApplicationController
        include Decidim::Admin::Concerns::HasComponents
        include QuestionAdmin

        def part_of
          current_participatory_space
        end
      end
    end
  end
end
