class Vacancy < ActiveRecord::Base
  include StateMachines::Vacancy
  
  belongs_to :project
  belongs_to :offeror, class_name: 'User'
  belongs_to :author, class_name: 'User'
  belongs_to :resource, polymorphic: true
  belongs_to :project_user
  
  has_many :candidatures, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  
  accepts_nested_attributes_for :candidatures, allow_destroy: true, reject_if: ->(t) { t['name'].blank? }
  scope :open, -> { where(state: 'open') }
  
  validates :resource_type, presence: true
  validates :project_id, presence: true
  validates :offeror_id, presence: true
  validates :name, presence: true
  
  attr_accessible :project_id, :name, :text, :limit, :timezone, :from_raw, :to_raw, :resource_type, :candidatures_attributes
  
  before_validation :set_defaults
  
  def candidatures_left
    if limit
      limit - candidatures.accepted.count
    else
      '∞'
    end
  end
  
  def from_raw
    timezone && from ? from.in_time_zone(timezone).strftime('%Y-%m-%d %H:%M:%S') : ''
  end
  
  def from_raw=(value)
    if timezone && value.present?
      datetime = Time.zone.parse(value)
      args = [
        datetime.strftime('%Y').to_i, datetime.strftime('%m').to_i, datetime.strftime('%d').to_i,
        datetime.strftime('%H').to_i, datetime.strftime('%M').to_i, datetime.strftime('%S').to_i
      ]
      timezone_was = Time.zone
      Time.zone = timezone
      self.from = Time.zone.local *args
    end
  end
  
  def to_raw
    timezone && to ? to.in_time_zone(timezone).strftime('%Y-%m-%d %H:%M:%S') : ''
  end
  
  def to_raw=(value)
    if timezone && value.present?
      datetime = Time.zone.parse(value)
      args = [
        datetime.strftime('%Y').to_i, datetime.strftime('%m').to_i, datetime.strftime('%d').to_i,
        datetime.strftime('%H').to_i, datetime.strftime('%M').to_i, datetime.strftime('%S').to_i
      ]
      timezone_was = Time.zone
      Time.zone = timezone
      self.to = Time.zone.local *args
    end
  end
  
  def ended?
    if from.present? && Time.now < from
      false
    elsif from.blank? && to.present? && Time.now < to
      false
    elsif from.blank? && to.present?
      true
    elsif from.blank?
      false
    else
      true
    end
  end
  
  def calculate_accepted_candidatures_amount
    candidatures.accepted.count
  end
  
  def create_project_user?
    true
  end
  
  protected
  
  def set_defaults
    if project
      self.offeror_id = project.user_id
      self.author_id = project.user_id unless self.author_id.present?
    end
  end
end
