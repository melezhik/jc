class Target < ActiveRecord::Base
    belongs_to :build
    validates :name, presence: true
end
