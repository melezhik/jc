class Dist < ActiveRecord::Base
    belongs_to :build
    validates :name, presence: true
end
