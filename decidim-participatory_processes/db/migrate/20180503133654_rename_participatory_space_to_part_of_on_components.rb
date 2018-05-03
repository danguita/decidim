# frozen_string_literal: true

class RenameParticipatorySpaceToPartOfOnComponents < ActiveRecord::Migration[5.1]
  def change
    rename_column :decidim_components, :participatory_space_id, :part_of_id
    rename_column :decidim_components, :participatory_space_type, :part_of_type
  end
end
