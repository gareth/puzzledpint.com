class City < ApplicationRecord
  belongs_to :parent, class_name: "City", optional: true
  has_many :children, class_name: "City",
    foreign_key: :parent_id, dependent: :destroy
  has_many :event_locations, dependent: :destroy
  has_and_belongs_to_many :admins, optional: true

  validates :name, :country, presence: true

  include Authority::Abilities

  def self.parent_cities
    where(parent: nil)
  end

  def child?
    parent.present?
  end

  def parent?
    not child?
  end

  def display_name
    return "#{parent.name} - #{name}" if parent
    name
  end

  # cutoff_date : Fetch events occurring BEFORE this date. For example,
  #               don't include the current month in the results if one
  #               has already been entered for the city.
  # limit       : Limit results to this many events.
  def recent_locations(cutoff_date, limit)
    event_locations.joins(:event).
      where.not(bar_name: '').
      where('event_at < ?', cutoff_date).
      last(limit)
  end
end
