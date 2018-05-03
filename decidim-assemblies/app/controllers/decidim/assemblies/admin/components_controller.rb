# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing the Assembly' Components in the
      # admin panel.
      #
      class ComponentsController < Decidim::Admin::ApplicationController
        include Decidim::Admin::Concerns::HasComponents
        include Concerns::AssemblyAdmin

        def part_of
          current_participatory_space
        end
      end
    end
  end
end
