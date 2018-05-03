# frozen_string_literal: true

require_dependency "decidim/components/namer"

Decidim.register_component(:debates) do |component|
  component.engine = Decidim::Debates::Engine
  component.admin_engine = Decidim::Debates::AdminEngine
  component.icon = "decidim/debates/icon.svg"

  component.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this component" if Decidim::Debates::Debate.where(component: instance).any?
  end

  component.settings(:global) do |settings|
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
    settings.attribute :creation_enabled, type: :boolean, default: false
    settings.attribute :comments_blocked, type: :boolean, default: false
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.register_stat :debates_count, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, _start_at, _end_at|
    Decidim::Debates::Debate.where(component: components).count
  end

  component.register_resource do |resource|
    resource.model_class_name = "Decidim::Debates::Debate"
  end

  component.actions = %w(create)

  component.seeds do |part_of|
    component = Decidim::Component.create!(
      name: Decidim::Components::Namer.new(part_of.organization.available_locales, :debates).i18n_name,
      manifest_name: :debates,
      published_at: Time.current,
      part_of: part_of
    )

    3.times do
      debate = Decidim::Debates::Debate.create!(
        component: component,
        category: part_of.categories.sample,
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        instructions: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        start_time: 3.weeks.from_now,
        end_time: 3.weeks.from_now + 4.hours
      )

      Decidim::Comments::Seed.comments_for(debate)
    end
  end
end
