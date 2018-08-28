class ShiftInventoryUpdatesController < ApplicationController
    include ApplicationHelper

    # Calls the method :get_all_required_records with only the edit and show method
    before_action :get_all_required_records

    def index
    end

    # Checks if there is a current date and if there is a chosen shift. If there is, the current shift inventory
    # update record is/could be edited. If there is none, a new shift inventory 
    def load_form
        if params[:date].present? and params[:shift].present?
            date = params[:date]
            shift = params[:shift]

            @shift_inventory_update = ShiftInventoryUpdate.new(date: date, shift: shift)
            query = {date: @shift_inventory_update.date, shift: @shift_inventory_update.shift}

            if ShiftInventoryUpdate.exists?(query)
                id = ShiftInventoryUpdate.find_by(query).id
                redirect_to edit_shift_inventory_update_path(id)
            else
                if generate_new(@shift_inventory_update)
                    redirect_to edit_shift_inventory_update_path(@shift_inventory_update)
                else
                    
                end
            end
        end
    end

    # Checks if there is a current date and if there is a chosen shift. If there is, a new shift inventory
    # update record is created.
    def load_view
        if params[:date].present? and params[:shift].present?
            date = params[:date]
            shift = params[:shift]

            @shift_inventory_update = ShiftInventoryUpdate.new(date: date, shift: shift)
            query = {date: @shift_inventory_update.date, shift: @shift_inventory_update.shift}
            if ShiftInventoryUpdate.exists?(query)
                id = ShiftInventoryUpdate.find_by(query).id
                redirect_to shift_inventory_update_path(id)
            else
                if generate_new(@shift_inventory_update)
                    redirect_to shift_inventory_update_path(@shift_inventory_update)
                else
                    
                end
            end
        end
    end

    def edit
        @shift_inventory_update = ShiftInventoryUpdate.find(params[:id])
        prebuild_nested_fields @shift_inventory_update
    end

    def update
        @shift_inventory_update = ShiftInventoryUpdate.find params[:id]
        if @shift_inventory_update.update shift_inventory_update_params
            redirect_to shift_inventory_update_path(@shift_inventory_update)
        else
            render :edit
        end
    end

    def show
        @shift_inventory_update = ShiftInventoryUpdate.find(params[:id])
    end

    def destroy
        @shift_inventory_update = ShiftInventoryUpdate.find(params[:id])
        @shift_inventory_update.destroy
    end

    def async_shift_summary
        shift_inventory_update = ShiftInventoryUpdate.find(params[:shift_inventory_update_id])
        render partial: 'shift_inventory_updates/shift_summary/shift_summary',
            locals: { shift_inventory_update: shift_inventory_update }
    end

    def async_fuel_summary
        shift_inventory_update = ShiftInventoryUpdate.find(params[:shift_inventory_update_id])
        render partial: 'shift_inventory_updates/shift_summary/fuel_summary',
            locals: { shift_inventory_update: shift_inventory_update }
    end

    private
        def get_all_required_records
            @products = Product.all
            @fuels = Fuel.all
            @non_fuels = NonFuel.all
            @tanks = Tank.all
            @pump_nozzles = PumpNozzle.all
        end
        def shift_inventory_update_params
            params.require(:shift_inventory_update).permit!
        end
        def generate_new(shift_inventory_update)
            shift_inventory_update.save
        end

        def prebuild_nested_fields(shift_inventory_update)
            fuels = @products.where(type: 'Fuel').order(id: :asc)
            pump_nozzles = @pump_nozzles.order(pump_island_num: :asc, loading_point_num: :asc, nozzle_num: :asc)
            tanks = @tanks.includes(:fuel).order(tank_num: :asc).order('products.id ASC')

            order_config = {
                fuel_sales: tanks,
                dipstick_measurements: tanks,
                pump_reconciliation_totals: fuels,
                pump_meter_readings: pump_nozzles,
                calibrations: pump_nozzles
            }

            prebuilt = {}
            order_config.each { |form, ref_records| prebuilt[form.to_sym] = [] }

            order_config.each do |form, ref_records|
                ref_record_name = ref_records.name.underscore

                ref_records.each do |ref_record|
                    query_sym = "#{ref_record_name}_id".to_s
                    related_record = shift_inventory_update.send(form.to_s).find_by(query_sym => ref_record.id)

                    if related_record.nil?
                        prebuilt[form] << { query_sym => ref_record.id }
                    end
                end

                shift_inventory_update.send(form.to_s).build(prebuilt[form])

                id_order = ref_records.pluck(:id)
                shift_inventory_update.class.class_eval do
                    define_method "#{form.to_s}_by_#{ref_record_name}" do
                        shift_inventory_update.send(form.to_s).each.sort_by do |record|
                            if !defined?(record.write_derived).nil?
                                record.write_derived(rewrite_chain=false, rewrite_dependencies=false)
                            end
                            id_order.index(record.send("#{ref_record_name}_id"))
                        end
                    end
                end

            end

        end
end
