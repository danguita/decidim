# frozen_string_literal: true

class AddRegistrationSurveyToMeetings < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_meetings_meetings, :registration_survey_id, :integer
  end
end
