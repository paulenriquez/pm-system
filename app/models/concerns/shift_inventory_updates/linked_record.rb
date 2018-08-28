module ShiftInventoryUpdates::LinkedRecord
    extend ActiveSupport::Concern

    def table_name
        self.class.name.underscore.pluralize
    end

    def link_ref_col
        self.class::LINK_REF_COL
    end

    def expected_prev
        siu = ( table_name == 'shift_inventory_updates' ? self : self.shift_inventory_update )
        ShiftInventoryUpdate.shift_iterator(siu.date, siu.shift, -1)
    end

    def expected_next
        siu = ( table_name == 'shift_inventory_updates' ? self : self.shift_inventory_update )
        ShiftInventoryUpdate.shift_iterator(siu.date, siu.shift, +1)
    end

    def chron_prev
        prev_siu = ShiftInventoryUpdate.find_by(self.expected_prev)
        if !prev_siu.nil?
            if !link_ref_col.nil?
                prev_siu
                    .send(table_name)
                    .find_by(link_ref_col => self.send(link_ref_col))
            else
                prev_siu
            end
        else
            nil
        end
    end

    def chron_next
        next_siu = ShiftInventoryUpdate.find_by(self.expected_next)
        if !next_siu.nil?
            if !link_ref_col.nil?
                next_siu
                    .send(table_name)
                    .find_by(link_ref_col => self.send(link_ref_col))
            else
                next_siu
            end
        else
            nil
        end
    end

    def nearest_prev
        if table_name == 'shift_inventory_updates'
            self.class
                .where('date <= ?', self.date)
                .where.not('date = ? AND shift > ?', self.date, self.shift)
                .where.not(id: self.id)
                .order(date: :desc, shift: :desc)
                .limit(1)
                .first
        else
            self.class
                .includes(:shift_inventory_update)
                .where('shift_inventory_updates.date <= ?', self.shift_inventory_update.date)
                .where.not(
                    'shift_inventory_updates.date = ? AND shift_inventory_updates.shift > ?',
                    self.shift_inventory_update.date,
                    self.shift_inventory_update.shift
                )
                .where.not(id: self.id)
                .where(link_ref_col => self.send(link_ref_col))
                .order('shift_inventory_updates.date DESC, shift_inventory_updates.shift DESC')
                .limit(1)
                .first
        end
    end

    def nearest_next
        if table_name == 'shift_inventory_updates'
            self.class
                .where('date >= ?', self.date)
                .where.not('date = ? AND shift < ?', self.date, self.shift)
                .where.not(id: self.id)
                .order(date: :asc, shift: :asc)
                .limit(1)
                .first
        else
            self.class
                .includes(:shift_inventory_update)
                .where('shift_inventory_updates.date >= ?', self.shift_inventory_update.date)
                .where.not(
                    'shift_inventory_updates.date = ? AND shift_inventory_updates.shift < ?',
                    self.shift_inventory_update.date,
                    self.shift_inventory_update.shift
                )
                .where.not(id: self.id)
                .where(link_ref_col => self.send(link_ref_col))
                .order('shift_inventory_updates.date ASC, shift_inventory_updates.shift ASC')
                .limit(1)
                .first
        end
    end
end