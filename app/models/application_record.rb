class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def my_onion
    configatron.my_onion
  end
end
