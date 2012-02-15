require 'qualified_has_and_belongs_to_many/associations/builder/association'
require 'active_record/associations/builder/has_and_belongs_to_many'

module ActiveRecord::Associations::Builder
  class QualifiedHasAndBelongsToMany < HasAndBelongsToMany
    self.macro = :qualified_has_and_belongs_to_many

    self.valid_options += [:qualifier, :qualifier_class_name, :qualifier_id, :qualifier_foreign_key]

    def self.build(model, name, qualifier, options, &extension)
      new(model, name, qualifier, options, &extension).build
    end

    def initialize(model, name, qualifier, options, &extension)
      super(model, name, options, &extension)
      options[:qualifier] = qualifier
    end

    def build
      join_table_option = options[:join_table]
      reflection = super
      set_join_table(reflection, join_table_option)
      reflection
    end
    
    private
    
    # TODO: Eventually ActiveRecord will define a reflection.join_table method.
    #       When that happens, this method should be moved into Reflection.
    def set_join_table(reflection, join_table_option = nil)
      reflection.options[:join_table] = !join_table_option.nil? ? join_table_option : 
        join_table_name(model.send(:undecorated_table_name, model.to_s),
                        model.send(:undecorated_table_name, reflection.class_name),
                        model.send(:undecorated_table_name, reflection.qualifier_class_name))
    end

    def join_table_name(*table_names)
      model.table_name_prefix + table_names.sort.join('_') + model.table_name_suffix
    end
  end
end
