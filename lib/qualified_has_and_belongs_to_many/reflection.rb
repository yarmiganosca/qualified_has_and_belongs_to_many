require 'active_record/reflection'

module ActiveRecord::Reflection
  extend ActiveSupport::Concern

  included do
    class_attribute :reflections
    self.refelctions = {}
  end

  module ClassMethods
    def create_reflection(macro, name, options, active_record)
      case macro
      when :has_many, :belongs_to, :has_one, :has_and_belongs_to_many
        klass = options[:through] ? ThroughReflection : AssociationReflection
        reflection = klass.new(macro, name, options, active_record)
      when :qualified_has_and_belongs_to_many
        reflection = QualifiedAssociationReflection.new(macro, name, options, active_record)
      when :composed_of
        reflection = AggregateReflection.new(macro, name, options, active_record)
      end
      
      self.reflections = self.reflections.merge(name => reflection)
      reflection
    end
  end

  class QualifiedAssociationReflection < AssociationReflection
    attr_reader :qualifier_record

    def initialize(macro, name, options, active_record)
      super

      if options[:qualifier_id]
        set_qualifier_record(options[:qualifier_id])
      end
    end

    def qualifier
      @qualifier = options[:qualifier]
    end

    def qualifier_class_name
      @qualifier_class_name ||= options[:qualifier_class_name] || options[:qualifier].to_s.singularize.camelize
    end

    def qualifier_class
      @qualifier_class ||= qualifier_class_name.constantize
    end

    def qualifier_foreign_key
      @qualifier_foreign_key ||= options[:qualifier_foreign_key] || qualifier_class_name.foreign_key
    end

    def association_class
      Associations::QualifiedHasAndBelongsToManyAssociation
    end

    def get_qualifier_id_from_id_or_record(id_or_record)
      if id_or_record.is_a? Fixnum
        id_or_record
      elsif id_or_record.is_a? qualifier_class
        id_or_record.id
      end
    end

    private

    def set_qualifier_record(id_or_record)
      @qualifier_record ||= qualifier_class.find get_qualifier_record_from_id_or_record(id_or_record)
    end
  end
end
