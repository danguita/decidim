# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # Controller that allows managing the Initiative's Components in the
      # admin panel.
      class ComponentsController < Decidim::Admin::ApplicationController
        include Decidim::Admin::Concerns::HasComponents
        include NeedsInitiative

        layout "decidim/admin/initiative"

        def part_of
          current_participatory_space
        end
      end
    end
  end
end
