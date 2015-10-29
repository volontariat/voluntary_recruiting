class Candidature < ActiveRecord::Base
  include StateMachines::Candidature
  
  belongs_to :vacancy
  belongs_to :offeror, class_name: 'User'
  belongs_to :resource, polymorphic: true

  has_many :comments, as: :commentable, dependent: :destroy

  scope :accepted, -> { where(state: 'accepted') }

  validates :vacancy_id, presence: true
  validates :offeror_id, presence: true
  validates :resource_id, presence: true, uniqueness: { scope: [:resource_type, :vacancy_id] }, if: 'validate_resource_id?'
  #validates :name, presence: true, uniqueness: { scope: :vacancy_id }
  
  attr_accessible :vacancy, :vacancy_id, :name, :text
  
  before_validation :set_offeror
  
  # association shortcuts
  def project
    vacancy.project
  end
  
  def product
    project.product
  end
  
  protected
  
  def validate_resource_id?
    true
  end
  
  private
  
  def set_offeror
    self.offeror_id = vacancy.project.user_id
  end
end