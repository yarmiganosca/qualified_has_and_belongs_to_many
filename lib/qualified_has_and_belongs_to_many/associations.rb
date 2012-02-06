module ActiveRecord::Associations
  extend ActiveSupport::Concern
    
  autoload :QualifiedHasAndBelongsToManyAssociation, 'qualified_has_and_belongs_to_many/associations/qualified_has_and_belongs_to_many_association'

  module Builder
    autoload :QualifiedHasAndBelongsToMany, 'qualified_has_and_belongs_to_many/associations/builder/qualified_has_and_belongs_to_many'
  end

  private

  module ClassMethods
    def qualified_has_and_belongs_to_many(name, qualified_by, options = {}, &extension)
      options[:qualified_by] = qualified_by
      Builder::QualifiedHasAndBelongsToMany.build(self, name, options, &extension)
    end
  end
end
