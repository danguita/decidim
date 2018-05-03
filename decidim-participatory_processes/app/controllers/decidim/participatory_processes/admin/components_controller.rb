# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing the Participatory Process' Components in the
      # admin panel.
      #
      class ComponentsController < Decidim::Admin::ApplicationController
        include Decidim::Admin::Concerns::HasComponents
        include Concerns::ParticipatoryProcessAdmin

        def part_of
          current_participatory_space
        end
      end
    end
  end
end
