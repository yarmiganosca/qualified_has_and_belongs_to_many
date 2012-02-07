require 'active_record/associations/has_and_belongs_to_many_association'

module ActiveRecord
  module Associations
    class QualifiedHasAndBelongsToManyAssociation < HasAndBelongsToManyAssociation
      def initialize(owner, reflection)
        super
      end

      def accepts_qualifiers?
        true
      end

      def qualifier
        if reflection.qualifier_record
          reflection.qualifier_record
        else
          reflection.qualifier_class.find(@qualifier_id)
        end
      end

      def reader(id_or_record = nil, force_reload = false)
        if force_reload
          klass.uncached { reload }
        elsif stale_target?
          reload
        end

        if id_or_record
          @qualifier_id = reflection.get_qualifier_id_from_id_or_record(id_or_record)
        elsif reflection.options[:qualifier_id]
          @qualifier_id = reflection.options[:qualifier_id]
        end

        if @qualifier_id
          proxy.where "#{reflection.qualifier_foreign_key}  = #{@qualifier_id.to_s}"
        else
          self
        end
      end

      def insert_record(record, validate = true, raise = false)
        debugger
        if record.new_record?
          if raise
            record.save!(:validate => validate)
          else
            return unless record.save(:validate => validate)
          end
        end

        if options[:insert_sql]
          owner.connection.insert(interpolate(options[:insert_sql], record))
        else
          stmt = join_table.compile_insert(join_table[reflection.foreign_key] => owner.id,
                                           join_table[reflection.association_foreign_key] => record.id,
                                           join_table[reflection.qualifier_foreign_key] => qualifier.id)

          owner.connection.insert stmt                                           
        end

        record
      end

      private
      
      def count_records
        # change later
        load_taget.size
      end

      def delete_records(records, method)
        if sql = options[:delete_sql]
          records.each { |record| owner.connection.delete(interpolate(sql, record)) }
        else
          relation = join_table
          stmt = relation.where(relation[reflection.foreign_key].eq(owner.id).
                                and(relation[reflection.association_foreign_key].in(records.map(&:id).compact)).
                                and(relation[reflection.qualifier_foreign_key].eq(qualifier.id))).compile_delete

          owner.connection.delete stmt
        end
      end
    end
  end
end
