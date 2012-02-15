module ActiveRecord::Associations::Builder
  class Association
    class_attribute :valid_options
    self.valid_options += [:additional_options]
  end
end
