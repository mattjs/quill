class Score < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :user
  serialize :practice_lesson_input, Hash
  serialize :review_lesson_input, Hash
  serialize :missed_rules, Array
  serialize :score_values, Hash
  def all_lesson_input
    practice_lesson_input.merge review_lesson_input
  end

  def missed_rules
    super.uniq.map{ |id| Rule.find(id) }
  end

  def give_time
  	self.completion_date = Time.now
  end

  def completed?
    completion_date.present?
  end

  def final_grade
    return 0.0 unless score_values[:story_percentage].present? && score_values[:review_percentage].present?
    result = (score_values[:story_percentage] + score_values[:review_percentage]).to_f / 2
    return 0.0 if result.nan?
    result
  end

  def finalize!
    self.score_values = ScoreFinalizer.new(self).results
    give_time
    save!
  end
end
