# frozen_string_literal: true

module Decidim
  # A Component represents a self-contained group of functionalities usually
  # defined via a ComponentManifest. It's meant to be able to provide a single
  # component that spans over several steps.
  class Component < ApplicationRecord
    include HasSettings
    include Publicable
    include Traceable
    include Loggable

    belongs_to :part_of, polymorphic: true

    default_scope { order(arel_table[:weight].asc, arel_table[:manifest_name].asc) }

    delegate :organization, :categories, to: :part_of

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::ComponentPresenter
    end

    # Public: Finds the manifest this component is associated to.
    #
    # Returns a ComponentManifest.
    def manifest
      Decidim.find_component_manifest(manifest_name)
    end

    # Public: Assigns a manifest to this component.
    #
    # manifest - The ComponentManifest for this Component.
    #
    # Returns nothing.
    def manifest=(manifest)
      self.manifest_name = manifest.name
    end

    # Public: The name of the engine the component is mounted to.
    def mounted_engine
      "decidim_#{part_of_name}_#{manifest_name}"
    end

    # Public: The name of the admin engine the component is mounted to.
    def mounted_admin_engine
      "decidim_admin_#{part_of_name}_#{manifest_name}"
    end

    # Public: The hash of contextual params when the component is mounted.
    def mounted_params
      {
        host: organization.host,
        component_id: id,
        "#{part_of.underscored_name}_slug".to_sym => part_of.slug
      }
    end

    # Public: Returns the value of the registered primary stat.
    def primary_stat
      @primary_stat ||= manifest.stats.filter(primary: true).with_context([self]).map { |name, value| [name, value] }.first&.last
    end

    private

    def part_of_name
      part_of.underscored_name
    end
  end
end
