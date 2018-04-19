# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user creates a Meeting from the admin
      # panel.
      class CreateAgenda < Rectify::Command
        def initialize(form, meeting)
          @form = form
          @meeting = meeting
        end

        # Creates the agenda if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          transaction do
            create_agenda_items
            create_agenda!
          end

          broadcast(:ok, @agenda)
        end

        private


        def create_agenda_items
          @form.agenda_items.each do |form_agenda_item|
            create_agenda_item(form_agenda_item)
          end
        end

        def create_agenda_item(form_agenda_item)
          agenda_item_attributes = {
            title: form_agenda_item.title,
            description: form_agenda_item.description,
            position: form_agenda_item.position,
            }

          create_nested_model(form_agenda_item, agenda_item_attributes, @agenda.agenda_items) do |agenda_item|
            form_agenda_item.agenda_item_childs.each do |form_agenda_item_child|
              agenda_item_child_attributes = {
                title: form_agenda_item_child.title,
                description: form_agenda_item_child.description,
                position: form_agenda_item_child.position
              }

              create_nested_model(form_agenda_item, agenda_item_child_attributes, agenda_item.agenda_item_childs)
            end
          end
        end

        def create_nested_model(form, attributes, agenda_item_childs)
          record = agenda_item_childs.find_by(id: form.id) || agenda_item_childs.build(attributes)

          yield record if block_given?

          if record.persisted?
            if form.deleted?
              record.destroy!
            else
              record.update!(attributes)
            end
          else
            record.save!
          end
        end

        def create_agenda!
          @agenda = Decidim.traceability.create!(
            Agenda,
            @form.current_user,
            title: @form.title,
            meeting: @meeting
          )
        end

      end
    end
  end
end