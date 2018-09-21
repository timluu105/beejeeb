require 'enumerable'

class ApplicationRecord < ActiveRecord::Base
  include Enumerable

  self.abstract_class = true

  scope :random, -> { order(Arel::Nodes::NamedFunction.new('RANDOM', [])) }
end
