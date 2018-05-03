# frozen_string_literal: true

require "decidim/components/namer"

Decidim.register_component(:blogs) do |component|
  component.engine = Decidim::Blogs::Engine
  component.admin_engine = Decidim::Blogs::AdminEngine
  component.icon = "decidim/blogs/icon.svg"

  component.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this component" if Decidim::Blogs::Post.where(component: instance).any?
  end

  component.register_stat :posts_count, primary: true, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, _start_at, _end_at|
    Decidim::Blogs::Post.where(component: components).count
  end

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :comments_enabled, type: :boolean, default: true
  end

  component.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :comments_blocked, type: :boolean, default: false
  end

  component.register_resource do |resource|
    resource.model_class_name = "Decidim::Blogs::Post"
  end

  component.seeds do |part_of|
    step_settings = if part_of.allows_steps?
                      { part_of.active_step.id => { comments_enabled: true, comments_blocked: false } }
                    else
                      {}
                    end

    component = Decidim::Component.create!(
      name: Decidim::Components::Namer.new(part_of.organization.available_locales, :blogs).i18n_name,
      manifest_name: :blogs,
      published_at: Time.current,
      part_of: part_of,
      settings: {
        vote_limit: 0
      },
      step_settings: step_settings
    )

    5.times do
      author = Decidim::User.where(organization: component.organization).all.first

      post = Decidim::Blogs::Post.create!(
        component: component,
        title: Decidim::Faker::Localized.sentence(5),
        body: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(20)
        end,
        author: author
      )

      Decidim::Comments::Seed.comments_for(post)
    end
  end
end
