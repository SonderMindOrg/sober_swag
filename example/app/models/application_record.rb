##
# Base class for all other models.
# Does nothing interesting.
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
