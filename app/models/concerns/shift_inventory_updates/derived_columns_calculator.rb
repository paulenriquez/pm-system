module ShiftInventoryUpdates::DerivedColumnsCalculator
    extend ActiveSupport::Concern

    def table_name
        self.class.name.underscore.pluralize
    end

    def derived_columns
        self.class::DERIVED_COLUMNS
    end

    def write_derived(rewrite_chain=true, rewrite_dependencies=true)
        derived_columns.each do |derived_column|
            if self.id.nil?
                derived_val = nil
                begin
                    derived_val = send("calc_#{derived_column.to_s}".to_sym)
                rescue

                end
                
                self.send("#{derived_column}=".to_sym, derived_val)
            else
                self.update_column(
                    derived_column,
                    send("calc_#{derived_column.to_s}".to_sym)
                )
            end
        end
        
        self.rewrite_chain if rewrite_chain
        self.rewrite_dependencies if rewrite_dependencies
    end

    def rewrite_chain
        next_record = self.nearest_next
        if !next_record.nil?
            self.nearest_next.write_derived
        end
    end

    def rewrite_dependencies
        siu_associations = ShiftInventoryUpdate.reflections.collect do |table, assoc_config|
            table if assoc_config.class == ActiveRecord::Reflection::HasManyReflection
        end
        siu_associations.compact!

        siu_associations = siu_associations.map do |table|
            model = table.classify.constantize
            table if model.instance_methods.include?(:write_derived)
        end
        siu_associations.compact!
        
        shift_inventory_update = self.shift_inventory_update
        siu_associations.each do |table|
            association = shift_inventory_update.send(table.to_sym)
            association.each { |record| record.write_derived(rewrite_chain=true, rewrite_dependencies=false) }
        end
    end
end